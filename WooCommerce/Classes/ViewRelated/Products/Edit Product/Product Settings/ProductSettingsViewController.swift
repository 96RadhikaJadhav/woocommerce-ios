import UIKit
import Yosemite

// MARK: - ProductSettingsViewController
//
final class ProductSettingsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    private var viewModel: ProductSettingsTableViewModel
    
    init(product: Product) {
        viewModel = ProductSettingsTableViewModel(product: product)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
}

// MARK: - View Configuration
//
private extension ProductSettingsViewController {

    func configureNavigationBar() {
        title = NSLocalizedString("Product Settings", comment: "Product Settings navigation title")
        
        removeNavigationBackBarButtonText()
    }

    func configureMainView() {
        view.backgroundColor = .listBackground
    }

    func configureTableView() {
        viewModel.registerTableViewCells(tableView)

        //tableView.dataSource = self
        tableView.delegate = self

        tableView.backgroundColor = .listBackground
        tableView.removeLastCellSeparator()

        tableView.reloadData()
    }
}

// MARK: - UITableViewDataSource Conformance
//
extension ProductSettingsViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let section = viewModel.sections[section]
        switch section {
        case .publishSettings( _, let rows):
            return rows.count
        case .moreOptions( _, let rows):
            return rows.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = viewModel.sections[indexPath.section]
        let reuseIdentifier = section.reuseIdentifier(at: indexPath.row)
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
        configure(cell, section: section, indexPath: indexPath)
        return cell
    }
    
    func configure(_ cell: UITableViewCell, section: ProductSettingsSection, indexPath: IndexPath) {
        switch section {
        case .publishSettings( _, let rows):
            configureCellInPublishSettingsSection(cell, row: rows[indexPath.row])
        case .moreOptions( _, let rows):
            configureCellInMoreOptionsSection(cell, row: rows[indexPath.row])
        }
    }
}

// MARK: - UITableViewDelegate Conformance
//
extension ProductSettingsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}


// MARK: Configure rows in Publish Settings Section
//
private extension ProductSettingsViewController {
    func configureCellInPublishSettingsSection(_ cell: UITableViewCell, row: ProductSettingsSection.PublishSettingsRow) {
        switch row {
        case .visibility(let visibility):
            configureVisibilityCell(cell: cell, visibility: visibility)
        }
    }
    
    func configureVisibilityCell(cell: UITableViewCell, visibility: String?) {
        
    }
}

// MARK: Configure rows in More Options Section
//
private extension ProductSettingsViewController {
    func configureCellInMoreOptionsSection(_ cell: UITableViewCell, row: ProductSettingsSection.MoreOptionsRow) {
        switch row {
        case .slug(let slug):
            configureSlugCell(cell: cell, slug: slug)
        }
    }
    
    func configureSlugCell(cell: UITableViewCell, slug: String?) {
        
    }
}
