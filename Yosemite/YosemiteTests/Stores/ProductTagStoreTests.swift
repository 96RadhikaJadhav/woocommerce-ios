import XCTest
@testable import Yosemite
@testable import Storage
@testable import Networking


/// ProductTagStore Unit Tests
///
final class ProductTagStoreTests: XCTestCase {
    /// Mockup Network: Allows us to inject predefined responses!
    ///
    private var network: MockupNetwork!

    /// Mockup Storage: InMemory
    ///
    private var storageManager: MockupStorageManager!

    /// Convenience Property: Returns the StorageType associated with the main thread.
    ///
    private var viewStorage: StorageType {
        return storageManager.viewStorage
    }

    /// Convenience Property: Returns stored product tags count.
    ///
    private var storedProductTagsCount: Int {
        return viewStorage.countObjects(ofType: Storage.ProductTag.self)
    }

    /// Store
    ///
    private var store: ProductTagStore!

    /// Testing SiteID
    ///
    private let sampleSiteID: Int64 = 123

    /// Testing Page Number
    ///
    private let defaultPageNumber = 1

    // MARK: - Overridden Methods

    override func setUp() {
        super.setUp()
        network = MockupNetwork(useResponseQueue: true)
        storageManager = MockupStorageManager()
        store = ProductTagStore(dispatcher: Dispatcher(),
                                     storageManager: storageManager,
                                     network: network)
    }

    override func tearDown() {
        store = nil
        network = nil
        storageManager = nil

        super.tearDown()
    }

    func testSynchronizeProductTagsReturnsTagsUponSuccessfulResponse() throws {
        // Given a stubed product-tags network response
        network.simulateResponse(requestUrlSuffix: "products/tags", filename: "product-tags-all")
        network.simulateResponse(requestUrlSuffix: "products/tags", filename: "product-tags-empty")
        XCTAssertEqual(storedProductTagsCount, 0)

        // When dispatching a `synchronizeAllProductTags` action
        var errorResponse: ProductTagActionError?
        waitForExpectation { (exp) in
            let action = ProductTagAction.synchronizeAllProductTags(siteID: sampleSiteID, fromPageNumber: defaultPageNumber) { error in
                errorResponse = error
                exp.fulfill()
            }
            store.onAction(action)
        }

        // Then a valid set of tags should be stored
        XCTAssertEqual(storedProductTagsCount, 4)
        XCTAssertNil(errorResponse)
    }

    func testSynchronizeProductTagsReturnsTagsUponPaginatedResponse() throws {
        // Given a stubed product-tags network response
        network.simulateResponse(requestUrlSuffix: "products/tags", filename: "product-tags-all")
        network.simulateResponse(requestUrlSuffix: "products/tags", filename: "product-tags-extra")
        network.simulateResponse(requestUrlSuffix: "products/tags", filename: "product-tags-empty")
        XCTAssertEqual(storedProductTagsCount, 0)

        // When dispatching a `synchronizeAllProductTags` action
        var errorResponse: ProductTagActionError?
        waitForExpectation { (exp) in
            let action = ProductTagAction.synchronizeAllProductTags(siteID: sampleSiteID, fromPageNumber: defaultPageNumber) { error in
                errorResponse = error
                exp.fulfill()
            }
            store.onAction(action)
        }

        // Then the combined set of tags should be stored
        XCTAssertEqual(storedProductTagsCount, 4)
        XCTAssertNil(errorResponse)
    }

