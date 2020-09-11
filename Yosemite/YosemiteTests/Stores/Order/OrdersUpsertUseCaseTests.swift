import XCTest

import Storage
import Networking

@testable import Yosemite

final class OrdersUpsertUseCaseTests: XCTestCase {

    private var storageManager: StorageManagerType!
    private var viewStorage: StorageType {
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

    func test_it_inserts_orders_with_permanent_ids() throws {
        // Given
        let orders = [makeOrder(), makeOrder()]
        let useCase = OrdersUpsertUseCase(storage: viewStorage)

        // When
        let storageOrders = useCase.upsert(orders)

        // Then
        XCTAssertEqual(storageOrders.count, 2)
        storageOrders.forEach { storageOrder in
            XCTAssertFalse(storageOrder.objectID.isTemporaryID)
        }
    }
}

private extension OrdersUpsertUseCaseTests {
    func makeOrder() -> Networking.Order {
        Order(siteID: 0,
              orderID: 0,
              parentID: 0,
              customerID: 0,
              number: "",
              statusKey: "",
              currency: "",
              customerNote: nil,
              dateCreated: Date(),
              dateModified: Date(),
              datePaid: nil,
              discountTotal: "",
              discountTax: "",
              shippingTotal: "",
              shippingTax: "",
              total: "",
              totalTax: "",
              paymentMethodTitle: "",
              items: [],
              billingAddress: nil,
              shippingAddress: nil,
              shippingLines: [],
              coupons: [],
              refunds: [])
    }
}
