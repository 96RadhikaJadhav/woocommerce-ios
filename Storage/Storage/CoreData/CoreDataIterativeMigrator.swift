import Foundation
import CoreData

/// CoreDataIterativeMigrator: Migrates through a series of models to allow for users to skip app versions without risk.
/// This was derived from ALIterativeMigrator originally used in the WordPress app.
///
final class CoreDataIterativeMigrator {

    /// The coordinator instance whose functions will be used for replacing the existing
    /// store with the migrated one.
    ///
    /// The coordinator instance can be retrieved from `NSPersistentContainer.persistentStoreCoordinator`.
    ///
    private let persistentStoreCoordinator: NSPersistentStoreCoordinator
    /// The model versions that will be used for migration.
    private let modelsInventory: ManagedObjectModelsInventory

    private let fileManager: FileManagerProtocol

    init(coordinator: NSPersistentStoreCoordinator,
         modelsInventory: ManagedObjectModelsInventory,
         fileManager: FileManagerProtocol = FileManager.default) {
        persistentStoreCoordinator = coordinator
        self.modelsInventory = modelsInventory
        self.fileManager = fileManager
    }

    /// Migrates a store to a particular model using the list of models to do it iteratively, if required.
    ///
    /// - Parameters:
    ///     - sourceStore: URL of the store on disk.
    ///     - storeType: Type of store (usually NSSQLiteStoreType).
    ///     - to: The target/most current model the migrator should migrate to.
    ///     - using: List of models on disk, sorted in migration order, that should include the to: model.
    ///
    /// - Returns: True if the process succeeded and didn't run into any errors. False if there was any problem and the store was left untouched.
    ///
    /// - Throws: A whole bunch of crap is possible to be thrown between Core Data and FileManager.
    ///
    func iterativeMigrate(sourceStore: URL,
                          storeType: String,
                          to targetModel: NSManagedObjectModel) throws -> (success: Bool, debugMessages: [String]) {
        // If the persistent store does not exist at the given URL,
        // assume that it hasn't yet been created and return success immediately.
        guard fileManager.fileExists(atPath: sourceStore.path) == true else {
            return (true, ["No store exists at URL \(sourceStore).  Skipping migration."])
        }

        // Get the persistent store's metadata.  The metadata is used to
        // get information about the store's managed object model.
        let sourceMetadata =
            try NSPersistentStoreCoordinator.metadataForPersistentStore(ofType: storeType, at: sourceStore, options: nil)

        // Check whether the final model is already compatible with the store.
        // If it is, no migration is necessary.
        guard targetModel.isConfiguration(withName: nil, compatibleWithStoreMetadata: sourceMetadata) == false else {
            return (true, ["Target model is compatible with the store. No migration necessary."])
        }

        // Find the current model used by the store.
        let sourceModel = try model(for: sourceMetadata)

        // Retrieve an inclusive list of models between the source and target models.
        let modelsToMigrate = try self.modelsToMigrate(from: sourceModel, to: targetModel)
        guard modelsToMigrate.count > 1 else {
            return (false, ["Skipping migration. Unexpectedly found less than 2 models to perform a migration."])
        }

        var debugMessages = [String]()

        // Migrate between each model. Count - 2 because of zero-based index and we want
        // to stop at the last pair (you can't migrate the last model to nothingness).
        let upperBound = modelsToMigrate.count - 2
        for index in 0...upperBound {
            let modelFrom = modelsToMigrate[index]
            let modelTo = modelsToMigrate[index + 1]
            let mappingModel = try self.mappingModel(from: modelFrom, to: modelTo)

            // Migrate the model to the next step
            let migrationAttemptMessage = makeMigrationAttemptLogMessage(models: modelsToMigrate,
                                                                         from: modelFrom,
                                                                         to: modelTo)
            debugMessages.append(migrationAttemptMessage)
            DDLogWarn(migrationAttemptMessage)

            let migrationResult = migrateStore(at: sourceStore,
                                               storeType: storeType,
                                               fromModel: modelFrom,
                                               toModel: modelTo,
                                               with: mappingModel)
            switch migrationResult {
            case .success(let destinationURL):
                #warning("FIXME I should do something!")
                print("successful")
            case .failure(let error):
                let errorInfo = (error as NSError?)?.userInfo ?? [:]
                debugMessages.append("Migration error: \(error) [\(errorInfo)]")
                return (false, debugMessages)
            }
        }

        return (true, debugMessages)
    }
}


