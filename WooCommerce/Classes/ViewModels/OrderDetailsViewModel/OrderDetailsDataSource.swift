import Foundation
import UIKit
import Yosemite


/// The main file for Order Details data.
///
final class OrderDetailsDataSource: NSObject {
    private(set) var order: Order
    private let currencyFormatter = CurrencyFormatter()
    private let couponLines: [OrderCouponLine]?

    /// Haptic Feedback!
    ///
    let hapticGenerator = UINotificationFeedbackGenerator()

    /// Sections to be rendered
    ///
    var sections = [Section]()

    /// Is this order processing?
    ///
    var isProcessingPayment: Bool {
        return order.statusKey == OrderStatusEnum.processing.rawValue
    }

    /// Is the shipment tracking plugin available?
    ///
    var trackingIsReachable: Bool = false

    /// Anything above 999.99 or below -999.99 should display a truncated amount
    ///
    var totalFriendlyString: String? {
        return currencyFormatter.formatHumanReadableAmount(order.total, with: order.currency, roundSmallNumbers: false) ?? String()
    }

    /// For example, #560 Pamela Nguyen
    ///
    var summaryTitle: String? {
        if let billingAddress = order.billingAddress {
            return "#\(order.number) \(billingAddress.firstName) \(billingAddress.lastName)"
        }
        return "#\(order.number)"
    }

    /// For example, Oct 1, 2019 at 2:31 PM
    ///
    var summaryDateCreated: String {
        return order.dateModified.relativelyFormattedUpdateString
    }

    /// Closure to be executed when the cell was tapped.
    ///
    var onCellAction: ((CellActionType, IndexPath?) -> Void)?

    /// Closure to be executed when the UI needs to be reloaded.
    ///
    var onUIReloadRequired: (() -> Void)?

    /// Order shipment tracking list
    ///
    var orderTracking: [ShipmentTracking] {
        return resultsControllers.orderTracking
    }

    /// Order statuses list
    ///
    var currentSiteStatuses: [OrderStatus] {
        return resultsControllers.currentSiteStatuses
    }

    /// Products from an Order
    ///
    var products: [Product] {
        return resultsControllers.products
    }

    /// Refunds on an Order
    ///
    var refunds: [Refund] {
        return resultsControllers.refunds
    }
    
    /// Shipping Lines from an Order
    ///
    var shippingLines: [ShippingLine] {
        return order.shippingLines
    }

    /// First Shipping method from an order
    ///
    var shippingMethod: String {
        return shippingLines.first?.methodTitle ?? String()
    }

    /// All the items inside an order
    var items: [OrderItem] {
        return order.items
    }

    /// All the condensed refunds in an order
    ///
    var condensedRefunds: [OrderRefundCondensed] {
        return order.refunds
    }

    /// Notes of an Order
    ///
    var orderNotes: [OrderNote] = [] {
        didSet {
            orderNotesSections = computeOrderNotesSections()
        }
    }

    /// Note of customer about the order
    var customerNote: String {
        return order.customerNote ?? String()
    }

    /// Computed Notes of an Order with note sections
    ///
    var orderNotesSections: [NoteSection] = []

    private lazy var resultsControllers: OrderDetailsResultsControllers = {
        return OrderDetailsResultsControllers(order: self.order)
    }()

    lazy var orderNoteAsyncDictionary: AsyncDictionary<Int, String> = {
        return AsyncDictionary()
    }()

    init(order: Order) {
        self.order = order
        self.couponLines = order.coupons
        super.init()
    }

    func update(order: Order) {
        self.order = order
    }

    func configureResultsControllers(onReload: @escaping () -> Void) {
        resultsControllers.configureResultsControllers(onReload: onReload)
    }
}


// MARK: - Conformance to UITableViewDataSource
extension OrderDetailsDataSource: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].rows.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = sections[indexPath.section].rows[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: row.reuseIdentifier, for: indexPath)
        configure(cell, for: row, at: indexPath)
        return cell
    }
}


