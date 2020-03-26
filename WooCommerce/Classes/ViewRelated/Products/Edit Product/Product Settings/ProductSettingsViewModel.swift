import UIKit
import Yosemite

/// The Product Settings contains 2 sections: Publish Settings and More Options
final class ProductSettingsViewModel {

    public private(set) var sections: [ProductSettingsSectionMediator]

    public private(set) var productSettings: ProductSettings

    /// Closures
    ///
    var onReload: (() -> Void)?

    init(product: Product) {
        productSettings = ProductSettings(status: product.productStatus)
        sections = Self.configureSections(productSettings)
    }

    func handleCellTap(at indexPath: IndexPath, sourceViewController: UIViewController) {
        let section = sections[indexPath.section]
        let row = section.rows[indexPath.row]
        row.handleTap(sourceViewController: sourceViewController) { [weak self] (settings) in
            self?.productSettings = settings
            self?.sections = ProductSettingsViewModel.configureSections(self?.productSettings)
            self?.onReload?()
        }
    }

}

// MARK: Configure sections and rows in Product Settings
//
private extension ProductSettingsViewModel {
    static func configureSections(_ settings: ProductSettings?) -> [ProductSettingsSectionMediator] {
        guard let settings = settings else {
            return []
        }
        return [ProductSettingsSections.PublishSettings(settings),
                     ProductSettingsSections.MoreOptions(settings)
        ]
    }
}

// MARK: - Register table view cells and headers
//
extension ProductSettingsViewModel {

    /// Registers all of the available TableViewCells
    ///
    func registerTableViewCells(_ tableView: UITableView) {
        sections.flatMap {
            $0.rows.flatMap { $0.cellTypes }
        }.forEach {
            tableView.register($0.loadNib(), forCellReuseIdentifier: $0.reuseIdentifier)
        }
    }

    /// Registers all of the available TableViewHeaderFooters
    ///
    func registerTableViewHeaderFooters(_ tableView: UITableView) {
        let headersAndFooters = [TwoColumnSectionHeaderView.self]

        for kind in headersAndFooters {
            tableView.register(kind.loadNib(), forHeaderFooterViewReuseIdentifier: kind.reuseIdentifier)
        }
    }
}

// Editable data
//
final class ProductSettings {
    var status: ProductStatus

    init(status: ProductStatus) {
        self.status = status
    }
}
