import Photos
import XCTest

@testable import WooCommerce
import Yosemite

/// Unit tests for update functions in `ProductFormViewModel`.
final class ProductFormViewModel_UpdatesTests: XCTestCase {
    func testUpdatingName() {
        // Arrange
        let product = MockProduct().product(name: "Test")
        let productImageActionHandler = ProductImageActionHandler(siteID: 0, product: product)
        let viewModel = ProductFormViewModel(product: product,
                                             productImageActionHandler: productImageActionHandler,
                                             isEditProductsRelease2Enabled: true,
                                             isEditProductsRelease3Enabled: false)

        // Action
        let newName = "<p> cool product </p>"
        viewModel.updateName(newName)

        // Assert
        XCTAssertEqual(viewModel.product.name, newName)
    }

    func testUpdatingDescription() {
        // Arrange
        let product = MockProduct().product(fullDescription: "Test")
        let productImageActionHandler = ProductImageActionHandler(siteID: 0, product: product)
        let viewModel = ProductFormViewModel(product: product,
                                             productImageActionHandler: productImageActionHandler,
                                             isEditProductsRelease2Enabled: true,
                                             isEditProductsRelease3Enabled: false)

        // Action
        let newDescription = "<p> cool product </p>"
        viewModel.updateDescription(newDescription)

        // Assert
        XCTAssertEqual(viewModel.product.fullDescription, newDescription)
    }

    func testUpdatingShippingSettings() {
        // Arrange
        let product = MockProduct().product()
        let productImageActionHandler = ProductImageActionHandler(siteID: 0, product: product)
        let viewModel = ProductFormViewModel(product: product,
                                             productImageActionHandler: productImageActionHandler,
                                             isEditProductsRelease2Enabled: true,
                                             isEditProductsRelease3Enabled: false)

        // Action
        let newWeight = "9999.88"
        let newDimensions = ProductDimensions(length: "122", width: "333", height: "")
        let newShippingClass = ProductShippingClass(count: 2020,
                                                    descriptionHTML: "Arriving in 2 days!",
                                                    name: "2 Days",
                                                    shippingClassID: 2022,
                                                    siteID: product.siteID,
                                                    slug: "2-days")
        viewModel.updateShippingSettings(weight: newWeight, dimensions: newDimensions, shippingClass: newShippingClass)

        // Assert
        XCTAssertEqual(viewModel.product.fullDescription, product.fullDescription)
        XCTAssertEqual(viewModel.product.name, product.name)
        XCTAssertEqual(viewModel.product.weight, newWeight)
        XCTAssertEqual(viewModel.product.dimensions, newDimensions)
        XCTAssertEqual(viewModel.product.shippingClass, newShippingClass.slug)
        XCTAssertEqual(viewModel.product.shippingClassID, newShippingClass.shippingClassID)
        XCTAssertEqual(viewModel.product.productShippingClass, newShippingClass)
    }

    func testUpdatingPriceSettings() {
        // Arrange
        let product = MockProduct().product()
        let productImageActionHandler = ProductImageActionHandler(siteID: 0, product: product)
        let viewModel = ProductFormViewModel(product: product,
                                             productImageActionHandler: productImageActionHandler,
                                             isEditProductsRelease2Enabled: true,
                                             isEditProductsRelease3Enabled: false)

        // Action
        let newRegularPrice = "32.45"
        let newSalePrice = "20.00"
        let newDateOnSaleStart = Date()
        let newDateOnSaleEnd = newDateOnSaleStart.addingTimeInterval(86400)
        let newTaxStatus = ProductTaxStatus.taxable
        let newTaxClass = TaxClass(siteID: product.siteID, name: "Reduced rate", slug: "reduced-rate")
        viewModel.updatePriceSettings(regularPrice: newRegularPrice,
                                      salePrice: newSalePrice,
                                      dateOnSaleStart: newDateOnSaleStart,
                                      dateOnSaleEnd: newDateOnSaleEnd,
                                      taxStatus: newTaxStatus,
                                      taxClass: newTaxClass)

        // Assert
        XCTAssertEqual(viewModel.product.regularPrice, newRegularPrice)
        XCTAssertEqual(viewModel.product.salePrice, newSalePrice)
        XCTAssertEqual(viewModel.product.dateOnSaleStart, newDateOnSaleStart)
        XCTAssertEqual(viewModel.product.dateOnSaleEnd, newDateOnSaleEnd)
        XCTAssertEqual(viewModel.product.taxStatusKey, newTaxStatus.rawValue)
        XCTAssertEqual(viewModel.product.taxClass, newTaxClass.slug)
    }

