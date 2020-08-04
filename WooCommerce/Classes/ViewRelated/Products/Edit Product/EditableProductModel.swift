import Yosemite

/// Represents an editable data model based on `Product`.
final class EditableProductModel {
    let product: Product

    init(product: Product) {
        self.product = product
    }
}

extension EditableProductModel: ProductFormDataModel, TaxClassRequestable {
    var siteID: Int64 {
        product.siteID
    }

    var productID: Int64 {
        product.productID
    }

    var name: String {
        product.name
    }

    var description: String? {
        product.fullDescription
    }

    var shortDescription: String? {
        product.briefDescription
    }

    var permalink: String {
        product.permalink
    }

    var images: [ProductImage] {
        product.images
    }

    var regularPrice: String? {
        product.regularPrice
    }

    var salePrice: String? {
        product.salePrice
    }

    var dateOnSaleStart: Date? {
        product.dateOnSaleStart
    }

    var dateOnSaleEnd: Date? {
        product.dateOnSaleEnd
    }

    var taxStatusKey: String {
        product.taxStatusKey
    }

    var taxClass: String? {
        product.taxClass
    }

    var weight: String? {
        product.weight
    }

    var dimensions: ProductDimensions {
        product.dimensions
    }

    var shippingClass: String? {
        product.shippingClass
    }

    var shippingClassID: Int64 {
        product.shippingClassID
    }

    var sku: String? {
        product.sku
    }

    var manageStock: Bool {
        product.manageStock
    }

    var stockStatus: ProductStockStatus {
        product.productStockStatus
    }

    var stockQuantity: Int64? {
        product.stockQuantity
    }

    var backordersKey: String {
        product.backordersKey
    }

    // Visibility logic

    func allowsMultipleImages() -> Bool {
        true
    }

    func isImageDeletionEnabled() -> Bool {
        true
    }

    func isShippingEnabled() -> Bool {
        product.downloadable == false && product.virtual == false
    }
}

extension EditableProductModel: Equatable {
    static func ==(lhs: EditableProductModel, rhs: EditableProductModel) -> Bool {
        return lhs.product == rhs.product
    }
}
