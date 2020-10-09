import XCTest

@testable import Yosemite

/// Tests cases for the Order+Refunds extension methods.
final class Order_RefundsTests: XCTestCase {

    func test_totalRefunded_returns_zero_if_there_are_no_refunds() {
        // Given
        let currencyFormatter = CurrencyFormatter(currencySettings: CurrencySettings())
        let order = MockOrder().empty()

        // When
        let totalRefunded = order.totalRefunded(using: currencyFormatter)

        // Then
        XCTAssertEqual(totalRefunded, .zero)
    }

    func test_totalRefunded_returns_the_sum_from_all_the_refund_items() {
        // Given
        let locale = Locale(identifier: "en_US")
        let currencySettings = CurrencySettings(currencyCode: .USD,
                                                currencyPosition: .left,
                                                thousandSeparator: ",",
                                                decimalSeparator: ".",
                                                numberOfDecimals: 8)
        let currencyFormatter = CurrencyFormatter(currencySettings: currencySettings)

        let refundItems = [
            OrderRefundCondensed(refundID: 0, reason: nil, total: "-1.6719"),
            OrderRefundCondensed(refundID: 0, reason: nil, total: "-78.56"),
            OrderRefundCondensed(refundID: 0, reason: nil, total: "-67"),
            OrderRefundCondensed(refundID: 0, reason: nil, total: "-881.0000"),
            OrderRefundCondensed(refundID: 0, reason: nil, total: "-46110.871"),
            // Values with currency are probably not possible in the API but we're
            // considering it here for resilience.
            OrderRefundCondensed(refundID: 0, reason: nil, total: "$-8.71972"),
            // The API returns negative numbers. We're including a positive number to indicate
            // that we don't do special handling of the sign.
            OrderRefundCondensed(refundID: 0, reason: nil, total: "3719.8850971"),
        ]
        let order = MockOrder().empty().copy(refunds: refundItems)

        // When
        let totalRefunded = order.totalRefunded(using: currencyFormatter, locale: locale)

        // Then
        XCTAssertEqual(totalRefunded, NSDecimalNumber(string: "-43427.9375229"))
    }
}
