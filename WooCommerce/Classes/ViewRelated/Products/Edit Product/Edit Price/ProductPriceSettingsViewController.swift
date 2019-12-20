import UIKit
import Yosemite

// MARK: - ProductPriceSettingsViewController
//
final class ProductPriceSettingsViewController: UIViewController {

    @IBOutlet weak private var tableView: UITableView!

    private let product: Product

    // Editable data
    //
    private var regularPrice: String?
    private var salePrice: String?

    private var dateOnSaleStart: Date?
    private var dateOnSaleEnd: Date?

    // When the site time zone can be correctly fetched, consider using the site time zone
    // for Product schedule sale (#1375).
    private let timezoneForScheduleSaleDates = TimeZone.current

    // Date Pickers status
    //
    private var datePickerSaleFromVisible: Bool = false
    private var datePickerSaleToVisible: Bool = false

    // Today at the start of the day
    //
    lazy private var defaultStartDate = Date().startOfDay(timezone: timezoneForScheduleSaleDates)

    // Tomorrow at the end of the day
    //
    lazy private var defaultEndDate = Calendar.current.date(byAdding: .day, value: 1, to: Date().endOfDay(timezone: timezoneForScheduleSaleDates))

    /// Table Sections to be rendered
    ///
    private var sections: [Section] = []

    /// Init
    ///
    init(product: Product) {
        self.product = product
        regularPrice = product.regularPrice
        salePrice = product.salePrice
        dateOnSaleStart = product.dateOnSaleStart
        dateOnSaleEnd = product.dateOnSaleEnd
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureMainView()
        configureSections()
        configureTableView()
    }

}

// MARK: - View Configuration
//
private extension ProductPriceSettingsViewController {

    func configureNavigationBar() {
        title = NSLocalizedString("Price", comment: "Product Price Settings navigation title")

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(completeUpdating))
        removeNavigationBackBarButtonText()
    }

    func configureMainView() {
        view.backgroundColor = .listBackground
    }

    func configureTableView() {
        tableView.rowHeight = UITableView.automaticDimension
        tableView.backgroundColor = .listBackground

        registerTableViewHeaderSections()
        registerTableViewCells()

        tableView.dataSource = self
        tableView.delegate = self
    }

    func registerTableViewHeaderSections() {
        let headerNib = UINib(nibName: TwoColumnSectionHeaderView.reuseIdentifier, bundle: nil)
        tableView.register(headerNib, forHeaderFooterViewReuseIdentifier: TwoColumnSectionHeaderView.reuseIdentifier)
    }

    func registerTableViewCells() {
        for row in Row.allCases {
            tableView.register(row.type.loadNib(), forCellReuseIdentifier: row.reuseIdentifier)
        }
    }
}

// MARK: - Navigation actions handling
//
private extension ProductPriceSettingsViewController {
    @objc func completeUpdating() {
        // TODO-1423: update price settings
    }
}

// MARK: - Input changes handling
//
private extension ProductPriceSettingsViewController {
    func handleRegularPriceChange(regularPrice: String?) {
        self.regularPrice = regularPrice
    }

    func handleSalePriceChange(salePrice: String?) {
        self.salePrice = salePrice
    }
}

// MARK: - UITableViewDataSource Conformance
//
extension ProductPriceSettingsViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].rows.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = rowAtIndexPath(indexPath)
        let cell = tableView.dequeueReusableCell(withIdentifier: row.reuseIdentifier, for: indexPath)
        configure(cell, for: row, at: indexPath)

        return cell
    }
}

// MARK: - UITableViewDelegate Conformance
//
extension ProductPriceSettingsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let row = rowAtIndexPath(indexPath)

        switch row {
        case .scheduleSaleFrom:
            datePickerSaleFromVisible = !datePickerSaleFromVisible
            refreshViewContent()
            break
        case .scheduleSaleTo:
            datePickerSaleToVisible = !datePickerSaleToVisible
            refreshViewContent()
            break
        default:
            break
        }

        // TODO-1423: navigate to tax status & tax class selector
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if sections[section].title == nil {
            return UITableView.automaticDimension
        }

        return Constants.sectionHeight
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let leftText = sections[section].title else {
            return nil
        }

        let headerID = TwoColumnSectionHeaderView.reuseIdentifier
        guard let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: headerID) as? TwoColumnSectionHeaderView else {
            fatalError()
        }

        headerView.leftText = leftText
        headerView.rightText = nil

        return headerView
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let row = rowAtIndexPath(indexPath)

        if row == .datePickerSaleFrom || row == .datePickerSaleTo {
            return Constants.pickerRowHeight
        }

        return UITableView.automaticDimension
    }
}

