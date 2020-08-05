import Yosemite

/// Represents an editable data model based on `ProductVariation`.
final class EditableProductVariationModel {
    let productVariation: ProductVariation
    let allAttributes: [ProductAttribute]

    lazy var variationName: String = generateName(variationAttributes: productVariation.attributes, allAttributes: allAttributes)

    init(productVariation: ProductVariation, allAttributes: [ProductAttribute]) {
        self.productVariation = productVariation
        self.allAttributes = allAttributes
    }
}

private extension EditableProductVariationModel {
    func generateName(variationAttributes: [ProductVariationAttribute], allAttributes: [ProductAttribute]) -> String {
        return allAttributes.map { attribute in
            guard let variationAttribute = variationAttributes.first(where: { $0.id == attribute.attributeID && $0.name == attribute.name }) else {
                // The variation doesn't have an option set for this attribute, and we show "Any \(attributeName)" in this case.
                return String.localizedStringWithFormat(Localization.anyAttirubteFormat, attribute.name)
            }
            return variationAttribute.option
        }.joined(separator: " - ")
    }
}

extension EditableProductVariationModel: ProductFormDataModel, TaxClassRequestable {
    var siteID: Int64 {
        productVariation.siteID
    }

    var productID: Int64 {
        productVariation.productID
    }

    var name: String {
        variationName
    }

    var description: String? {
        productVariation.description
    }

    var shortDescription: String? {
        nil
    }

    var permalink: String {
        productVariation.permalink
    }

    var images: [ProductImage] {
        [productVariation.image].compactMap { $0 }
    }

    var regularPrice: String? {
        productVariation.regularPrice
    }

    var salePrice: String? {
        productVariation.salePrice
    }

    var dateOnSaleStart: Date? {
        productVariation.dateOnSaleStart
    }

    var dateOnSaleEnd: Date? {
        productVariation.dateOnSaleEnd
    }

    var taxStatusKey: String {
        productVariation.taxStatusKey
    }

    var taxClass: String? {
        productVariation.taxClass
    }

    var weight: String? {
        productVariation.weight
    }

    var dimensions: ProductDimensions {
        productVariation.dimensions
    }

    var shippingClass: String? {
        productVariation.shippingClass
    }

    var shippingClassID: Int64 {
        productVariation.shippingClassID
    }

    var sku: String? {
        productVariation.sku
    }

    var manageStock: Bool {
        productVariation.manageStock
    }

    var stockStatus: ProductStockStatus {
        productVariation.stockStatus
    }

    var stockQuantity: Int64? {
        productVariation.stockQuantity
    }

    var backordersKey: String {
        productVariation.backordersKey
    }

    var soldIndividually: Bool? {
        nil
    }

    // Visibility logic

    func allowsMultipleImages() -> Bool {
        false
    }

    func isImageDeletionEnabled() -> Bool {
        false
    }

    func isShippingEnabled() -> Bool {
        productVariation.downloadable == false && productVariation.virtual == false
    }
}

extension EditableProductVariationModel: Equatable {
    static func ==(lhs: EditableProductVariationModel, rhs: EditableProductVariationModel) -> Bool {
        return lhs.productVariation == rhs.productVariation
    }
}

extension EditableProductVariationModel {
    enum Localization {
        static let anyAttirubteFormat =
            NSLocalizedString("Any %@", comment: "Format of a product varition attribute description where the attribute is set to any value.")
    }
}