    func testSynchronizeProductTagsUpdatesStoredTagsSuccessfulResponse() {
        // Given an initial stored tag and a stubed product-tags network response
        let initialTag = sampletag(tagID: 20)
        storageManager.insertSampleProductTag(readOnlyProductTag: initialTag)
        network.simulateResponse(requestUrlSuffix: "products/tags", filename: "product-tags-all")
        network.simulateResponse(requestUrlSuffix: "products/tags", filename: "product-tags-empty")

        // When dispatching a `synchronizeAllProductTags` action
        var errorResponse: ProductTagActionError?
        waitForExpectation { (exp) in
            let action = ProductTagAction.synchronizeAllProductTags(siteID: sampleSiteID, fromPageNumber: defaultPageNumber) { error in
                errorResponse = error
                exp.fulfill()
            }
            store.onAction(action)
        }

        // Then the initial tag should have it's values updated
        let updatedTag = viewStorage.loadProductTag(siteID: sampleSiteID, tagID: initialTag.tagID)
        XCTAssertNotEqual(initialTag.tagID, updatedTag?.tagID)
        XCTAssertNotEqual(initialTag.name, updatedTag?.name)
        XCTAssertNotEqual(initialTag.slug, updatedTag?.slug)
        XCTAssertNil(errorResponse)
    }
//
//    func testSynchronizeProductCategoriesReturnsErrorUponPaginatedReponseError() {
//        // Given a stubed first page category response and second page generic-error network response
//        let expectation = self.expectation(description: #function)
//        network.simulateResponse(requestUrlSuffix: "products/categories", filename: "categories-all")
//        network.simulateResponse(requestUrlSuffix: "products/categories", filename: "generic_error")
//        XCTAssertEqual(storedProductCategoriesCount, 0)
//
//        // When dispatching a `synchronizeProductCategories` action
//        var errorResponse: ProductCategoryActionError?
//        let action = ProductCategoryAction.synchronizeProductCategories(siteID: sampleSiteID, fromPageNumber: defaultPageNumber) { error in
//            errorResponse = error
//            expectation.fulfill()
//        }
//        store.onAction(action)
//        waitForExpectations(timeout: Constants.expectationTimeout, handler: nil)
//
//        // Then first page of categories should be stored
//        XCTAssertEqual(storedProductCategoriesCount, 2)
//
//        // And error should contain correct fromPageNumber
//        switch errorResponse {
//        case let .categoriesSynchronization(pageNumber, _):
//            XCTAssertEqual(pageNumber, 2)
//        case .none:
//            XCTFail("errorResponse should not be nil")
//        }
//    }
//
//    func testSynchronizeProductCategoriesReturnsErrorUponReponseError() {
//        // Given a stubed generic-error network response
//        let expectation = self.expectation(description: #function)
//        network.simulateResponse(requestUrlSuffix: "products/categories", filename: "generic_error")
//        XCTAssertEqual(storedProductCategoriesCount, 0)
//
//        // When dispatching a `synchronizeProductCategories` action
//        var errorResponse: ProductCategoryActionError?
//        let action = ProductCategoryAction.synchronizeProductCategories(siteID: sampleSiteID, fromPageNumber: defaultPageNumber) { error in
//            errorResponse = error
//            expectation.fulfill()
//        }
//        store.onAction(action)
//        waitForExpectations(timeout: Constants.expectationTimeout, handler: nil)
//
//        // Then no categories should be stored
//        XCTAssertEqual(storedProductCategoriesCount, 0)
//        XCTAssertNotNil(errorResponse)
//    }
//
//    func testSynchronizeProductCategoriesReturnsErrorUponEmptyResponse() {
//        // Given a an empty network response
//        let expectation = self.expectation(description: #function)
//        XCTAssertEqual(storedProductCategoriesCount, 0)
//
//        // When dispatching a `synchronizeProductCategories` action
//        var errorResponse: ProductCategoryActionError?
//        let action = ProductCategoryAction.synchronizeProductCategories(siteID: sampleSiteID, fromPageNumber: defaultPageNumber) { error in
//            errorResponse = error
//            expectation.fulfill()
//        }
//        store.onAction(action)
//        waitForExpectations(timeout: Constants.expectationTimeout, handler: nil)
//
//        // Then no categories should be stored
//        XCTAssertEqual(storedProductCategoriesCount, 0)
//        XCTAssertNotNil(errorResponse)
//    }
//
//    func testAddProductCategoryAddsStoredCategorySuccessfulResponse() {
//        // Given a stubed product category network response
//        network.simulateResponse(requestUrlSuffix: "products/categories", filename: "category")
//
//        // When dispatching a `addProductCategory` action
//        var result: Result<Networking.ProductCategory, Error>?
//        waitForExpectation { (exp) in
//            let action = ProductCategoryAction.addProductCategory(siteID: sampleSiteID, name: "Dress", parentID: 0) { aResult in
//                result = aResult
//                exp.fulfill()
//            }
//            store.onAction(action)
//        }
//
//
//        // Then the category should be added
//        let addedCategory = viewStorage.loadProductCategory(siteID: sampleSiteID, categoryID: 104)
//        XCTAssertNotNil(addedCategory)
//        XCTAssertEqual(addedCategory?.categoryID, 104)
//        XCTAssertEqual(addedCategory?.parentID, 0)
//        XCTAssertEqual(addedCategory?.siteID, sampleSiteID)
//        XCTAssertEqual(addedCategory?.name, "Dress")
//        XCTAssertEqual(addedCategory?.slug, "Shirt")
//        XCTAssertNil(result?.failure)
//    }
//
//    func testAddProductCategoryReturnsErrorUponReponseError() {
//        // Given a stubed generic-error network response
//        network.simulateResponse(requestUrlSuffix: "products/categories", filename: "generic_error")
//        XCTAssertEqual(storedProductCategoriesCount, 0)
//
//        // When dispatching a `addProductCategory` action
//        var result: Result<Networking.ProductCategory, Error>?
//        waitForExpectation { (exp) in
//            let action = ProductCategoryAction.addProductCategory(siteID: sampleSiteID, name: "Dress", parentID: 0) { aResult in
//                result = aResult
//                exp.fulfill()
//            }
//            store.onAction(action)
//        }
//
//
//        // Then no categories should be stored
//        XCTAssertEqual(storedProductCategoriesCount, 0)
//        XCTAssertNotNil(result?.failure)
//    }
//
//    func testAddProductCategoryReturnsErrorUponEmptyResponse() {
//        // Given a an empty network response
//        XCTAssertEqual(storedProductCategoriesCount, 0)
//
//        // When dispatching a `addProductCategory` action
//        var result: Result<Networking.ProductCategory, Error>?
//        waitForExpectation { (exp) in
//            let action = ProductCategoryAction.addProductCategory(siteID: sampleSiteID, name: "Dress", parentID: 0) { aResult in
//                result = aResult
//                exp.fulfill()
//            }
//            store.onAction(action)
//        }
//
//        // Then no categories should be stored
//        XCTAssertEqual(storedProductCategoriesCount, 0)
//        XCTAssertNotNil(result?.failure)
//    }
//
//    func testSynchronizeProductCategoriesDeletesUnusedCategories() {
//        // Given some stored product categories without product relationships
//        let expectation = self.expectation(description: #function)
//        let sampleCategories = (1...5).map { id in
//            return sampleCategory(categoryID: id)
//        }
//        sampleCategories.forEach { category in
//            storageManager.insertSampleProductCategory(readOnlyProductCategory: category)
//        }
//        XCTAssertEqual(storedProductCategoriesCount, sampleCategories.count)
//
//        // When dispatching a `synchronizeProductCategories` action
//        network.simulateResponse(requestUrlSuffix: "products/categories", filename: "categories-all")
//        network.simulateResponse(requestUrlSuffix: "products/categories", filename: "categories-empty")
//        let action = ProductCategoryAction.synchronizeProductCategories(siteID: sampleSiteID, fromPageNumber: defaultPageNumber) { _ in
//            expectation.fulfill()
//        }
//        store.onAction(action)
//        waitForExpectations(timeout: Constants.expectationTimeout, handler: nil)
//
//        // Then new categories should be stored and old categories should be deleted
//        XCTAssertEqual(storedProductCategoriesCount, 2)
//    }
}

private extension ProductTagStoreTests {
    func sampletag(tagID: Int64) -> Networking.ProductTag {
        return Networking.ProductTag(siteID: sampleSiteID, tagID: tagID, name: "Sample", slug: "sample")
    }
}
