import XCTest

@testable import WooCommerce
@testable import Yosemite

final class ProductFormActionsFactoryTests: XCTestCase {
    func testViewModelForPhysicalSimpleProductWithoutImages() {
        // Arrange
        let product = MockProduct().product(downloadable: false,
                                            name: "woo",
                                            productType: .simple,
                                            virtual: false)
        let model = EditableProductModel(product: product)

        // Action
        let factory = ProductFormActionsFactory(product: model,
                                                formType: .edit,
                                                isEditProductsRelease3Enabled: false,
                                                isEditProductsRelease5Enabled: false)

        // Assert
        let expectedPrimarySectionActions: [ProductFormEditAction] = [.images, .name, .description]
        XCTAssertEqual(factory.primarySectionActions(), expectedPrimarySectionActions)

        let expectedSettingsSectionActions: [ProductFormEditAction] = [.priceSettings, .shippingSettings, .inventorySettings, .briefDescription]
        XCTAssertEqual(factory.settingsSectionActions(), expectedSettingsSectionActions)

        let expectedBottomSheetActions: [ProductFormBottomSheetAction] = []
        XCTAssertEqual(factory.bottomSheetActions(), expectedBottomSheetActions)
    }

    func testViewModelForVirtualSimpleProductWithImages() {
        // Arrange
        let product = MockProduct().product(downloadable: false,
                                            name: "woo",
                                            productType: .simple,
                                            virtual: true,
                                            images: sampleImages())
        let model = EditableProductModel(product: product)

        // Action
        let factory = ProductFormActionsFactory(product: model,
                                                formType: .edit,
                                                isEditProductsRelease3Enabled: false,
                                                isEditProductsRelease5Enabled: false)

        // Assert
        let expectedPrimarySectionActions: [ProductFormEditAction] = [.images, .name, .description]
        XCTAssertEqual(factory.primarySectionActions(), expectedPrimarySectionActions)

        let expectedSettingsSectionActions: [ProductFormEditAction] = [.priceSettings, .inventorySettings, .briefDescription]
        XCTAssertEqual(factory.settingsSectionActions(), expectedSettingsSectionActions)

        let expectedBottomSheetActions: [ProductFormBottomSheetAction] = []
        XCTAssertEqual(factory.bottomSheetActions(), expectedBottomSheetActions)
    }

    func testViewModelForDownloadableSimpleProduct() {
        // Arrange
        let product = MockProduct().product(downloadable: true,
                                            name: "woo",
                                            productType: .simple)
        let model = EditableProductModel(product: product)

        // Action
        let factory = ProductFormActionsFactory(product: model,
                                                formType: .edit,
                                                isEditProductsRelease3Enabled: false,
                                                isEditProductsRelease5Enabled: true)

        // Assert
        let expectedPrimarySectionActions: [ProductFormEditAction] = [.images, .name, .description]
        XCTAssertEqual(factory.primarySectionActions(), expectedPrimarySectionActions)

        let expectedSettingsSectionActions: [ProductFormEditAction] = [.priceSettings, .inventorySettings, .downloadableFiles, .briefDescription]
        XCTAssertEqual(factory.settingsSectionActions(), expectedSettingsSectionActions)

        let expectedBottomSheetActions: [ProductFormBottomSheetAction] = []
        XCTAssertEqual(factory.bottomSheetActions(), expectedBottomSheetActions)
    }

    func testViewModelForVirtualSimpleProduct() {
        // Arrange
        let product = MockProduct().product(downloadable: false,
                                            name: "woo",
                                            productType: .simple,
                                            virtual: true)
        let model = EditableProductModel(product: product)

        // Action
        let factory = ProductFormActionsFactory(product: model,
                                                formType: .edit,
                                                isEditProductsRelease3Enabled: false,
                                                isEditProductsRelease5Enabled: false)

        // Assert
        let expectedPrimarySectionActions: [ProductFormEditAction] = [.images, .name, .description]
        XCTAssertEqual(factory.primarySectionActions(), expectedPrimarySectionActions)

        let expectedSettingsSectionActions: [ProductFormEditAction] = [.priceSettings, .inventorySettings, .briefDescription]
        XCTAssertEqual(factory.settingsSectionActions(), expectedSettingsSectionActions)

        let expectedBottomSheetActions: [ProductFormBottomSheetAction] = []
        XCTAssertEqual(factory.bottomSheetActions(), expectedBottomSheetActions)
    }
}

private extension ProductFormActionsFactoryTests {
    func sampleImages() -> [ProductImage] {
        let image1 = ProductImage(imageID: 19,
                                  dateCreated: Date(),
                                  dateModified: Date(),
                                  src: "https://photo.jpg",
                                  name: "Tshirt",
                                  alt: "")
        return [image1]
    }
}
