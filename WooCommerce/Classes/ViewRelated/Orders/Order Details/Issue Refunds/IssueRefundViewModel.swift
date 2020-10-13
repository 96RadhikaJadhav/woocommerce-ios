import Foundation
import Yosemite

/// ViewModel for presenting the issue refund screen to the user.
///
final class IssueRefundViewModel {

    /// Struct to hold the necessary state to perform the refund and update the view model
    ///
    private struct State {
        /// Order to be refunded
        ///
        let order: Order

        /// Current currency settings
        ///
        let currencySettings: CurrencySettings

        /// Bool indicating if shipping will be refunded
        ///
        var shouldRefundShipping: Bool = false

        ///  Holds the quantity of items to refund
        ///
        var refundQuantityStore = RefundQuantityStore()
    }

    /// Current ViewModel state
    ///
    private var state: State {
        didSet {
            sections = createSections()
            title = calculateTitle()
            onChange?()
        }
    }

    /// Closured to notify the `ViewController` when the view model properties change
    ///
    var onChange: (() -> (Void))?

    /// Title for the navigation bar
    ///
    private(set) var title: String = ""

    /// String indicating how many items the user has selected to refund
    /// This is temporary data, will be removed after implementing https://github.com/woocommerce/woocommerce-ios/issues/2842
    ///
    let selectedItemsTitle: String = "0 items selected"

    /// The sections and rows to display in the `UITableView`.
    ///
    private(set) var sections: [Section] = []

    /// Products related to this order. Needed to build `RefundItemViewModel` rows
    ///
    private lazy var products: [Product] = {
        let resultsController = createProductsResultsController()
        try? resultsController.performFetch()
        return resultsController.fetchedObjects
    }()

    init(order: Order, currencySettings: CurrencySettings) {
        state = State(order: order, currencySettings: currencySettings)
        sections = createSections()
        title = calculateTitle()
    }
}

// MARK: User Actions
extension IssueRefundViewModel {
    /// Toggles the refund shipping state
    ///
    func toggleRefundShipping() {
        state.shouldRefundShipping.toggle()
    }

    /// Returns the number of items available for refund for the provided item index.
    /// Returns `nil` if the index is out of bounds
    ///
    func quantityAvailableForRefundForItemAtIndex(_ itemIndex: Int) -> Int? {
        guard let item = state.order.items[safe: itemIndex] else {
            return nil
        }
        return Int(truncating: item.quantity as NSDecimalNumber)
    }

    /// Returns the current quantlty set for refund for the provided item index.
    /// Returns `nil` if the index is out of bounds.
    ///
    func currentQuantityForItemAtIndex(_ itemIndex: Int) -> Int? {
        guard let item = state.order.items[safe: itemIndex] else {
            return nil
        }
        return state.refundQuantityStore.refundQuantity(for: item)
    }

    /// Updates the quantity to be refunded for an item on the provided index.
    ///
    func updateRefundQuantity(quantity: Int, forItemAtIndex itemIndex: Int) {
        guard let item = state.order.items[safe: itemIndex] else {
            return
        }
        state.refundQuantityStore.update(quantity: quantity, for: item)
    }
}

// MARK: Results Controller
private extension IssueRefundViewModel {

    /// Results controller that fetches the products related to this order
    ///
    func createProductsResultsController() -> ResultsController<StorageProduct> {
        let itemsIDs = state.order.items.map { $0.productID }
        let predicate = NSPredicate(format: "siteID == %lld AND productID IN %@", state.order.siteID, itemsIDs)
        return ResultsController<StorageProduct>(storageManager: ServiceLocator.storageManager, matching: predicate, sortedBy: [])
    }
}

// MARK: Constants
private extension IssueRefundViewModel {
    enum Localization {
        static let refundShippingTitle = NSLocalizedString("Refund Shipping", comment: "Title of the switch in the IssueRefund screen to refund shipping")
    }
}

// MARK: Sections and Rows

/// Protocol that any `Section` item  should conform to.
///
protocol IssueRefundRow {}

extension IssueRefundViewModel {

    struct Section {
        let rows: [IssueRefundRow]
    }

    /// ViewModel that represents the shipping switch row.
    struct ShippingSwitchViewModel: IssueRefundRow {
        let title: String
        let isOn: Bool
    }