// MARK: - File helpers
//
private extension CoreDataIterativeMigrator {

    /// Build a temporary SQLite **file URL** to be used as the destination when performing a
    /// migration.
    ///
    /// - Returns: A unique URL in the temporary directory.
    func makeTemporaryMigrationDestinationURL() -> URL {
        URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
            .appendingPathComponent("migration_\(UUID().uuidString)")
            .appendingPathExtension("sqlite")
    }

    /// Deletes the SQLite files for the store at the given `storeURL`.
    ///
    /// The files that will be deleted are:
    ///
    /// - {store_filename}.sqlite
    /// - {store_filename}.sqlite-wal
    /// - {store_filename}.sqlite-shm
    ///
    /// Where {store_filename} is most probably "WooCommerce".
    ///
    /// TODO Possibly replace this with `NSPersistentStoreCoordinator.destroyStore` or use
    /// `replaceStore` directly.
    ///
    /// - Throws: `Error` if one of the deletion fails.
    ///
    func deleteStoreFiles(storeURL: URL) throws {
        let storeFolderURL = storeURL.deletingLastPathComponent()

        do {
            try fileManager.contentsOfDirectory(atPath: storeFolderURL.path).map { fileName in
                storeFolderURL.appendingPathComponent(fileName)
            }.filter { fileURL in
                // Only include files that have the same filename as the store (sqlite) filename.
                fileURL.deletingPathExtension() == storeURL.deletingPathExtension()
            }.forEach { fileURL in
                try fileManager.removeItem(at: fileURL)
            }
        } catch {
            DDLogError("⛔️ Error while deleting the store SQLite files: \(error)")
            throw error
        }
    }

    /// Copy the store files that were migrated (using `NSMigrationManager`) to where the
    /// store files should be loaded by `CoreDataManager` later.
    ///
    func copyMigratedOverOriginal(from tempDestinationURL: URL, to storeURL: URL) throws {
        do {
            let files = try fileManager.contentsOfDirectory(atPath: tempDestinationURL.deletingLastPathComponent().path)
            try files.forEach { (file) in
                if file.hasPrefix(tempDestinationURL.lastPathComponent) {
                    let sourceURL = tempDestinationURL.deletingLastPathComponent().appendingPathComponent(file)
                    let targetURL = storeURL.deletingLastPathComponent().appendingPathComponent(file)

                    // TODO This removeItem may not be necessary because we should have already
                    // deleted everything during `deleteStoreFiles`.
                    try? fileManager.removeItem(at: targetURL)

                    try fileManager.moveItem(at: sourceURL, to: targetURL)
                }
            }
        } catch {
            DDLogError("⛔️ Error while copying migrated over the original files: \(error)")
            throw error
        }
    }

    func makeMigrationAttemptLogMessage(models: [NSManagedObjectModel],
                                        from fromModel: NSManagedObjectModel,
                                        to toModel: NSManagedObjectModel) -> String {
        // This logic is a bit nasty. I'm just trying to keep the existing logic intact for now.

        let versions = modelsInventory.versions

        let fromName: String? = {
            if let index = models.firstIndex(of: fromModel) {
                return versions[safe: index]?.name
            } else {
                return nil
            }
        }()

        let toName: String? = {
            if let index = models.firstIndex(of: toModel) {
                return versions[safe: index]?.name
            } else {
                return nil
            }
        }()

        return "⚠️ Attempting migration from \(fromName ?? "unknown") to \(toName ?? "unknown")"
    }
}


