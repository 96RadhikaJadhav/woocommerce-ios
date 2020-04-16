
import Foundation
import XCTest
@testable import WooCommerce
import Yosemite
import Storage

private typealias SyncReason = OrdersViewModel.SyncReason
private typealias Defaults = OrdersViewModel.Defaults

/// Tests for `OrdersViewModel`.
///
final class OrdersViewModelTests: XCTestCase {
    /// The `siteID` value doesn't matter.
    private let siteID: Int64 = 1_000_000
    private let pageSize = 50

    private let unimportantCompletionHandler: ((Error?) -> Void) = { _ in
        // noop
    }

    private var storageManager: StorageManagerType!

    private var storage: StorageType {
        storageManager.viewStorage
    }

    override func setUp() {
        super.setUp()
        storageManager = MockupStorageManager()
    }

    override func tearDown() {
        storageManager = nil
        super.tearDown()
    }

    // Test that when pulling to refresh on a filtered list (e.g. Processing tab), the action
    // returned will be for:
    //
    // 1. deleting all orders
    // 2. fetching both the filtered list and the "all orders" list
    //
    func testPullingToRefreshOnFilteredListItDeletesAndPerformsDualFetch() {
        // Arrange
        let viewModel = OrdersViewModel(statusFilter: orderStatus(with: .processing))

        // Act
        let action = viewModel.synchronizationAction(
            siteID: siteID,
            pageNumber: Defaults.pageFirstIndex,
            pageSize: pageSize,
            reason: SyncReason.pullToRefresh,
            completionHandler: unimportantCompletionHandler)

        // Assert
        guard case .fetchFilteredAndAllOrders(_, let statusKey, let deleteAllBeforeSaving, _, _) = action else {
            XCTFail("Unexpected OrderAction type: \(action)")
            return
        }

        XCTAssertTrue(deleteAllBeforeSaving)
        XCTAssertEqual(statusKey, OrderStatusEnum.processing.rawValue)
    }

    // Test that when fetching the first page of a filtered list (e.g. Processing) for reasons
    // other than pull-to-refresh (e.g. `viewWillAppear`), the action returned will only be for
    // dual fetching of the filtered list and the all orders list.
    //
    func testFirstPageLoadOnFilteredListWithNonPullToRefreshReasonsWillOnlyPerformDualFetch() {
        // Arrange
        let viewModel = OrdersViewModel(statusFilter: orderStatus(with: .processing))

        // Act
        let action = viewModel.synchronizationAction(
            siteID: siteID,
            pageNumber: Defaults.pageFirstIndex,
            pageSize: pageSize,
            reason: nil,
            completionHandler: unimportantCompletionHandler)

        // Assert
        guard case .fetchFilteredAndAllOrders(_, let statusKey, let deleteAllBeforeSaving, _, _) = action else {
            XCTFail("Unexpected OrderAction type: \(action)")
            return
        }

        XCTAssertFalse(deleteAllBeforeSaving)
        XCTAssertEqual(statusKey, OrderStatusEnum.processing.rawValue)
    }

    // Test that when pulling to refresh on the All Orders tab, the action returned will be for:
    //
    // 1. Deleting all the orders
    // 2. Fetching the first page of all orders (any status)
    //
    func testPullingToRefreshOnAllOrdersListDeletesAndFetchesFirstPageOfAllOrdersOnly() {
        // Arrange
        let viewModel = OrdersViewModel(statusFilter: nil)

        // Act
        let action = viewModel.synchronizationAction(
            siteID: siteID,
            pageNumber: Defaults.pageFirstIndex,
            pageSize: pageSize,
            reason: SyncReason.pullToRefresh,
            completionHandler: unimportantCompletionHandler)

        // Assert
        guard case .fetchFilteredAndAllOrders(_, let statusKey, let deleteAllBeforeSaving, _, _) = action else {
            XCTFail("Unexpected OrderAction type: \(action)")
            return
        }

        XCTAssertTrue(deleteAllBeforeSaving)
        XCTAssertNil(statusKey, "No filtered list will be fetched.")
    }

