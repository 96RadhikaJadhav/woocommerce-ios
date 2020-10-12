import XCTest
@testable import WooCommerce
@testable import Yosemite

final class ProductFormActionsFactory_NonEmptyBottomSheetActionsTests: XCTestCase {
    func testDataHasEditProductsRelease3ActionsForAPhysicalProductWhenBothFeatureFlagsAreOn() {
        // Arrange
        let product = Fixtures.physicalProduct
        let model = EditableProductModel(product: product)

        // Action
        let factory = ProductFormActionsFactory(product: model,
                                                formType: .edit,
                                                isEditProductsRelease3Enabled: true)

        // Assert
        let expectedSettingsSectionActions: [ProductFormEditAction] = [.priceSettings(editable: true), .reviews, .productType(editable: true)]
        XCTAssertEqual(factory.settingsSectionActions(), expectedSettingsSectionActions)

        let expectedBottomSheetActions: [ProductFormBottomSheetAction] = [.editShippingSettings,
                                                                          .editInventorySettings,
                                                                          .editCategories,
                                                                          .editTags,
                                                                          .editBriefDescription]
        XCTAssertEqual(factory.bottomSheetActions(), expectedBottomSheetActions)
    }

    func testDataHasEditProductsRelease3ButNoShippingActionsForAVirtualProductWhenBothFeatureFlagsAreOn() {
        // Arrange
        let product = Fixtures.virtualProduct
        let model = EditableProductModel(product: product)

        // Action
        let factory = ProductFormActionsFactory(product: model,
                                                formType: .edit,
                                                isEditProductsRelease3Enabled: true)

        // Assert
        let expectedSettingsSectionActions: [ProductFormEditAction] = [.priceSettings(editable: true), .reviews, .productType(editable: true)]
        XCTAssertEqual(factory.settingsSectionActions(), expectedSettingsSectionActions)

        let expectedBottomSheetActions: [ProductFormBottomSheetAction] = [.editInventorySettings, .editCategories, .editTags, .editBriefDescription]
        XCTAssertEqual(factory.bottomSheetActions(), expectedBottomSheetActions)
    }

    func testDataHasEditProductsRelease3ButNoShippingActionsForADownloadableProductWhenBothFeatureFlagsAreOn() {
        // Arrange
        let product = Fixtures.downloadableProduct
        let model = EditableProductModel(product: product)

        // Action
        let factory = ProductFormActionsFactory(product: model,
                                                formType: .edit,
                                                isEditProductsRelease3Enabled: true)

        // Assert
        let expectedSettingsSectionActions: [ProductFormEditAction] = [.priceSettings(editable: true), .reviews, .productType(editable: true)]
        XCTAssertEqual(factory.settingsSectionActions(), expectedSettingsSectionActions)

        let expectedBottomSheetActions: [ProductFormBottomSheetAction] = [.editInventorySettings, .editCategories, .editTags, .editBriefDescription]
        XCTAssertEqual(factory.bottomSheetActions(), expectedBottomSheetActions)
    }

}

private extension ProductFormActionsFactory_NonEmptyBottomSheetActionsTests {
    enum Fixtures {
        // downloadable: false, virtual: false, missing inventory/shipping/categories/tags/brief description
        static let physicalProduct = MockProduct().product(downloadable: false, briefDescription: "", manageStock: true, sku: nil, stockQuantity: nil,
                                                           dimensions: ProductDimensions(length: "", width: "", height: ""), weight: nil,
                                                           virtual: false,
                                                           categories: [],
                                                           tags: [])
        // downloadable: false, virtual: true, missing inventory/shipping/categories/tags/brief description
        static let virtualProduct = MockProduct().product(downloadable: false, briefDescription: "", manageStock: true, sku: nil, stockQuantity: nil,
                                                          dimensions: ProductDimensions(length: "", width: "", height: ""), weight: nil,
                                                          virtual: true,
                                                          categories: [],
                                                          tags: [])
        // downloadable: true, virtual: true, missing inventory/shipping/categories/tags/brief description
        static let downloadableProduct = MockProduct().product(downloadable: true, briefDescription: "", manageStock: true, sku: nil, stockQuantity: nil,
                                                               dimensions: ProductDimensions(length: "", width: "", height: ""), weight: nil,
                                                               virtual: true,
                                                               categories: [],
                                                               tags: [])
    }
}
