import UIKit
import Yosemite

// MARK: - ProductEditPriceSettingsViewController
//
final class ProductEditPriceSettingsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!

    private let product: Product

    // Editable data
    //
    private var regularPrice: String?
    private var salePrice: String?

    private var dateOnSaleStart: Date?
    private var dateOnSaleEnd: Date?

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
private extension ProductEditPriceSettingsViewController {

    func configureNavigationBar() {
        title = NSLocalizedString("Price", comment: "Product Price Settings navigation title")

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(completeUpdating))
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
private extension ProductEditPriceSettingsViewController {
    @objc func completeUpdating() {
        // TODO-1423: update price settings
    }
}

// MARK: - Input changes handling
//
private extension ProductEditPriceSettingsViewController {
    func handleRegularPriceChange(regularPrice: String?) {
        self.regularPrice = regularPrice
    }

    func handleSalePriceChange(salePrice: String?) {
        self.salePrice = salePrice
    }
}

// MARK: - UITableViewDataSource Conformance
//
extension ProductEditPriceSettingsViewController: UITableViewDataSource {

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
extension ProductEditPriceSettingsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        // TODO-1423: navigate to tax class selector
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
}

// MARK: - Cell configuration
//
private extension ProductEditPriceSettingsViewController {
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
        default:
            //fatalError()
            break
        }
    }

    func configurePrice(cell: UnitInputTableViewCell) {
        let viewModel = product.createRegularPriceViewModel(using: CurrencySettings.shared) { [weak self] value in
            self?.handleRegularPriceChange(regularPrice: value)
        }
        cell.selectionStyle = .none
        cell.configure(viewModel: viewModel)
    }

    func configureSalePrice(cell: UnitInputTableViewCell) {
        let viewModel = product.createSalePriceViewModel(using: CurrencySettings.shared) { [weak self] value in
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
        cell.onChange = { isOn in
            
        }
    }
}

// MARK: - Convenience Methods
//
private extension ProductEditPriceSettingsViewController {

    func rowAtIndexPath(_ indexPath: IndexPath) -> Row {
        return sections[indexPath.section].rows[indexPath.row]
    }
    
    func configureSections() {
        sections = [
        Section(title: NSLocalizedString("Price", comment: "Section header title for product price"), rows: [.price, .salePrice]),
        Section(title: nil, rows: [.scheduleSale, .scheduleSaleFrom, .scheduleSaleTo]),
        Section(title: NSLocalizedString("Tax Settings", comment: "Section header title for product tax settings"), rows: [.taxStatus, .taxClass])
        ]
    }
}

// MARK: - Private Types
//
private struct Constants {
    static let sectionHeight = CGFloat(44)
}

private extension ProductEditPriceSettingsViewController {

    struct Section {
        let title: String?
        let rows: [Row]
    }

    enum Row: CaseIterable {
        case price
        case salePrice

        case scheduleSale
        case scheduleSaleFrom
        case scheduleSaleTo

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
            default:
                return SettingTitleAndValueTableViewCell.self
            }
        }

        var reuseIdentifier: String {
            return type.reuseIdentifier
        }
    }
}