    // Test that when fetching the first page of the All Orders list for reasons other than
    // pull-to-refresh (e.g. `viewWillAppear`), the action returned will only be for fetching the
    // all the orders (any status).
    //
    func testFirstPageLoadOnAllOrdersListWithNonPullToRefreshReasonsWillOnlyPerformSingleFetch() {
        // Arrange
        let viewModel = OrdersViewModel(statusFilter: nil)

        // Act
        let action = viewModel.synchronizationAction(
            siteID: siteID,
            pageNumber: Defaults.pageFirstIndex,
            pageSize: pageSize,
            reason: nil,
            completionHandler: unimportantCompletionHandler)

        // Assert
        guard case .fetchFilteredAndAllOrders(_, let statusKey, let deleteAllBeforeSaving, _, _) = action else {
            XCTFail("Unexpected OrderAction type: \(action)")
            return
        }

        XCTAssertFalse(deleteAllBeforeSaving)
        XCTAssertNil(statusKey, "No filtered list will be fetched.")
    }

    func testSubsequentPageLoadsOnFilteredListWillFetchTheGivenPageOnThatList() {
        // Arrange
        let viewModel = OrdersViewModel(statusFilter: orderStatus(with: .pending))

        // Act
        let action = viewModel.synchronizationAction(
            siteID: siteID,
            pageNumber: Defaults.pageFirstIndex + 3,
            pageSize: pageSize,
            reason: nil,
            completionHandler: unimportantCompletionHandler)

        // Assert
        guard case .synchronizeOrders(_, let statusKey, let pageNumber, let pageSize, _) = action else {
            XCTFail("Unexpected OrderAction type: \(action)")
            return
        }

        XCTAssertEqual(statusKey, OrderStatusEnum.pending.rawValue)
        XCTAssertEqual(pageNumber, Defaults.pageFirstIndex + 3)
        XCTAssertEqual(pageSize, self.pageSize)
    }

    func testSubsequentPageLoadsOnAllOrdersListWillFetchTheGivenPageOnThatList() {
        // Arrange
        let viewModel = OrdersViewModel(statusFilter: nil)

        // Act
        let action = viewModel.synchronizationAction(
            siteID: siteID,
            pageNumber: Defaults.pageFirstIndex + 5,
            pageSize: pageSize,
            reason: nil,
            completionHandler: unimportantCompletionHandler)

        // Assert
        guard case .synchronizeOrders(_, let statusKey, let pageNumber, let pageSize, _) = action else {
            XCTFail("Unexpected OrderAction type: \(action)")
            return
        }

        XCTAssertNil(statusKey)
        XCTAssertEqual(pageNumber, Defaults.pageFirstIndex + 5)
        XCTAssertEqual(pageSize, self.pageSize)
    }

    func testGivenAFilterItLoadsTheOrdersMatchingThatFilterFromTheDB() {
        // Arrange
        let viewModel = OrdersViewModel(storageManager: storageManager,
                                        statusFilter: orderStatus(with: .processing))

        let processingOrders = (0..<10).map { insertOrder(id: $0, status: .processing) }
        let completedOrders = (100..<105).map { insertOrder(id: $0, status: .completed) }

        XCTAssertEqual(storage.countObjects(ofType: StorageOrder.self), processingOrders.count + completedOrders.count)

        // Act
        viewModel.activateAndForwardUpdates(to: UITableView())

        // Assert
        XCTAssertTrue(viewModel.isFiltered)
        XCTAssertFalse(viewModel.isEmpty)
        XCTAssertEqual(viewModel.numberOfObjects, processingOrders.count)

        let processingOrderIDs = Set(processingOrders.map { $0.orderID })
        XCTAssertEqual(viewModel.fetchedOrderIDs, processingOrderIDs)
    }

