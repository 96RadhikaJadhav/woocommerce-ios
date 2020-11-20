import UIKit
import WordPressUI
import Yosemite

/// Displays a paginated list of products given product IDs, with a CTA to add more products.
final class LinkedProductsListSelectorViewController: UIViewController {

    @IBOutlet private weak var addButton: UIButton!
    @IBOutlet private weak var addButtonBottomBorderView: UIView!
    @IBOutlet private weak var topContainerView: UIView!
    @IBOutlet private weak var productsContainerView: UIView!

    private let imageService: ImageService
    private let productID: Int64
    private let siteID: Int64
    private let viewConfiguration: LinkedProductsListSelectorViewController.ViewConfiguration

    private let dataSource: GroupedProductListSelectorDataSource

    private lazy var paginatedListSelector: PaginatedListSelectorViewController
        <GroupedProductListSelectorDataSource, Product, StorageProduct, ProductsTabProductTableViewCell> = {
            let noResultsPlaceholderText = NSLocalizedString("No products yet", comment: "Placeholder for the products list selector view controller")
            let viewProperties = PaginatedListSelectorViewProperties(navigationBarTitle: nil,
                                                                     noResultsPlaceholderText: noResultsPlaceholderText,
                                                                     noResultsPlaceholderImage: .emptyProductsImage,
                                                                     noResultsPlaceholderImageTintColor: .primary,
                                                                     tableViewStyle: .plain,
                                                                     separatorStyle: .none)
            return PaginatedListSelectorViewController(viewProperties: viewProperties, dataSource: dataSource, onDismiss: { _ in })
    }()

    private var cancellable: ObservationToken?

    // Completion callback
    //
    typealias Completion = (_ groupedProductIDs: [Int64]) -> Void
    private let onCompletion: Completion

    init(product: Product, imageService: ImageService = ServiceLocator.imageService, viewConfiguration: ViewConfiguration, completion: @escaping Completion) {
        self.productID = product.productID
        self.siteID = product.siteID
        self.dataSource = GroupedProductListSelectorDataSource(product: product)
        self.imageService = imageService
        self.viewConfiguration = viewConfiguration
        self.onCompletion = completion
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        configureMainView()
        configureNavigation()
        configureAddButton()
        configureAddButtonBottomBorderView()
        configurePaginatedProductList()

        observeGroupedProductIDs()
    }
}

// MARK: - Actions
//
private extension LinkedProductsListSelectorViewController {
    @objc func addTapped() {
        ServiceLocator.analytics.track(.groupedProductLinkedProductsAddButtonTapped)

        let excludedProductIDs = dataSource.groupedProductIDs + [productID]
        let listSelector = ProductListSelectorViewController(excludedProductIDs: excludedProductIDs,
                                                             siteID: siteID) { [weak self] selectedProductIDs in
                                                                if selectedProductIDs.isNotEmpty {
                                                                    ServiceLocator.analytics.track(.groupedProductLinkedProductsAdded)
                                                                }
                                                                self?.dataSource.addProducts(selectedProductIDs)
                                                                self?.navigationController?.popViewController(animated: true)
        }
        show(listSelector, sender: self)
    }

    @objc func doneButtonTapped() {
        let hasChangedData = dataSource.hasUnsavedChanges()
        ServiceLocator.analytics.track(.groupedProductLinkedProductsDoneButtonTapped, withProperties: [
            "has_changed_data": hasChangedData
        ])

        completeUpdating()
    }
}

// MARK: - Navigation actions handling
//
extension LinkedProductsListSelectorViewController {
    override func shouldPopOnBackButton() -> Bool {
        if dataSource.hasUnsavedChanges() {
            presentBackNavigationActionSheet()
            return false
        }
        return true
    }

    override func shouldPopOnSwipeBack() -> Bool {
        return shouldPopOnBackButton()
    }

    private func completeUpdating() {
        onCompletion(dataSource.groupedProductIDs)
    }

    private func presentBackNavigationActionSheet() {
        UIAlertController.presentDiscardChangesActionSheet(viewController: self, onDiscard: { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        })
    }
}

// MARK: - UI updates
//
private extension LinkedProductsListSelectorViewController {
    func updateNavigationRightBarButtonItem() {
        if dataSource.hasUnsavedChanges() {
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonTapped))
        } else {
            navigationItem.rightBarButtonItem = nil
        }
    }
}

// MARK: - UI configurations
//
private extension LinkedProductsListSelectorViewController {
    func configureMainView() {
        view.backgroundColor = .basicBackground
    }

    func configureNavigation() {
        title = viewConfiguration.title
        updateNavigationRightBarButtonItem()
        removeNavigationBackBarButtonText()
    }

    func configureAddButton() {
        addButton.setTitle(Localization.addButton, for: .normal)
        addButton.addTarget(self, action: #selector(addTapped), for: .touchUpInside)
        addButton.applySecondaryButtonStyle()
    }

    func configureAddButtonBottomBorderView() {
        addButtonBottomBorderView.backgroundColor = .systemColor(.separator)
    }

    func configurePaginatedProductList() {
        addChild(paginatedListSelector)

        paginatedListSelector.view.translatesAutoresizingMaskIntoConstraints = false
        productsContainerView.addSubview(paginatedListSelector.view)
        paginatedListSelector.didMove(toParent: self)
        productsContainerView.pinSubviewToAllEdges(paginatedListSelector.view)
    }

    func observeGroupedProductIDs() {
        cancellable = dataSource.productIDs.subscribe { [weak self] productIDs in
            self?.paginatedListSelector.updateResultsController()
            self?.updateNavigationRightBarButtonItem()
        }
    }
}

extension LinkedProductsListSelectorViewController {
    struct ViewConfiguration {
        let title: String

        init(title: String) {
            self.title = title
        }
    }
}

private extension LinkedProductsListSelectorViewController {
    enum Localization {
        static let addButton = NSLocalizedString("Add Products", comment: "Action to add products to a grouped product on the Grouped Products screen")
    }
}
