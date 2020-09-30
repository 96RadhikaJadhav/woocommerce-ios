import XCTest
import CoreData

@testable import Storage

/// Tests for migrating from a specific model version to another.
///
/// Ideally, we should have a test for every new model version. There can also be more than
/// one test between 2 versions if there are many cases being tested.
///
/// ## Notes
///
/// In general, we should avoid using the entity classes like `Product` or `Order`. These classes
/// may **change** in the future. And if they do, the migration tests would have to be changed.
/// There's a risk that the migration tests would no longer be correct if this happens.
///
/// That said, it is understandable that we are sometimes under pressure to finish features that
/// this may not be economical.
///
final class MigrationTests: XCTestCase {
    private var modelsInventory: ManagedObjectModelsInventory!

    /// URLs of SQLite stores created using `makePersistentStore()`.
    ///
    /// These will be deleted during tear down.
    private var createdStoreURLs = Set<URL>()

    override func setUpWithError() throws {
        try super.setUpWithError()
        modelsInventory = try .from(packageName: "WooCommerce", bundle: Bundle(for: CoreDataManager.self))
    }

    override func tearDownWithError() throws {
        let fileManager = FileManager.default
        let knownExtensions = ["sqlite-shm", "sqlite-wal"]
        try createdStoreURLs.forEach { url in
            try fileManager.removeItem(at: url)

            try knownExtensions.forEach { ext in
                if fileManager.fileExists(atPath: url.appendingPathExtension(ext).path) {
                    try fileManager.removeItem(at: url.appendingPathExtension(ext))
                }
            }
        }

        modelsInventory = nil

        try super.tearDownWithError()
    }

    func test_migrating_from_26_to_27_deletes_ProductCategory_objects() throws {
        // Arrange
        let sourceContainer = try startPersistentContainer("Model 26")
        let sourceContext = sourceContainer.viewContext

        insertAccount(to: sourceContext)
        let product = insertProduct(to: sourceContext)
        let productCategory = insertProductCategory(to: sourceContext)
        product.mutableSetValue(forKey: "categories").add(productCategory)

        try sourceContext.save()

        XCTAssertEqual(try sourceContext.count(entityName: "Account"), 1)
        XCTAssertEqual(try sourceContext.count(entityName: "Product"), 1)
        XCTAssertEqual(try sourceContext.count(entityName: "ProductCategory"), 1)

        // Action
        let targetContainer = try migrate(sourceContainer, to: "Model 27")
        let targetContext = targetContainer.viewContext

        // Assert
        XCTAssertEqual(try targetContext.count(entityName: "Account"), 1)
        XCTAssertEqual(try targetContext.count(entityName: "Product"), 1)
        // Product categories should be deleted.
        XCTAssertEqual(try targetContext.count(entityName: "ProductCategory"), 0)
    }

    func test_migrating_from_31_to_32_renames_Attribute_to_GenericAttribute() throws {
        // Given
        let container = try startPersistentContainer("Model 31")

        let attribute = container.viewContext.insert(entityName: "Attribute", properties: [
            "id": 9_753_134,
            "key": "voluptatem",
            "value": "veritatis"
        ])
        let variation = insertProductVariation(to: container.viewContext)
        variation.mutableOrderedSetValue(forKey: "attributes").add(attribute)

        try container.viewContext.save()

        XCTAssertEqual(try container.viewContext.count(entityName: "Attribute"), 1)
        XCTAssertEqual(try container.viewContext.count(entityName: "ProductVariation"), 1)

        // When
        let migratedContainer = try migrate(container, to: "Model 32")

        // Then
        XCTAssertNil(NSEntityDescription.entity(forEntityName: "Attribute", in: migratedContainer.viewContext))
        XCTAssertEqual(try migratedContainer.viewContext.count(entityName: "GenericAttribute"), 1)
        XCTAssertEqual(try migratedContainer.viewContext.count(entityName: "ProductVariation"), 1)

        let migratedAttribute = try XCTUnwrap(migratedContainer.viewContext.allObjects(entityName: "GenericAttribute").first)
        XCTAssertEqual(migratedAttribute.value(forKey: "id") as? Int, 9_753_134)
        XCTAssertEqual(migratedAttribute.value(forKey: "key") as? String, "voluptatem")
        XCTAssertEqual(migratedAttribute.value(forKey: "value") as? String, "veritatis")

        // The "attributes" relationship should have been migrated too
        let migratedVariation = try XCTUnwrap(migratedContainer.viewContext.allObjects(entityName: "ProductVariation").first)
        let migratedVariationAttributes = migratedVariation.mutableOrderedSetValue(forKey: "attributes")
        XCTAssertEqual(migratedVariationAttributes.count, 1)
        XCTAssertEqual(migratedVariationAttributes.firstObject as? NSManagedObject, migratedAttribute)

        // The migrated attribute can be accessed using the newly renamed `GenericAttribute` class.
        let genericAttribute = try XCTUnwrap(migratedContainer.viewContext.firstObject(ofType: GenericAttribute.self))
        XCTAssertEqual(genericAttribute.id, 9_753_134)
        XCTAssertEqual(genericAttribute.key, "voluptatem")
        XCTAssertEqual(genericAttribute.value, "veritatis")
    }
}

// MARK: - Persistent Store Setup and Migrations

