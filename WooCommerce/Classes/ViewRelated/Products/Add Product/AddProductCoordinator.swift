import UIKit
import Yosemite

/// Controls navigation for the in-app feedback flow. Meant to be presented modally
///
final class AddProductCoordinator: Coordinator {
    var navigationController: UINavigationController

    private let siteID: Int64
    private let sourceView: UIBarButtonItem

    init(siteID: Int64, sourceView: UIBarButtonItem, sourceNavigationController: UINavigationController) {
        self.siteID = siteID
        self.sourceView = sourceView
        self.navigationController = sourceNavigationController
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func start() {
        presentProductTypeBottomSheet()
    }
}

// MARK: Navigation
private extension AddProductCoordinator {
    func presentProductTypeBottomSheet() {
        let title = NSLocalizedString("Select a product type",
                                      comment: "Message title of bottom sheet for selecting a product type to create a product")
        let viewProperties = BottomSheetListSelectorViewProperties(title: title)
        let command = ProductTypeBottomSheetListSelectorCommand(selected: nil) { selectedProductType in
            self.navigationController.dismiss(animated: true) {
                // Strong reference to `self` is required since `AddProductCoordinator` is not strongly referenced by any class.
                self.presentProductForm(productType: selectedProductType)
            }
        }
        let productTypesListPresenter = BottomSheetListSelectorPresenter(viewProperties: viewProperties, command: command)
        productTypesListPresenter.show(from: navigationController, sourceBarButtonItem: sourceView, arrowDirections: .up)
    }

    func presentProductForm(productType: ProductType) {
        let product = ProductFactory().createNewProduct(type: productType, siteID: siteID)
        let model = EditableProductModel(product: product)

        let currencyCode = ServiceLocator.currencySettings.currencyCode
        let currency = ServiceLocator.currencySettings.symbol(from: currencyCode)
        let productImageActionHandler = ProductImageActionHandler(siteID: product.siteID,
                                                                  product: model)
        let viewModel = ProductFormViewModel(product: model,
                                             formType: .add,
                                             productImageActionHandler: productImageActionHandler,
                                             isEditProductsRelease3Enabled: true)
        let viewController = ProductFormViewController(viewModel: viewModel,
                                                       eventLogger: ProductFormEventLogger(),
                                                       productImageActionHandler: productImageActionHandler,
                                                       currency: currency,
                                                       presentationStyle: .navigationStack,
                                                       isEditProductsRelease3Enabled: true)
        // Since the edit Product UI could hold local changes, disables the bottom bar (tab bar) to simplify app states.
        viewController.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(viewController, animated: true)
    }
}
