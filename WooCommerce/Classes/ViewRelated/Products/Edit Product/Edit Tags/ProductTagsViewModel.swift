import Foundation
import Yosemite

final class ProductTagsViewModel {

    /// Obscure token that allows the view model to retry the synchronizeTags operation
    ///
    struct RetryToken: Equatable {
        fileprivate let fromPageNumber: Int
    }

    /// Represents the current state of `synchronizeTags` action. Useful for the consumer to update it's UI upon changes
    ///
    enum SyncingState: Equatable {
        case initialized
        case syncing
        case failed(RetryToken)
        case synced
    }

    /// Reference to the StoresManager to dispatch Yosemite Actions.
    ///
    private let storesManager: StoresManager

    /// Product the user is editiing
    ///
    private let product: Product

    /// Product tags that will be eventually modified by the user
    ///
    private(set) var originalTags: [String]

    /// List of all the fetched tags for a specific SiteID
    ///
    private(set) var fetchedTags: [ProductTag] = []

    /// List of all the sections
    ///
    private (set) var sections: [Section] = []

    /// Closure to be invoked when `synchronizeTags` state  changes
    ///
    private var onSyncStateChange: ((SyncingState) -> Void)?

    /// Current  tag synchronization state
    ///
    private var syncTagsState: SyncingState = .initialized {
        didSet {
            guard syncTagsState != oldValue else {
                return
            }
            onSyncStateChange?(syncTagsState)
        }
    }

    private lazy var resultController: ResultsController<StorageProductTag> = {
        let storageManager = ServiceLocator.storageManager
        let predicate = NSPredicate(format: "siteID = %ld", self.product.siteID)
        let descriptor = NSSortDescriptor(keyPath: \StorageProductTag.name, ascending: true)
        return ResultsController<StorageProductTag>(storageManager: storageManager, matching: predicate, sortedBy: [descriptor])
    }()

    init(storesManager: StoresManager = ServiceLocator.stores, product: Product) {
        self.storesManager = storesManager
        self.product = product

        originalTags = product.tags.map { $0.name }
    }

    /// Load existing tags from storage and fire the synchronize all tags action.
    ///
    func performFetch() {
        synchronizeAllTags()
        try? resultController.performFetch()
    }

    /// Retry product tags synchronization when `syncTagsState` is on a `.failed` state.
    ///
    func retryTagSynchronization(retryToken: RetryToken) {
        guard syncTagsState == .failed(retryToken) else {
            return
        }
        synchronizeAllTags(fromPageNumber: retryToken.fromPageNumber)
    }

    /// Observes and notifies of changes made to product tags. the current state will be dispatched upon subscription.
    /// Calling this method will remove any other previous observer.
    ///
    func observeTagListStateChanges(onStateChanges: @escaping (SyncingState) -> Void) {
        onSyncStateChange = onStateChanges
        onSyncStateChange?(syncTagsState)
    }

    func hasUnsavedChanges() -> Bool {
        return product.tags.map { $0.name }.sorted() != originalTags.sorted()
    }
}

// MARK: - Synchronize Tags
//
private extension ProductTagsViewModel {
    /// Synchronizes all product tags starting at a specific page number. Default initial page number is set on `Default.firstPageNumber`
    ///
    func synchronizeAllTags(fromPageNumber: Int = Default.firstPageNumber) {
        self.syncTagsState = .syncing
        let action = ProductTagAction.synchronizeAllProductTags(siteID: product.siteID, fromPageNumber: fromPageNumber) { [weak self] error in
            // Make sure we always have fetched tags to display
            self?.updateFetchedTagsAndSections()

            if let error = error {
                self?.handleSychronizeAllTagsError(error)
            } else {
                self?.syncTagsState = .synced
            }
        }
        storesManager.dispatch(action)
    }

    /// Update `syncTagsState` with the proper retryToken
    ///
    func handleSychronizeAllTagsError(_ error: ProductTagActionError) {
        switch error {
        case let .tagsSynchronization(pageNumber, rawError):
            let retryToken = RetryToken(fromPageNumber: pageNumber)
            syncTagsState = .failed(retryToken)
            DDLogError("⛔️ Error fetching product tags: \(rawError.localizedDescription)")
        }
    }

    /// Updates  `fetchedTags` and `sections` from  the resultController's fetched objects.
    ///
    func updateFetchedTagsAndSections() {
        fetchedTags = resultController.fetchedObjects
        let rows: [Row] = fetchedTags.map { _ in Row.tag }
        sections = [Section(rows: rows)]
    }
}

// MARK: - Constants
//
extension ProductTagsViewModel {

    /// Table Rows
    ///
    enum Row {
        /// Listed in the order they appear on screen
        case tag

        /// Returns the Row's Reuse Identifier
        ///
        var reuseIdentifier: String {
            return cellType.reuseIdentifier
        }

        /// Returns the Row's Cell Type
        ///
        var cellType: UITableViewCell.Type {
            switch self {
            case .tag:
                return BasicTableViewCell.self
            }
        }
    }

    /// Table Sections
    ///
    struct Section: RowIterable {
        let rows: [Row]

        init(rows: [Row]) {
            self.rows = rows
        }
    }

    enum Default {
        public static let firstPageNumber = 1
    }
}
