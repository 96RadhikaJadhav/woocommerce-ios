import Foundation
import Yosemite

/// Generates mock refund and refund items
///
public struct MockRefunds {
    public static func sampleRefund(refundID: Int64 = 0,
                                    orderID: Int64 = 0,
                                    siteID: Int64 = 0,
                                    dateCreated: Date = Date(),
                                    amount: String = "0.0",
                                    reason: String = "",
                                    refundedByUserID: Int64 = 0,
                                    isAutomated: Bool? = nil,
                                    createAutomated: Bool? = nil,
                                    items: [OrderItemRefund] = [sampleRefundItem()]) -> Refund {
        return Refund(refundID: refundID,
                      orderID: orderID,
                      siteID: siteID,
                      dateCreated: dateCreated,
                      amount: amount,
                      reason: reason,
                      refundedByUserID: refundedByUserID,
                      isAutomated: isAutomated,
                      createAutomated: createAutomated,
                      items: items,
                      shippingLines: [])
    }

    public static func sampleRefundItem(itemID: Int64 = 0,
                                        name: String = "",
                                        productID: Int64 = 0,
                                        variationID: Int64 = 0,
                                        quantity: Decimal = 0,
                                        price: NSDecimalNumber = 0,
                                        sku: String? = nil,
                                        subtotal: String = "0.0",
                                        subtotalTax: String = "0.0",
                                        taxClass: String = "",
                                        taxes: [OrderItemTaxRefund] = [],
                                        total: String = "0.0",
                                        totalTax: String = "0.0") -> OrderItemRefund {
        return OrderItemRefund(itemID: itemID,
                               name: name,
                               productID: productID,
                               variationID: variationID,
                               quantity: quantity,
                               price: price,
                               sku: sku,
                               subtotal: subtotal,
                               subtotalTax: subtotalTax,
                               taxClass: taxClass,
                               taxes: taxes,
                               total: total,
                               totalTax: totalTax)
    }
}
