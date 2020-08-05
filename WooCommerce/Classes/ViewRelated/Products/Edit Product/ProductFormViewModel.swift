import Yosemite

/// Provides data for product form UI, and handles product editing actions.
final class ProductFormViewModel: ProductFormViewModelProtocol {
    typealias ProductModel = EditableProductModel

    /// Emits product on change, except when the product name is the only change (`productName` is emitted for this case).
    var observableProduct: Observable<EditableProductModel> {
        productSubject
    }

    /// Emits product name on change.
    var productName: Observable<String>? {
        productNameSubject
    }

    /// Emits a boolean of whether the product has unsaved changes for remote update.
    var isUpdateEnabled: Observable<Bool> {
        isUpdateEnabledSubject
    }

    /// The latest product value.
    var productModel: EditableProductModel {
        product
    }

    /// Creates actions available on the bottom sheet.
    private(set) var actionsFactory: ProductFormActionsFactoryProtocol

    private let productSubject: PublishSubject<EditableProductModel> = PublishSubject<EditableProductModel>()
    private let productNameSubject: PublishSubject<String> = PublishSubject<String>()
    private let isUpdateEnabledSubject: PublishSubject<Bool>

    /// The product model before any potential edits; reset after a remote update.
    private var originalProduct: EditableProductModel {
        didSet {
            product = originalProduct
        }
    }

    /// The product model with potential edits; reset after a remote update.
    private var product: EditableProductModel {
        didSet {
            guard product != oldValue else {
                return
            }

            defer {
                isUpdateEnabledSubject.send(hasUnsavedChanges())
            }

            if isNameTheOnlyChange(oldProduct: oldValue, newProduct: product) {
                productNameSubject.send(product.name)
                return
            }

            actionsFactory = ProductFormActionsFactory(product: product,
                                                       isEditProductsRelease2Enabled: isEditProductsRelease2Enabled,
                                                       isEditProductsRelease3Enabled: isEditProductsRelease3Enabled)
            productSubject.send(product)
        }
    }

    /// The product password, fetched in Product Settings
    private var originalPassword: String? {
        didSet {
            password = originalPassword
        }
    }

    private(set) var password: String? {
        didSet {
            if password != oldValue {
                isUpdateEnabledSubject.send(hasUnsavedChanges())
            }
        }
    }

    private let productImageActionHandler: ProductImageActionHandler
    private let isEditProductsRelease2Enabled: Bool
    private let isEditProductsRelease3Enabled: Bool

    private var cancellable: ObservationToken?

    init(product: EditableProductModel,
         productImageActionHandler: ProductImageActionHandler,
         isEditProductsRelease2Enabled: Bool,
         isEditProductsRelease3Enabled: Bool) {
        self.productImageActionHandler = productImageActionHandler
        self.isEditProductsRelease2Enabled = isEditProductsRelease2Enabled
        self.isEditProductsRelease3Enabled = isEditProductsRelease3Enabled
        self.originalProduct = product
        self.product = product
        self.actionsFactory = ProductFormActionsFactory(product: product,
                                                        isEditProductsRelease2Enabled: isEditProductsRelease2Enabled,
                                                        isEditProductsRelease3Enabled: isEditProductsRelease3Enabled)
        self.isUpdateEnabledSubject = PublishSubject<Bool>()

        self.cancellable = productImageActionHandler.addUpdateObserver(self) { [weak self] allStatuses in
            if allStatuses.productImageStatuses.hasPendingUpload {
                self?.isUpdateEnabledSubject.send(true)
            }
        }
    }

    deinit {
        cancellable?.cancel()
    }

    func hasUnsavedChanges() -> Bool {
        return product != originalProduct || productImageActionHandler.productImageStatuses.hasPendingUpload || password != originalPassword
    }

    func hasProductChanged() -> Bool {
        return product != originalProduct
    }

    func hasPasswordChanged() -> Bool {
        return password != nil && password != originalPassword
    }
}

// MARK: - More menu
//
extension ProductFormViewModel {
    func canEditProductSettings() -> Bool {
        return true
    }

    func canViewProductInStore() -> Bool {
        return originalProduct.product.productStatus == .publish
    }
}

// MARK: Action handling
//
extension ProductFormViewModel {
    func updateName(_ name: String) {
        product = EditableProductModel(product: product.product.copy(name: name))
    }

    func updateImages(_ images: [ProductImage]) {
        product = EditableProductModel(product: product.product.copy(images: images))
    }

    func updateDescription(_ newDescription: String) {
        product = EditableProductModel(product: product.product.copy(fullDescription: newDescription))
    }