    func testGivenNoFilterItLoadsAllTheTodayAndPastOrdersFromTheDB() {
        // Arrange
        let viewModel = OrdersViewModel(storageManager: storageManager, statusFilter: nil)

        let allInsertedOrders = [
            (0..<10).map { insertOrder(id: $0, status: .processing) },
            (100..<105).map { insertOrder(id: $0, status: .completed, dateCreated: Date().adding(days: -2)!) },
            (200..<203).map { insertOrder(id: $0, status: .pending) },
        ].flatMap { $0 }

        XCTAssertEqual(storage.countObjects(ofType: StorageOrder.self), allInsertedOrders.count)

        // Act
        viewModel.activateAndForwardUpdates(to: UITableView())

        // Assert
        XCTAssertFalse(viewModel.isFiltered)
        XCTAssertFalse(viewModel.isEmpty)
        XCTAssertEqual(viewModel.numberOfObjects, allInsertedOrders.count)

        let allInsertedOrderIDs = Set(allInsertedOrders.map { $0.orderID })
        XCTAssertEqual(viewModel.fetchedOrderIDs, allInsertedOrderIDs)
    }

    func testGivenAProcessingFilterItAlsoLoadsFutureOrdersFromTheDB() {
        // Arrange
        let viewModel = OrdersViewModel(storageManager: storageManager, statusFilter: orderStatus(with: .processing))

        let expectedFutureOrders = [
            insertOrder(id: 1_000, status: .processing, dateCreated: Date().adding(days: 1)!),
            insertOrder(id: 1_001, status: .processing, dateCreated: Date().adding(days: 2)!),
            insertOrder(id: 1_002, status: .processing, dateCreated: Date().adding(days: 3)!),
        ]

        // This should be ignored because it is not .processing
        let ignoredFutureOrder = insertOrder(id: 2_000, status: .cancelled, dateCreated: Date().adding(days: 1)!)

        let expectedPastOrders = [
            insertOrder(id: 4_000, status: .processing, dateCreated: Date().adding(days: -1)!),
            insertOrder(id: 4_001, status: .processing, dateCreated: Date().adding(days: -20)!),
        ]

        // Act
        viewModel.activateAndForwardUpdates(to: UITableView())

        // Assert
        XCTAssertEqual(viewModel.numberOfObjects, expectedFutureOrders.count + expectedPastOrders.count)
        XCTAssertFalse(viewModel.fetchedOrderIDs.contains(ignoredFutureOrder.orderID))

        let expectedOrderIDs = Set((expectedPastOrders + expectedFutureOrders).map(\.orderID))
        XCTAssertEqual(viewModel.fetchedOrderIDs, expectedOrderIDs)
    }

}

// MARK: - Helpers

private extension OrdersViewModel {
    /// Returns the Order instances for all the rows
    ///
    var fetchedOrders: [Yosemite.Order] {
        (0..<numberOfSections).flatMap { section in
            (0..<numberOfRows(in: section)).map { row in
                detailsViewModel(at: IndexPath(row: row, section: section)).order
            }
        }
    }

    /// Returns the IDs for all the Order rows
    ///
    var fetchedOrderIDs: Set<Int64> {
        Set(fetchedOrders.map(\.orderID))
    }
}

// MARK: - Builders

private extension OrdersViewModelTests {
    func orderStatus(with status: OrderStatusEnum) -> Yosemite.OrderStatus {
        OrderStatus(name: nil, siteID: siteID, slug: status.rawValue, total: 0)
    }

    func insertOrder(id orderID: Int64,
                     status: OrderStatusEnum,
                     dateCreated: Date = Date()) -> Yosemite.Order {
        let readonlyOrder = Order(siteID: siteID,
                                  orderID: orderID,
                                  parentID: 0,
                                  customerID: 11,
                                  number: "963",
                                  statusKey: status.rawValue,
                                  currency: "USD",
                                  customerNote: "",
                                  dateCreated: dateCreated,
                                  dateModified: Date(),
                                  datePaid: nil,
                                  discountTotal: "30.00",
                                  discountTax: "1.20",
                                  shippingTotal: "0.00",
                                  shippingTax: "0.00",
                                  total: "31.20",
                                  totalTax: "1.20",
                                  paymentMethodTitle: "Credit Card (Stripe)",
                                  items: [],
                                  billingAddress: nil,
                                  shippingAddress: nil,
                                  shippingLines: [],
                                  coupons: [],
                                  refunds: [])

        let storageOrder = storage.insertNewObject(ofType: StorageOrder.self)
        storageOrder.update(with: readonlyOrder)

        return readonlyOrder
    }
}