    func testUpdatingInventorySettings() {
        // Arrange
        let product = MockProduct().product()
        let productImageActionHandler = ProductImageActionHandler(siteID: 0, product: product)
        let viewModel = ProductFormViewModel(product: product,
                                             productImageActionHandler: productImageActionHandler,
                                             isEditProductsRelease2Enabled: true,
                                             isEditProductsRelease3Enabled: false)

        // Action
        let newSKU = "94115"
        let newManageStock = !product.manageStock
        let newSoldIndividually = !product.soldIndividually
        let newStockQuantity = 17
        let newBackordersSetting = ProductBackordersSetting.allowedAndNotifyCustomer
        let newStockStatus = ProductStockStatus.onBackOrder
        viewModel.updateInventorySettings(sku: newSKU,
                                          manageStock: newManageStock,
                                          soldIndividually: newSoldIndividually,
                                          stockQuantity: newStockQuantity,
                                          backordersSetting: newBackordersSetting,
                                          stockStatus: newStockStatus)

        // Assert
        XCTAssertEqual(viewModel.product.sku, newSKU)
        XCTAssertEqual(viewModel.product.manageStock, newManageStock)
        XCTAssertEqual(viewModel.product.soldIndividually, newSoldIndividually)
        XCTAssertEqual(viewModel.product.stockQuantity, newStockQuantity)
        XCTAssertEqual(viewModel.product.backordersSetting, newBackordersSetting)
        XCTAssertEqual(viewModel.product.productStockStatus, newStockStatus)
    }

    func testUpdatingImages() {
        // Arrange
        let product = MockProduct().product()
        let productImageActionHandler = ProductImageActionHandler(siteID: 0, product: product)
        let viewModel = ProductFormViewModel(product: product,
                                             productImageActionHandler: productImageActionHandler,
                                             isEditProductsRelease2Enabled: true,
                                             isEditProductsRelease3Enabled: false)

        // Action
        let newImage = ProductImage(imageID: 17,
                                    dateCreated: date(with: "2018-01-26T21:49:45"),
                                    dateModified: date(with: "2018-01-26T21:50:11"),
                                    src: "https://somewebsite.com/shirt.jpg",
                                    name: "Tshirt",
                                    alt: "")
        let newImages = [newImage]
        viewModel.updateImages(newImages)

        // Assert
        XCTAssertEqual(viewModel.product.images, newImages)
    }

    func testUpdatingBriefDescription() {
        // Arrange
        let product = MockProduct().product()
        let productImageActionHandler = ProductImageActionHandler(siteID: 0, product: product)
        let viewModel = ProductFormViewModel(product: product,
                                             productImageActionHandler: productImageActionHandler,
                                             isEditProductsRelease2Enabled: true,
                                             isEditProductsRelease3Enabled: false)

        // Action
        let newBriefDescription = "<p> deal of the day! </p>"
        viewModel.updateBriefDescription(newBriefDescription)

        // Assert
        XCTAssertEqual(viewModel.product.briefDescription, newBriefDescription)
    }

    func testUpdatingProductSettings() {
        // Arrange
        let product = MockProduct().product()
        let productImageActionHandler = ProductImageActionHandler(siteID: 0, product: product)
        let viewModel = ProductFormViewModel(product: product,
                                             productImageActionHandler: productImageActionHandler,
                                             isEditProductsRelease2Enabled: true,
                                             isEditProductsRelease3Enabled: false)

        // Action
        let newStatus = "pending"
        let featured = true
        let password = ""
        let catalogVisibility = "search"
        let slug = "this-is-a-test"
        let purchaseNote = "This is a purchase note"
        let menuOrder = 0
        let productSettings = ProductSettings(status: .pending,
                                              featured: featured,
                                              password: password,
                                              catalogVisibility: .search,
                                              slug: slug,
                                              purchaseNote: purchaseNote,
                                              menuOrder: menuOrder)
        viewModel.updateProductSettings(productSettings)

        // Assert
        XCTAssertEqual(viewModel.product.statusKey, newStatus)
        XCTAssertEqual(viewModel.product.featured, featured)
        XCTAssertEqual(viewModel.product.catalogVisibilityKey, catalogVisibility)
        XCTAssertEqual(viewModel.product.slug, slug)
        XCTAssertEqual(viewModel.product.purchaseNote, purchaseNote)
        XCTAssertEqual(viewModel.product.menuOrder, menuOrder)
    }
}

private extension ProductFormViewModel_UpdatesTests {
    func date(with dateString: String) -> Date {
        guard let date = DateFormatter.Defaults.dateTimeFormatter.date(from: dateString) else {
            return Date()
        }
        return date
    }
}
