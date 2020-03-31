import XCTest
import Storage
import CoreData
@testable import Yosemite

final class ResultsController_StorageProductTests: XCTestCase {
    /// InMemory Storage!
    ///
    private var storage: MockupStorageManager!

    /// Returns the NSMOC associated to the Main Thread
    ///
    private var viewContext: NSManagedObjectContext {
        return storage.persistentContainer.viewContext
    }

    private let sampleSiteID: Int64 = 134

    private lazy var sampleProductsPredicate = NSPredicate(format: "siteID == %lld", sampleSiteID)

    // MARK: - Overridden Methods

    override func setUp() {
        super.setUp()
        storage = MockupStorageManager()
    }

    // MARK: tests for `init` with a `ProductsSortOrder` param

    func testProductResultsControllerInitWithAscendingNameSortOrder() {
        // Arrange
        let product1 = MockProduct().product(siteID: sampleSiteID, productID: 1, name: "Zap")
        storage.insertSampleProduct(readOnlyProduct: product1)

        let product2 = MockProduct().product(siteID: sampleSiteID, productID: 2, name: "fun house")
        storage.insertSampleProduct(readOnlyProduct: product2)

        // Act
        let resultsController = ResultsController<StorageProduct>(viewContext: viewContext,
                                                                  matching: sampleProductsPredicate,
                                                                  sortOrder: .nameAscending)
        try? resultsController.performFetch()

        // Assert
        XCTAssertEqual(resultsController.fetchedObjects.count, 2)
        XCTAssertEqual(resultsController.fetchedObjects, [product2, product1])
    }

    func testProductResultsControllerInitWithDescendingNameSortOrder() {
        // Arrange
        let product1 = MockProduct().product(siteID: sampleSiteID, productID: 1, name: "fun house")
        storage.insertSampleProduct(readOnlyProduct: product1)

        let product2 = MockProduct().product(siteID: sampleSiteID, productID: 2, name: "zap!")
        storage.insertSampleProduct(readOnlyProduct: product2)

        // Act
        let resultsController = ResultsController<StorageProduct>(viewContext: viewContext,
                                                                  matching: sampleProductsPredicate,
                                                                  sortOrder: .nameDescending)
        try? resultsController.performFetch()

        // Assert
        XCTAssertEqual(resultsController.fetchedObjects.count, 2)
        XCTAssertEqual(resultsController.fetchedObjects, [product2, product1])
    }

    func testProductResultsControllerInitWithAscendingDateSortOrder() {
        // Arrange
        let product1 = MockProduct().product(siteID: sampleSiteID, productID: 1, dateModified: Date(), name: "fun house")
        storage.insertSampleProduct(readOnlyProduct: product1)

        let product2 = MockProduct().product(siteID: sampleSiteID, productID: 2, dateModified: Date(), name: "zap!")
        storage.insertSampleProduct(readOnlyProduct: product2)

        // Act
        let resultsController = ResultsController<StorageProduct>(viewContext: viewContext,
                                                                  matching: sampleProductsPredicate,
                                                                  sortOrder: .dateAscending)
        try? resultsController.performFetch()

        // Assert
        XCTAssertEqual(resultsController.fetchedObjects.count, 2)
        XCTAssertEqual(resultsController.fetchedObjects, [product1, product2])
    }

    func testProductResultsControllerInitWithDescendingDateSortOrder() {
        // Arrange
        let product1 = MockProduct().product(siteID: sampleSiteID, productID: 1, dateModified: Date(), name: "fun house")
        storage.insertSampleProduct(readOnlyProduct: product1)

        let product2 = MockProduct().product(siteID: sampleSiteID, productID: 2, dateModified: Date(), name: "zap!")
        storage.insertSampleProduct(readOnlyProduct: product2)

        // Act
        let resultsController = ResultsController<StorageProduct>(viewContext: viewContext,
                                                                  matching: sampleProductsPredicate,
                                                                  sortOrder: .dateDescending)
        try? resultsController.performFetch()

        // Assert
        XCTAssertEqual(resultsController.fetchedObjects.count, 2)
        XCTAssertEqual(resultsController.fetchedObjects, [product2, product1])
    }