    func updatePriceSettings(regularPrice: String?,
                             salePrice: String?,
                             dateOnSaleStart: Date?,
                             dateOnSaleEnd: Date?,
                             taxStatus: ProductTaxStatus,
                             taxClass: TaxClass?) {
        product = EditableProductModel(product: product.product.copy(dateOnSaleStart: dateOnSaleStart,
                                                                     dateOnSaleEnd: dateOnSaleEnd,
                                                                     regularPrice: regularPrice,
                                                                     salePrice: salePrice,
                                                                     taxStatusKey: taxStatus.rawValue,
                                                                     taxClass: taxClass?.slug))
    }

    func updateReviews(averageRating: String, ratingCount: Int) {
        product = EditableProductModel(product: product.product.copy(averageRating: averageRating, ratingCount: ratingCount))
    }

    func updateInventorySettings(sku: String?,
                                 manageStock: Bool,
                                 soldIndividually: Bool?,
                                 stockQuantity: Int64?,
                                 backordersSetting: ProductBackordersSetting?,
                                 stockStatus: ProductStockStatus?) {
        product = EditableProductModel(product: product.product.copy(sku: sku,
                                                                     manageStock: manageStock,
                                                                     stockQuantity: stockQuantity,
                                                                     stockStatusKey: stockStatus?.rawValue,
                                                                     backordersKey: backordersSetting?.rawValue,
                                                                     soldIndividually: soldIndividually))
    }

    func updateShippingSettings(weight: String?, dimensions: ProductDimensions, shippingClass: ProductShippingClass?) {
        product = EditableProductModel(product: product.product.copy(weight: weight,
                                                                     dimensions: dimensions,
                                                                     shippingClass: shippingClass?.slug ?? "",
                                                                     shippingClassID: shippingClass?.shippingClassID ?? 0,
                                                                     productShippingClass: shippingClass))
    }

    func updateProductCategories(_ categories: [ProductCategory]) {
        product = EditableProductModel(product: product.product.copy(categories: categories))
    }

    func updateProductTags(_ tags: [ProductTag]) {
        product = EditableProductModel(product: product.product.copy(tags: tags))
    }

    func updateBriefDescription(_ briefDescription: String) {
        product = EditableProductModel(product: product.product.copy(briefDescription: briefDescription))
    }

    func updateSKU(_ sku: String?) {
        product = EditableProductModel(product: product.product.copy(sku: sku))
    }

    func updateGroupedProductIDs(_ groupedProductIDs: [Int64]) {
        product = EditableProductModel(product: product.product.copy(groupedProducts: groupedProductIDs))
    }

    func updateProductSettings(_ settings: ProductSettings) {
        product = EditableProductModel(product: product.product.copy(slug: settings.slug,
                                                                     statusKey: settings.status.rawValue,
                                                                     featured: settings.featured,
                                                                     catalogVisibilityKey: settings.catalogVisibility.rawValue,
                                                                     virtual: settings.virtual,
                                                                     reviewsAllowed: settings.reviewsAllowed,
                                                                     purchaseNote: settings.purchaseNote,
                                                                     menuOrder: settings.menuOrder))
        password = settings.password
    }

    func updateExternalLink(externalURL: String?, buttonText: String) {
        product = EditableProductModel(product: product.product.copy(buttonText: buttonText, externalURL: externalURL))
    }
}

// MARK: Remote actions
//
extension ProductFormViewModel {
    func updateProductRemotely(onCompletion: @escaping (Result<EditableProductModel, ProductUpdateError>) -> Void) {
        let updateProductAction = ProductAction.updateProduct(product: product.product) { [weak self] result in
            switch result {
            case .failure(let error):
                onCompletion(.failure(error))
            case .success(let product):
                let model = EditableProductModel(product: product)
                self?.resetProduct(model)
                onCompletion(.success(model))
            }
        }
        ServiceLocator.stores.dispatch(updateProductAction)
    }
}

// MARK: Reset actions
//
extension ProductFormViewModel {
    private func resetProduct(_ product: EditableProductModel) {
        originalProduct = product
    }

    func resetPassword(_ password: String?) {
        originalPassword = password
        isUpdateEnabledSubject.send(hasUnsavedChanges())
    }
}

private extension ProductFormViewModel {
    func isNameTheOnlyChange(oldProduct: EditableProductModel, newProduct: EditableProductModel) -> Bool {
        let oldProductWithNewName = EditableProductModel(product: oldProduct.product.copy(name: newProduct.name))
        return oldProductWithNewName == newProduct && newProduct.name != oldProduct.name
    }
}