    /// Creates sections for the table view to display
    ///
    private func createSections() -> [Section] {
        [
            createItemsToRefundSection(),
            createShippingSection()
        ].compactMap { $0 }
    }

    /// Returns a section with the order items that can be refunded
    ///
    private func createItemsToRefundSection() -> Section {
        let itemsRows = state.order.items.map { item -> RefundItemViewModel in
            let product = products.filter { $0.productID == item.productID }.first
            return RefundItemViewModel(item: item,
                                       product: product,
                                       refundQuantity: state.refundQuantityStore.refundQuantity(for: item),
                                       currency: state.order.currency,
                                       currencySettings: state.currencySettings)
        }

        let refundItems = state.refundQuantityStore.map { RefundItemsValuesCalculationUseCase.RefundItem(item: $0, quantity: $1) }
        let summaryRow = RefundProductsTotalViewModel(refundItems: refundItems, currency: state.order.currency, currencySettings: state.currencySettings)

        return Section(rows: itemsRows + [summaryRow])
    }

    /// Returns a `Section` with the shipping switch row and the shipping details row.
    /// Returns `nil` if there isn't any shipping line available
    ///
    private func createShippingSection() -> Section? {
        guard let shippingLine = state.order.shippingLines.first else {
            return nil
        }

        // If `shouldRefundShipping` is disabled, return only the `switchRow`
        let switchRow = ShippingSwitchViewModel(title: Localization.refundShippingTitle, isOn: state.shouldRefundShipping)
        guard state.shouldRefundShipping else {
            return Section(rows: [switchRow])
        }

        let detailsRow = RefundShippingDetailsViewModel(shippingLine: shippingLine, currency: state.order.currency, currencySettings: state.currencySettings)
        return Section(rows: [switchRow, detailsRow])
    }

    /// Returns a string of the refund total formatted with the proper currency settings and store currency.
    ///
    private func calculateTitle() -> String {
        let formatter = CurrencyFormatter(currencySettings: state.currencySettings)
        let totalToRefund = calculateRefundTotal()
        return formatter.formatAmount(totalToRefund, with: state.order.currency) ?? ""
    }

    /// Returns the total amount to refund. ProductsTotal + Shipping Total(If required)
    ///
    private func calculateRefundTotal() -> Decimal {
        let formatter = CurrencyFormatter(currencySettings: state.currencySettings)
        let refundItems = state.refundQuantityStore.map { RefundItemsValuesCalculationUseCase.RefundItem(item: $0, quantity: $1) }
        let productsTotalUseCase = RefundItemsValuesCalculationUseCase(refundItems: refundItems, currencyFormatter: formatter)

        // If shipping is not enabled, return only the products value
        guard let shippingLine = state.order.shippingLines.first, state.shouldRefundShipping else {
            return productsTotalUseCase.calculateRefundValues().total
        }

        let shippingTotalUseCase = RefundShippingCalculationUseCase(shippingLine: shippingLine, currencyFormatter: formatter)
        return productsTotalUseCase.calculateRefundValues().total + shippingTotalUseCase.calculateRefundValue()
    }
}

extension RefundItemViewModel: IssueRefundRow {}

extension RefundProductsTotalViewModel: IssueRefundRow {}

extension RefundShippingDetailsViewModel: IssueRefundRow {}

// MARK: Refund Quantity Store
private extension IssueRefundViewModel {
    /// Structure that holds and provides the quantity of items to refund
    ///
    struct RefundQuantityStore {
        typealias Quantity = Int

        /// Key: order item
        /// Value: quantity to refund
        ///
        private var store: [OrderItem: Quantity] = [:]

        /// Returns the quantity set to be refunded for an itemID
        ///
        func refundQuantity(for item: OrderItem) -> Quantity {
            store[item] ?? 0
        }

        /// Updates the quantity to be refunded for an itemID
        ///
        mutating func update(quantity: Quantity, for item: OrderItem) {
            store[item] = quantity
        }

        /// Returns an array containing the results of mapping the given closure over the sequence's elements.
        ///
        func map<T>(transform: (_ item: OrderItem, _ quantity: Quantity) -> (T)) -> [T] {
            store.map(transform)
        }
    }
}