// MARK: - Support for UITableViewDelegate
extension OrderDetailsDataSource {
    func viewForHeaderInSection(_ section: Int, tableView: UITableView) -> UIView? {
        guard let leftText = sections[section].title else {
            return nil
        }

        let headerID = TwoColumnSectionHeaderView.reuseIdentifier
        guard let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: headerID) as? TwoColumnSectionHeaderView else {
            fatalError()
        }

        headerView.leftText = leftText
        headerView.rightText = sections[section].rightTitle

        return headerView
    }
}


// MARK: - Lookup orders and statuses
extension OrderDetailsDataSource {
    func lookUpOrderStatus(for order: Order) -> OrderStatus? {
        return currentSiteStatuses.filter({$0.slug == order.statusKey}).first
    }

    func lookUpProduct(by productID: Int) -> Product? {
        return products.filter({ $0.productID == productID }).first
    }

    func lookUpRefund(by refundID: Int) -> Refund? {
        return refunds.filter({ $0.refundID == refundID }).first
    }
    
    func isMultiShippingLinesAvailable(for order: Order) -> Bool {
        return shippingLines.count > 1
    }
}


// MARK: - Sections
extension OrderDetailsDataSource {
    /// Setup: Sections
    ///
    /// CustomerInformation Behavior:
    /// When: Customer Note == nil          >>> Hide Customer Note
    /// When: Shipping == nil               >>> Display: Shipping = "No address specified"
    ///
    func reloadSections() {
        let summary = Section(row: .summary)

        let shippingNotice: Section? = {
            //Hide the shipping method warning if order contains only virtual products or if the order contains only one shipping method
            if isMultiShippingLinesAvailable(for: order) == false {
                return nil
            }

            return Section(title: nil, rightTitle: nil, footer: nil, rows: [.shippingNotice])
        }()

        let products: Section? = {
            guard items.isEmpty == false else {
                return nil
            }

            var rows: [Row] = Array(repeating: .orderItem, count: items.count)
            if isProcessingPayment {
                rows.append(.fulfillButton)
            } else {
                rows.append(.details)
            }

            return Section(title: Title.product, rightTitle: Title.quantity, rows: rows)
        }()

        let customerInformation: Section = {
            var rows: [Row] = []

            if customerNote.isEmpty == false {
                rows.append(.customerNote)
            }
            if order.shippingAddress != nil {
                rows.append(.shippingAddress)
            }
            if shippingLines.count > 0 {
                rows.append(.shippingMethod)
            }
            rows.append(.billingDetail)

            return Section(title: Title.information, rows: rows)
        }()
        
        let payment:Section = {
            var rows: [Row] = [.payment, .customerPaid]

            if order.refunds.count > 0 {
                let refunds = Array<Row>(repeating: .refund, count: order.refunds.count)
                rows.append(contentsOf: refunds)
                rows.append(.netAmount)
            }

            return Section(title: Title.payment, rows: rows)
        }()
        
        let tracking: Section? = {
            guard orderTracking.count > 0 else {
                return nil
            }

            let rows: [Row] = Array(repeating: .tracking, count: orderTracking.count)
            return Section(title: Title.tracking, rows: rows)
        }()

        let addTracking: Section? = {
            // Hide the section if the shipment
            // tracking plugin is not installed
            guard trackingIsReachable else {
                return nil
            }

            let title = orderTracking.count == 0 ? NSLocalizedString("Optional Tracking Information", comment: "") : nil
            let row = Row.trackingAdd

            return Section(title: title, rightTitle: nil, rows: [row])
        }()

        let notes: Section = {
            let rows = [.addOrderNote] + orderNotesSections.map {$0.row}
            return Section(title: Title.notes, rows: rows)
        }()

        sections = [summary, shippingNotice, products, customerInformation, payment, tracking, addTracking, notes].compactMap { $0 }
        updateOrderNoteAsyncDictionary(orderNotes: orderNotes)
    }

