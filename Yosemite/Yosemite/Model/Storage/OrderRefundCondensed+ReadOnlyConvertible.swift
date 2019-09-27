import Foundation
import Storage


// MARK: - Storage.OrderRefundCondensed: ReadOnlyConvertible
//
extension Storage.OrderRefundCondensed: ReadOnlyConvertible {

    /// Updates the Storage.OrderRefundCondensed with the ReadOnly.
    ///
    public func update(with orderRefundCondensed: Yosemite.OrderRefundCondensed) {
        siteID = Int64(orderRefundCondensed.siteID)
        refundID = Int64(orderRefundCondensed.orderID)
        reason = orderRefundCondensed.reason
        total = orderRefundCondensed.total
    }

    /// Returns a ReadOnly version of the receiver.
    ///
    public func toReadOnly() -> Yosemite.Order {
        return OrderRefundCondensed(siteID: Int(siteID),
                                    refundID: Int(refundID),
                                    reason: reason ?? "",
                                    total: total ?? "")
    }
}