// MARK: - Cell configuration
//
private extension ProductPriceSettingsViewController {
    /// Cells currently configured in the order they appear on screen
    ///
    func configure(_ cell: UITableViewCell, for row: Row, at indexPath: IndexPath) {
        switch cell {
        case let cell as UnitInputTableViewCell where row == .price:
            configurePrice(cell: cell)
        case let cell as UnitInputTableViewCell where row == .salePrice:
            configureSalePrice(cell: cell)
        case let cell as SwitchTableViewCell where row == .scheduleSale:
            configureScheduleSale(cell: cell)
        case let cell as SettingTitleAndValueTableViewCell where row == .scheduleSaleFrom:
            configureScheduleSaleFrom(cell: cell)
        case let cell as DatePickerTableViewCell where row == .datePickerSaleFrom:
            configureSaleFromPicker(cell: cell)
        case let cell as SettingTitleAndValueTableViewCell where row == .scheduleSaleTo:
            configureScheduleSaleTo(cell: cell)
        case let cell as DatePickerTableViewCell where row == .datePickerSaleTo:
            configureSaleToPicker(cell: cell)
        case let cell as SettingTitleAndValueTableViewCell where row == .taxStatus:
            configureTaxStatus(cell: cell)
        case let cell as SettingTitleAndValueTableViewCell where row == .taxClass:
            configureTaxClass(cell: cell)
        default:
            fatalError()
            break
        }
    }

    func configurePrice(cell: UnitInputTableViewCell) {
        let viewModel = Product.createRegularPriceViewModel(regularPrice: regularPrice, using: CurrencySettings.shared) { [weak self] value in
            self?.handleRegularPriceChange(regularPrice: value)
        }
        cell.selectionStyle = .none
        cell.configure(viewModel: viewModel)
    }

    func configureSalePrice(cell: UnitInputTableViewCell) {
        let viewModel = Product.createSalePriceViewModel(salePrice: salePrice, using: CurrencySettings.shared) { [weak self] value in
            self?.handleSalePriceChange(salePrice: value)
        }
        cell.selectionStyle = .none
        cell.configure(viewModel: viewModel)
    }

    func configureScheduleSale(cell: SwitchTableViewCell) {
        cell.selectionStyle = .none
        cell.title = NSLocalizedString("Schedule sale", comment: "Title of the cell in Product Price Settings > Schedule sale")
        cell.subtitle = NSLocalizedString("Automatically start and end a sale", comment: "Subtitle of the cell in Product Price Settings > Schedule sale")
        cell.isOn = (dateOnSaleStart != nil && dateOnSaleEnd != nil) ? true : false
        cell.onChange = { [weak self] isOn in
            guard let self = self else {
                return
            }

            if isOn {
                self.dateOnSaleStart = self.dateOnSaleStart != nil ? self.dateOnSaleStart : self.product.dateOnSaleStart ?? self.defaultStartDate
                self.dateOnSaleEnd = self.dateOnSaleEnd != nil ? self.dateOnSaleEnd : self.product.dateOnSaleEnd ?? self.defaultEndDate
                self.refreshViewContent()
            }
            else {
                self.dateOnSaleStart = nil
                self.dateOnSaleEnd = nil
                self.refreshViewContent()
            }
        }
    }

    func configureScheduleSaleFrom(cell: SettingTitleAndValueTableViewCell) {
        let title = NSLocalizedString("From", comment: "Title of the cell in Product Price Settings > Schedule sale From a certain date")
        let value = dateOnSaleStart?.toString(dateStyle: .medium, timeStyle: .none)
        cell.updateUI(title: title, value: value)
    }

    func configureSaleFromPicker(cell: DatePickerTableViewCell) {
        guard let dateOnSaleStart = dateOnSaleStart, let dateOnSaleEnd = dateOnSaleEnd else {
            return
        }
        cell.getPicker().setDate(dateOnSaleStart, animated: false)
        cell.onDateSelected = { [weak self] date in
            guard let self = self else {
                return
            }
            if date > dateOnSaleEnd {
                cell.getPicker().setDate(dateOnSaleStart, animated: true)
            }
            else {
                self.dateOnSaleStart = date.startOfDay(timezone: self.timezoneForScheduleSaleDates)
            }
            self.refreshViewContent()
        }
    }

