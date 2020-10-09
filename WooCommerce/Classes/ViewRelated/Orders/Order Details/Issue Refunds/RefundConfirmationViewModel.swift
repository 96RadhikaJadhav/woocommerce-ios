import Foundation
import Yosemite

/// ViewModel for presenting refund confirmation to the user.
///
final class RefundConfirmationViewModel {

    /// This will be computed later :D
    let refundAmount = "$87.50"

    private let order: Order
    private let currencyFormatter: CurrencyFormatter

    /// The sections and rows to display in the `UITableView`.
    lazy private(set) var sections: [Section] = [
        Section(
            title: nil,
            rows: [
                makePreviouslyRefundedRow(),
                TwoColumnRow(title: Localization.refundAmount, value: refundAmount, isHeadline: true),
                TitleAndEditableValueRow(title: Localization.reasonForRefund,
                                         placeholder: Localization.reasonForRefundingOrder),
            ]
        ),
        Section(
            title: Localization.refundVia,
            rows: [
                TitleAndBodyRow(title: Localization.manualRefund(via: "Stripe"),
                                body: Localization.refundWillNotBeIssued(paymentMethod: "Stripe"))
            ]
        )
    ]

    init(order: Order, currencySettings: CurrencySettings = ServiceLocator.currencySettings) {
        self.order = order
        self.currencyFormatter = CurrencyFormatter(currencySettings: currencySettings)
    }
}

// MARK: - Builders

private extension RefundConfirmationViewModel {
    func makePreviouslyRefundedRow() -> TwoColumnRow {
        let totalRefunded = order.totalRefunded(using: currencyFormatter).abs()
        let totalRefundedFormatted = currencyFormatter.formatAmount(totalRefunded) ?? ""
        return TwoColumnRow(title: Localization.previouslyRefunded, value: totalRefundedFormatted, isHeadline: false)
    }
}

// MARK: - Section and Row Types

/// A base protocol for the row types used by `RefundConfirmationViewModel`.
protocol RefundConfirmationViewModelRow {

}

extension RefundConfirmationViewModel {
    struct Section {
        let title: String?
        let rows: [RefundConfirmationViewModelRow]
    }

    /// A row that shows a title on the left and a value on the right.
    struct TwoColumnRow: RefundConfirmationViewModelRow {
        let title: String
        let value: String
        /// Indicates the style to use. If true, the view should use an emphasized (bold) style.
        let isHeadline: Bool
    }

    /// A row that shows a title and a text field below it.
    struct TitleAndEditableValueRow: RefundConfirmationViewModelRow {
        let title: String
        let placeholder: String
    }

    /// A row that shows a title and a paragraph (label) below it.
    struct TitleAndBodyRow: RefundConfirmationViewModelRow {
        let title: String
        let body: String?
    }
}

// MARK: - Localization

private extension RefundConfirmationViewModel {
    enum Localization {
        static let previouslyRefunded = NSLocalizedString("Previously Refunded",
                                                          comment: "A label representing the amount that was previously refunded for the order.")
        static let refundAmount =
            NSLocalizedString("Refund Amount",
                              comment: "A label representing the amount that will be refunded if the user confirms to proceed with the refund.")
        static let refundVia = NSLocalizedString("Refund Via",
                                                 comment: "The title of the section containing information about how the refund will be processed.")
        static let reasonForRefund =
            NSLocalizedString("Reason for Refund (Optional)",
                              comment: "A label for the text field that the user can edit to indicate why they are issuing a refund.")
        static let reasonForRefundingOrder =
            NSLocalizedString("Reason for refunding order",
                              comment: "A placeholder for the text field that the user can edit to indicate why they are issuing a refund.")

        static func manualRefund(via paymentMethod: String) -> String {
            let format = NSLocalizedString(
                     "Manual Refund via %1$@",
                comment: "In Refund Confirmation, The title shown to the user to inform them that"
                    + " they have to issue the refund manually."
                    + " The %1$@ is the payment method like “Stripe”.")
            return String.localizedStringWithFormat(format, paymentMethod)
        }

        static func refundWillNotBeIssued(paymentMethod: String) -> String {
            let format = NSLocalizedString(
                "A refund will not be issued to the customer."
                    + " You will need to manually issue the refund through %1$@.",
                comment: "In Refund Confirmation, The message shown to the user to inform them that"
                    + " they have to issue the refund manually."
                    + " The %1$@ is the payment method like “Stripe”.")
            return String.localizedStringWithFormat(format, paymentMethod)
        }
    }
}