    // MARK: tests for `updateSortOrder` with a `ProductsSortOrder` param

    func testProductResultsControllerUpdateWithAscendingNameSortOrder() {
        // Arrange
        let product1 = MockProduct().product(siteID: sampleSiteID, productID: 1, name: "fun house")
        storage.insertSampleProduct(readOnlyProduct: product1)

        let product2 = MockProduct().product(siteID: sampleSiteID, productID: 2, name: "woo")
        storage.insertSampleProduct(readOnlyProduct: product2)

        let resultsController = ResultsController<StorageProduct>(viewContext: viewContext,
                                                                  matching: sampleProductsPredicate,
                                                                  sortOrder: .nameDescending)
        try? resultsController.performFetch()

        // Act
        resultsController.updateSortOrder(.nameAscending)
        try? resultsController.performFetch()

        // Assert
        XCTAssertEqual(resultsController.fetchedObjects.count, 2)
        XCTAssertEqual(resultsController.fetchedObjects, [product1, product2])
    }

    func testProductResultsControllerUpdateWithDescendingNameSortOrder() {
        // Arrange
        let product1 = MockProduct().product(siteID: sampleSiteID, productID: 1, name: "Zap")
        storage.insertSampleProduct(readOnlyProduct: product1)

        let product2 = MockProduct().product(siteID: sampleSiteID, productID: 2, name: "fun house")
        storage.insertSampleProduct(readOnlyProduct: product2)

        let resultsController = ResultsController<StorageProduct>(viewContext: viewContext,
                                                                  matching: sampleProductsPredicate,
                                                                  sortOrder: .nameAscending)
        try? resultsController.performFetch()

        // Act
        resultsController.updateSortOrder(.nameDescending)
        try? resultsController.performFetch()

        // Assert
        XCTAssertEqual(resultsController.fetchedObjects.count, 2)
        XCTAssertEqual(resultsController.fetchedObjects, [product1, product2])
    }

    func testProductResultsControllerUpdateWithAscendingDateSortOrder() {
        // Arrange
        let product1 = MockProduct().product(siteID: sampleSiteID, productID: 1, dateModified: Date(), name: "fun house")
        storage.insertSampleProduct(readOnlyProduct: product1)

        let product2 = MockProduct().product(siteID: sampleSiteID, productID: 2, dateModified: Date(), name: "woo")
        storage.insertSampleProduct(readOnlyProduct: product2)

        let resultsController = ResultsController<StorageProduct>(viewContext: viewContext,
                                                                  matching: sampleProductsPredicate,
                                                                  sortOrder: .nameDescending)
        try? resultsController.performFetch()

        // Act
        resultsController.updateSortOrder(.dateAscending)
        try? resultsController.performFetch()

        // Assert
        XCTAssertEqual(resultsController.fetchedObjects.count, 2)
        XCTAssertEqual(resultsController.fetchedObjects, [product1, product2])
    }

    func testProductResultsControllerUpdateWithDescendingDateSortOrder() {
        // Arrange
        let product1 = MockProduct().product(siteID: sampleSiteID, productID: 1, dateModified: Date(), name: "Zap")
        storage.insertSampleProduct(readOnlyProduct: product1)

        let product2 = MockProduct().product(siteID: sampleSiteID, productID: 2, dateModified: Date(), name: "fun house")
        storage.insertSampleProduct(readOnlyProduct: product2)

        let resultsController = ResultsController<StorageProduct>(viewContext: viewContext,
                                                                  matching: sampleProductsPredicate,
                                                                  sortOrder: .nameAscending)
        try? resultsController.performFetch()

        // Act
        resultsController.updateSortOrder(.dateDescending)
        try? resultsController.performFetch()

        // Assert
        XCTAssertEqual(resultsController.fetchedObjects.count, 2)
        XCTAssertEqual(resultsController.fetchedObjects, [product2, product1])
    }
}
