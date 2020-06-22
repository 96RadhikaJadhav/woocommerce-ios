import XCTest

import Storage

@testable import Yosemite

/// Test cases for `RetrieveProductReviewFromNoteUseCase`.
///
final class RetrieveProductReviewFromNoteUseCaseTests: XCTestCase {

    private var storageManager: StorageManagerType!

    private var storage: StorageType {
        storageManager.viewStorage
    }

    private var notificationsRemote: MockNotificationsRemote!
    private var productReviewsRemote: MockProductReviewsRemote!
    private var productsRemote: MockProductsRemote!

    override func setUp() {
        super.setUp()

        storageManager = MockupStorageManager()

        notificationsRemote = MockNotificationsRemote()
        productReviewsRemote = MockProductReviewsRemote()
        productsRemote = MockProductsRemote()

    }

    override func tearDown() {
        productsRemote = nil
        productReviewsRemote = nil
        notificationsRemote = nil

        storageManager = nil

        super.tearDown()
    }

    func testItFetchesAllEntitiesAndReturnsTheParcel() throws {
        // Given
        let useCase = makeUseCase()
        let note = TestData.note
        let productReview = TestData.productReview
        let product = TestData.product

        notificationsRemote.whenLoadingNotes(noteIDs: [note.noteID], thenReturn: .success([note]))
        productReviewsRemote.whenLoadingProductReview(siteID: productReview.siteID,
                                                      reviewID: productReview.reviewID,
                                                      thenReturn: .success(productReview))
        productsRemote.whenLoadingProduct(siteID: product.siteID,
                                          productID: product.productID,
                                          thenReturn: .success(product))

        // When
        let result = try retrieveAndWait(using: useCase, noteID: note.noteID)

        // Then
        XCTAssert(result.isSuccess)

        let parcel = try XCTUnwrap(result.get())
        XCTAssertEqual(parcel.note.noteID, note.noteID)
        XCTAssertEqual(parcel.review, productReview)
        XCTAssertEqual(parcel.product, product)
    }

    func testWhenSuccessfulThenItSavesTheProductReviewToStorage() throws {
        // Given
        let useCase = makeUseCase()
        let note = TestData.note
        let productReview = TestData.productReview
        let product = TestData.product

        notificationsRemote.whenLoadingNotes(noteIDs: [note.noteID], thenReturn: .success([note]))
        productReviewsRemote.whenLoadingProductReview(siteID: productReview.siteID,
                                                      reviewID: productReview.reviewID,
                                                      thenReturn: .success(productReview))
        productsRemote.whenLoadingProduct(siteID: product.siteID,
                                          productID: product.productID,
                                          thenReturn: .success(product))

        XCTAssertEqual(storage.countObjects(ofType: StorageProductReview.self), 0)

        // When
        let result = try retrieveAndWait(using: useCase, noteID: note.noteID)

        // Then
        XCTAssert(result.isSuccess)
        XCTAssertEqual(storage.countObjects(ofType: StorageProductReview.self), 1)

        let reviewFromStorage = storage.loadProductReview(siteID: productReview.siteID, reviewID: productReview.reviewID)
        XCTAssertNotNil(reviewFromStorage)
    }


        // Then
        XCTAssert(result.isSuccess)
        XCTAssertEqual(storage.countObjects(ofType: StorageProductReview.self), 1)

        let reviewFromStorage = storage.loadProductReview(siteID: productReview.siteID, reviewID: productReview.reviewID)
        XCTAssertNotNil(reviewFromStorage)
    }

}

// MARK: - Utils

private extension RetrieveProductReviewFromNoteUseCaseTests {

    /// Create a UseCase using the mocks
    ///
    func makeUseCase() -> RetrieveProductReviewFromNoteUseCase {
        RetrieveProductReviewFromNoteUseCase(derivedStorage: storage,
                                             notificationsRemote: notificationsRemote,
                                             productReviewsRemote: productReviewsRemote,
                                             productsRemote: productsRemote)
    }

    /// Retrieve the Parcel using the given UseCase
    ///
    func retrieveAndWait(using useCase: RetrieveProductReviewFromNoteUseCase,
                         noteID: Int64) throws -> Result<ProductReviewFromNoteParcel, Error> {
        var result: Result<ProductReviewFromNoteParcel, Error>?

        waitForExpectation { exp in
            useCase.retrieve(noteID: noteID) { aResult in
                print(aResult)
                result = aResult
                exp.fulfill()
            }
        }

        return try XCTUnwrap(result)
    }
}

// MARK: - Test Data

private extension RetrieveProductReviewFromNoteUseCaseTests {
    enum TestData {
        static let siteID: Int64 = 398
        static let product = MockProduct().product(siteID: siteID, productID: 756_611)
        static let productReview = MockProductReview().make(siteID: siteID, reviewID: 1_981_157, productID: product.productID)
        static let note = MockNote().make(noteID: 9_981, metaSiteID: siteID, metaReviewID: productReview.reviewID)
    }
}