    private func updateOrderNoteAsyncDictionary(orderNotes: [OrderNote]) {
        orderNoteAsyncDictionary.clear()
        for orderNote in orderNotes {
            let calculation = { () -> (String) in
                return orderNote.note.strippedHTML
            }
            let onSet = { [weak self] (note: String?) -> () in
                guard note != nil else {
                    return
                }
                self?.onUIReloadRequired?()
            }
            orderNoteAsyncDictionary.calculate(forKey: orderNote.noteID,
                                               operation: calculation,
                                               onCompletion: onSet)
        }
    }

    func rowAtIndexPath(_ indexPath: IndexPath) -> Row {
        return sections[indexPath.section].rows[indexPath.row]
    }

    func noteHeader(at indexPath: IndexPath) -> Date? {
        // We need to subtract 1 here because the first order note row is the "Add Order" cell
        let noteHeaderIndex = indexPath.row - 1
        guard orderNotesSections.indices.contains(noteHeaderIndex) else {
            return nil
        }

        return orderNotesSections[noteHeaderIndex].date
    }

    func note(at indexPath: IndexPath) -> OrderNote? {
        // We need to subtract 1 here because the first order note row is the "Add Order" cell
        let noteIndex = indexPath.row - 1
        guard orderNotesSections.indices.contains(noteIndex) else {
            return nil
        }

        return orderNotesSections[noteIndex].orderNote
    }

    func orderTracking(at indexPath: IndexPath) -> ShipmentTracking? {
        let orderIndex = indexPath.row
        guard orderTracking.indices.contains(orderIndex) else {
            return nil
        }

        return orderTracking[orderIndex]
    }

    /// Sends the provided Row's text data to the pasteboard
    ///
    /// - Parameter indexPath: IndexPath to copy text data from
    ///
    func copyText(at indexPath: IndexPath) {
        let row = rowAtIndexPath(indexPath)

        switch row {
        case .shippingAddress:
            sendToPasteboard(order.shippingAddress?.fullNameWithCompanyAndAddress)
        case .tracking:
            sendToPasteboard(orderTracking(at: indexPath)?.trackingNumber, includeTrailingNewline: false)
        default:
            break // We only send text to the pasteboard from the address rows right meow
        }
    }

    /// Sends the provided text to the general pasteboard and triggers a success haptic. If the text param
    /// is nil, nothing is sent to the pasteboard.
    ///
    /// - Parameter
    ///   - text: string value to send to the pasteboard
    ///   - includeTrailingNewline: If true, insert a trailing newline; defaults to true
    ///
    func sendToPasteboard(_ text: String?, includeTrailingNewline: Bool = true) {
        guard var text = text, text.isEmpty == false else {
            return
        }

        if includeTrailingNewline {
            text += "\n"
        }

        UIPasteboard.general.string = text
        hapticGenerator.notificationOccurred(.success)
    }

    /// Checks if copying the row data at the provided indexPath is allowed
    ///
    /// - Parameter indexPath: index path of the row to check
    /// - Returns: true is copying is allowed, false otherwise
    ///
    func checkIfCopyingIsAllowed(for indexPath: IndexPath) -> Bool {
        let row = rowAtIndexPath(indexPath)
        switch row {
        case .shippingAddress:
            if let _ = order.shippingAddress {
                return true
            }
        case .tracking:
            if orderTracking(at: indexPath)?.trackingNumber.isEmpty == false {
                return true
            }
        default:
            break
        }

        return false
    }

    func computeOrderNotesSections() -> [NoteSection] {
        var sections: [NoteSection] = []

        for order in orderNotes {
            if sections.contains(where: { (section) -> Bool in
                return Calendar.current.isDate(section.date, inSameDayAs: order.dateCreated) && section.row == .orderNoteHeader
            }) {
                let orderToAppend = NoteSection(row: .orderNote, date: order.dateCreated, orderNote: order)
                sections.append(orderToAppend)
            }
            else {
                let sectionToAppend = NoteSection(row: .orderNoteHeader, date: order.dateCreated, orderNote: order)
                let orderToAppend = NoteSection(row: .orderNote, date: order.dateCreated, orderNote: order)
                sections.append(contentsOf: [sectionToAppend, orderToAppend])
            }
        }

        return sections
    }
}