    func configureScheduleSaleTo(cell: SettingTitleAndValueTableViewCell) {
        let title = NSLocalizedString("To", comment: "Title of the cell in Product Price Settings > Schedule sale To a certain date")
        let value = dateOnSaleEnd?.toString(dateStyle: .medium, timeStyle: .none)
        cell.updateUI(title: title, value: value)
    }

    func configureSaleToPicker(cell: DatePickerTableViewCell) {
        guard let dateOnSaleStart = dateOnSaleStart, let dateOnSaleEnd = dateOnSaleEnd else {
            return
        }
        cell.getPicker().setDate(dateOnSaleEnd, animated: false)
        cell.onDateSelected = { [weak self] date in
            guard let self = self else {
                return
            }
            if date < dateOnSaleStart {
                cell.getPicker().setDate(dateOnSaleEnd, animated: true)
            }
            else {
                self.dateOnSaleEnd = date.endOfDay(timezone: self.timezoneForScheduleSaleDates)
            }
            self.refreshViewContent()
        }
    }

    func configureTaxStatus(cell: SettingTitleAndValueTableViewCell) {
        let title = NSLocalizedString("Tax status", comment: "Title of the cell in Product Price Settings > Tax status")
        //TODO: set the tax status
        cell.updateUI(title: title, value: nil)
        cell.accessoryType = .disclosureIndicator
    }

    func configureTaxClass(cell: SettingTitleAndValueTableViewCell) {
        let title = NSLocalizedString("Tax class", comment: "Title of the cell in Product Price Settings > Tax class")
        //TODO: set the tax class
        cell.updateUI(title: title, value: nil)
        cell.accessoryType = .disclosureIndicator
    }
}

// MARK: - Convenience Methods
//
private extension ProductPriceSettingsViewController {

    func refreshViewContent() {
        configureSections()
        tableView.reloadData()
    }

    func rowAtIndexPath(_ indexPath: IndexPath) -> Row {
        return sections[indexPath.section].rows[indexPath.row]
    }

    func configureSections() {
        var saleScheduleRows: [Row] = [.scheduleSale]
        if dateOnSaleStart != nil && dateOnSaleEnd != nil {
            saleScheduleRows.append(contentsOf: [.scheduleSaleFrom])
            if datePickerSaleFromVisible {
                saleScheduleRows.append(contentsOf: [.datePickerSaleFrom])
            }
            saleScheduleRows.append(contentsOf: [.scheduleSaleTo])
            if datePickerSaleToVisible {
                saleScheduleRows.append(contentsOf: [.datePickerSaleTo])
            }
        }

        sections = [
        Section(title: NSLocalizedString("Price", comment: "Section header title for product price"), rows: [.price, .salePrice]),
        Section(title: nil, rows: saleScheduleRows),
        Section(title: NSLocalizedString("Tax Settings", comment: "Section header title for product tax settings"), rows: [.taxStatus, .taxClass])
        ]
    }
}

// MARK: - Private Types
//
private extension ProductPriceSettingsViewController {

    struct Section {
        let title: String?
        let rows: [Row]
    }

    enum Row: CaseIterable {
        case price
        case salePrice

        case scheduleSale
        case scheduleSaleFrom
        case datePickerSaleFrom
        case scheduleSaleTo
        case datePickerSaleTo

        case taxStatus
        case taxClass

        var type: UITableViewCell.Type {
            switch self {
            case .price, .salePrice:
                return UnitInputTableViewCell.self
            case .scheduleSale:
                return SwitchTableViewCell.self
            case .scheduleSaleFrom, .scheduleSaleTo:
                return SettingTitleAndValueTableViewCell.self
            case .datePickerSaleFrom, .datePickerSaleTo:
                return DatePickerTableViewCell.self
            case .taxStatus, .taxClass:
                return SettingTitleAndValueTableViewCell.self
            }
        }

        var reuseIdentifier: String {
            return type.reuseIdentifier
        }
    }
}

private struct Constants {
    static let sectionHeight = CGFloat(44)
    static let pickerRowHeight = CGFloat(216)
}