// MARK: - Private helper functions
//
private extension CoreDataIterativeMigrator {

    /// Migrates a store located at the given `sourceURL` to a temporary `URL`. The source store is
    /// **never changed**.
    func migrateStore(at sourceURL: URL,
                      storeType: String,
                      fromModel: NSManagedObjectModel,
                      toModel: NSManagedObjectModel,
                      with mappingModel: NSMappingModel) -> Result<URL, Error> {
        let tempDestinationURL = makeTemporaryMigrationDestinationURL()

        // Migrate from the source model to the target model using the mapping,
        // and store the resulting data at the temporary path.
        let migrator = NSMigrationManager(sourceModel: fromModel, destinationModel: toModel)
        do {
            try migrator.migrateStore(from: sourceURL,
                                      sourceType: storeType,
                                      options: nil,
                                      with: mappingModel,
                                      toDestinationURL: tempDestinationURL,
                                      destinationType: storeType,
                                      destinationOptions: nil)
        } catch {
            return .failure(error)
        }

        do {
            // Delete the original store files.
            try deleteStoreFiles(storeURL: sourceURL)
            // Replace the (deleted) original store files with the migrated store files.
            try copyMigratedOverOriginal(from: tempDestinationURL, to: sourceURL)
        } catch {
            return .failure(error)
        }

        return.success(tempDestinationURL)
    }

    func model(for metadata: [String: Any]) throws -> NSManagedObjectModel {
        let bundle = Bundle(for: CoreDataManager.self)
        guard let sourceModel = NSManagedObjectModel.mergedModel(from: [bundle], forStoreMetadata: metadata) else {
            let description = "Failed to find source model for metadata: \(metadata)"
            throw NSError(domain: "IterativeMigrator", code: 100, userInfo: [NSLocalizedDescriptionKey: description])
        }

        return sourceModel
    }

    func models(for modelVersions: [ManagedObjectModelsInventory.ModelVersion]) throws -> [NSManagedObjectModel] {
        try modelVersions.map { version -> NSManagedObjectModel in
            guard let model = self.modelsInventory.model(for: version) else {
                let description = "No model found for \(version.name)"
                throw NSError(domain: "IterativeMigrator", code: 110, userInfo: [NSLocalizedDescriptionKey: description])
            }

            return model
        }
    }

    /// Returns an inclusive list of models between the source and target models.
    func modelsToMigrate(from sourceModel: NSManagedObjectModel,
                         to targetModel: NSManagedObjectModel) throws -> [NSManagedObjectModel] {
        // Get NSManagedObjectModels for each of the model names given.
        let objectModels = try models(for: modelsInventory.versions)

        // Build an inclusive list of models between the source and final models.
        var modelsToMigrate = [NSManagedObjectModel]()
        var firstFound = false, lastFound = false, reverse = false

        for model in objectModels {
            if model.isEqual(sourceModel) || model.isEqual(targetModel) {
                if firstFound {
                    lastFound = true
                    // In case a reverse migration is being performed (descending through the
                    // ordered array of models), check whether the source model is found
                    // after the final model.
                    reverse = model.isEqual(sourceModel)
                } else {
                    firstFound = true
                }
            }

            if firstFound {
                modelsToMigrate.append(model)
            }

            if lastFound {
                break
            }
        }

        // Ensure that the source model is at the start of the list.
        if reverse {
            modelsToMigrate = modelsToMigrate.reversed()
        }

        return modelsToMigrate
    }

    /// Load a developer-defined `NSMappingModel` (`*.xcmappingmodel` file) or infer it.
    func mappingModel(from sourceModel: NSManagedObjectModel,
                      to targetModel: NSManagedObjectModel) throws -> NSMappingModel {
        if let mappingModel = NSMappingModel(from: nil, forSourceModel: sourceModel, destinationModel: targetModel) {
            return mappingModel
        }

        return try NSMappingModel.inferredMappingModel(forSourceModel: sourceModel, destinationModel: targetModel)
    }
}