private extension MigrationTests {
    /// Create a new Sqlite file and load it. Returns the loaded `NSPersistentContainer`.
    func startPersistentContainer(_ versionName: String) throws -> NSPersistentContainer {
        let storeURL = try XCTUnwrap(NSURL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent(UUID().uuidString)?
            .appendingPathExtension("sqlite"))
        let model = try XCTUnwrap(modelsInventory.model(for: .init(name: versionName)))
        let container = makePersistentContainer(storeURL: storeURL, model: model)

        let loadingError: Error? = try waitFor { promise in
            container.loadPersistentStores { _, error in
                promise(error)
            }
        }
        XCTAssertNil(loadingError)

        return container
    }

    /// Migrate the existing `container` to the model with name `versionName`.
    ///
    /// This disconnects the given `container` from the `NSPersistentStore` (SQLite) to avoid
    /// warnings pertaining to having two `NSPersistentContainer` using the same SQLite file.
    /// The `container.viewContext` and any created `NSManagedObjects` can still be used but
    /// they will not be attached to the SQLite database so watch out for that. XD
    ///
    /// - Returns: A new `NSPersistentContainer` instance using the new `NSManagedObjectModel`
    ///            pointed to by `versionName`.
    ///
    func migrate(_ container: NSPersistentContainer, to versionName: String) throws -> NSPersistentContainer {
        let storeDescription = try XCTUnwrap(container.persistentStoreDescriptions.first)
        let storeURL = try XCTUnwrap(storeDescription.url)
        let targetModel = try XCTUnwrap(modelsInventory.model(for: .init(name: versionName)))

        // Unload the currently loaded persistent store to avoid Sqlite warnings when we create
        // another NSPersistentContainer later after the upgrade.
        let persistentStore = try XCTUnwrap(container.persistentStoreCoordinator.persistentStore(for: storeURL))
        try container.persistentStoreCoordinator.remove(persistentStore)

        // Migrate the store
        let migrator = CoreDataIterativeMigrator(modelsInventory: modelsInventory)
        let (isMigrationSuccessful, _) =
            try migrator.iterativeMigrate(sourceStore: storeURL, storeType: storeDescription.type, to: targetModel)
        XCTAssertTrue(isMigrationSuccessful)

        // Load a new container
        let migratedContainer = makePersistentContainer(storeURL: storeURL, model: targetModel)
        let loadingError: Error? = try waitFor { promise in
            migratedContainer.loadPersistentStores { _, error in
                promise(error)
            }
        }
        XCTAssertNil(loadingError)

        return migratedContainer
    }

    func makePersistentContainer(storeURL: URL, model: NSManagedObjectModel) -> NSPersistentContainer {
        let description: NSPersistentStoreDescription = {
            let description = NSPersistentStoreDescription(url: storeURL)
            description.shouldAddStoreAsynchronously = false
            description.shouldMigrateStoreAutomatically = false
            description.type = NSSQLiteStoreType
            return description
        }()

        let container = NSPersistentContainer(name: "ContainerName", managedObjectModel: model)
        container.persistentStoreDescriptions = [description]

        createdStoreURLs.insert(storeURL)

        return container
    }
}

// MARK: - Entity Helpers
//

private extension MigrationTests {
    /// Inserts a `ProductVariation` entity, providing default values for the required properties.
    @discardableResult
    func insertProductVariation(to context: NSManagedObjectContext) -> NSManagedObject {
        context.insert(entityName: "ProductVariation", properties: [
            "dateCreated": Date(),
            "backordered": false,
            "backordersAllowed": false,
            "backordersKey": "",
            "permalink": "",
            "price": "",
            "statusKey": "",
            "stockStatusKey": "",
            "taxStatusKey": ""
        ])
    }

    @discardableResult
    func insertAccount(to context: NSManagedObjectContext) -> NSManagedObject {
        context.insert(entityName: "Account", properties: [
            "userID": 0,
            "username": ""
        ])
    }

    @discardableResult
    func insertProduct(to context: NSManagedObjectContext) -> NSManagedObject {
        context.insert(entityName: "Product", properties: [
            "price": "",
            "permalink": "",
            "productTypeKey": "simple",
            "purchasable": true,
            "averageRating": "",
            "backordered": true,
            "backordersAllowed": false,
            "backordersKey": "",
            "catalogVisibilityKey": "",
            "dateCreated": Date(),
            "downloadable": true,
            "featured": true,
            "manageStock": true,
            "name": "product",
            "onSale": true,
            "soldIndividually": true,
            "slug": "",
            "shippingRequired": false,
            "shippingTaxable": false,
            "reviewsAllowed": true,
            "groupedProducts": [],
            "virtual": true,
            "stockStatusKey": "",
            "statusKey": "",
            "taxStatusKey": ""
        ])
    }

    @discardableResult
    func insertProductCategory(to context: NSManagedObjectContext) -> NSManagedObject {
        context.insert(entityName: "ProductCategory", properties: [
            "name": "",
            "slug": ""
        ])
    }

    @discardableResult
    func insertProductTag(to context: NSManagedObjectContext) -> NSManagedObject {
        context.insert(entityName: "ProductTag", properties: [
            "tagID": 0,
            "name": "",
            "slug": ""
        ])
    }
}
