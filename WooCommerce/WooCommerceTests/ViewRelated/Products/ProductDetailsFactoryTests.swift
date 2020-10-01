import XCTest
@testable import WooCommerce

final class ProductDetailsFactoryTests: XCTestCase {
    // MARK: Simple product type

    func testFactoryCreatesProductFormForSimpleProductWhenProductsFeatureSwitchIsOn() {
        // Arrange
        let mockStoresManager = MockProductsAppSettingsStoresManager(isProductsFeatureSwitchEnabled: true, sessionManager: SessionManager.testingInstance)

        let product = MockProduct().product(productType: .simple)

        let expectation = self.expectation(description: "Wait for loading Products feature switch from app settings")
        // Action
        ProductDetailsFactory.productDetails(product: product,
                                             presentationStyle: .navigationStack,
                                             stores: mockStoresManager,
                                             forceReadOnly: false) { viewController in
                                                // Assert
                                                XCTAssertTrue(viewController is ProductFormViewController<ProductFormViewModel>)
                                                expectation.fulfill()
        }
        waitForExpectations(timeout: Constants.expectationTimeout, handler: nil)
    }

    func testFactoryCreatesProductFormForSimpleProductWhenProductsFeatureSwitchIsOff() {
        // Arrange
        let mockStoresManager = MockProductsAppSettingsStoresManager(isProductsFeatureSwitchEnabled: false, sessionManager: SessionManager.testingInstance)

        let product = MockProduct().product(productType: .simple)

        let expectation = self.expectation(description: "Wait for loading Products feature switch from app settings")
        // Action
        ProductDetailsFactory.productDetails(product: product,
                                             presentationStyle: .navigationStack,
                                             stores: mockStoresManager,
                                             forceReadOnly: false) { viewController in
                                                // Assert
                                                XCTAssertTrue(viewController is ProductFormViewController<ProductFormViewModel>)
                                                expectation.fulfill()
        }
        waitForExpectations(timeout: Constants.expectationTimeout, handler: nil)
    }

    // MARK: External/affiliate product type

    func testFactoryCreatesProductFormForAffiliateProductWhenProductsRelease3IsOn() {
        // Arrange
        let mockStoresManager = MockProductsAppSettingsStoresManager(isProductsFeatureSwitchEnabled: true, sessionManager: SessionManager.testingInstance)

        let product = MockProduct().product(productType: .affiliate)
        let expectation = self.expectation(description: "Wait for loading Products feature switch from app settings")

        // Action
        ProductDetailsFactory.productDetails(product: product,
                                             presentationStyle: .navigationStack,
                                             stores: mockStoresManager,
                                             forceReadOnly: false) { viewController in
                                                // Assert
                                                XCTAssertTrue(viewController is ProductFormViewController<ProductFormViewModel>)
                                                expectation.fulfill()
        }
        waitForExpectations(timeout: Constants.expectationTimeout, handler: nil)
    }

    func testFactoryCreatesReadonlyProductDetailsForAffiliateProductWhenProductsRelease3IsOff() {
        // Arrange
        let mockStoresManager = MockProductsAppSettingsStoresManager(isProductsFeatureSwitchEnabled: false, sessionManager: SessionManager.testingInstance)
        let product = MockProduct().product(productType: .affiliate)
        let expectation = self.expectation(description: "Wait for loading Products feature switch from app settings")

        // Action
        ProductDetailsFactory.productDetails(product: product,
                                             presentationStyle: .navigationStack,
                                             stores: mockStoresManager,
                                             forceReadOnly: false) { viewController in
                                                // Assert
                                                XCTAssertTrue(viewController is ProductDetailsViewController)
                                                expectation.fulfill()
        }
        waitForExpectations(timeout: Constants.expectationTimeout, handler: nil)
    }

    // MARK: Grouped product type

    func testFactoryCreatesProductFormForGroupedProductWhenProductsRelease3IsOn() {
        // Arrange
        let mockStoresManager = MockProductsAppSettingsStoresManager(isProductsFeatureSwitchEnabled: true, sessionManager: SessionManager.testingInstance)
        let product = MockProduct().product(productType: .grouped)
        let expectation = self.expectation(description: "Wait for loading Products feature switch from app settings")

        // Action
        ProductDetailsFactory.productDetails(product: product,
                                             presentationStyle: .navigationStack,
                                             stores: mockStoresManager,
                                             forceReadOnly: false) { viewController in
                                                // Assert
                                                XCTAssertTrue(viewController is ProductFormViewController<ProductFormViewModel>)
                                                expectation.fulfill()
        }
        waitForExpectations(timeout: Constants.expectationTimeout, handler: nil)
    }

    func testFactoryCreatesReadonlyProductDetailsForGroupedProductWhenProductsRelease3IsOff() {
        // Arrange
        let mockStoresManager = MockProductsAppSettingsStoresManager(isProductsFeatureSwitchEnabled: false, sessionManager: SessionManager.testingInstance)
        let product = MockProduct().product(productType: .grouped)
        let expectation = self.expectation(description: "Wait for loading Products feature switch from app settings")

        // Action
        ProductDetailsFactory.productDetails(product: product,
                                             presentationStyle: .navigationStack,
                                             stores: mockStoresManager,
                                             forceReadOnly: false) { viewController in
                                                // Assert
                                                XCTAssertTrue(viewController is ProductDetailsViewController)
                                                expectation.fulfill()
        }
        waitForExpectations(timeout: Constants.expectationTimeout, handler: nil)
    }

    // MARK: Variable product type

    func testFactoryCreatesProductFormForVariableProductWhenProductsRelease3IsOn() {
        // Arrange
        let mockStoresManager = MockProductsAppSettingsStoresManager(isProductsFeatureSwitchEnabled: true, sessionManager: SessionManager.testingInstance)
        let product = MockProduct().product(productType: .variable)
        let expectation = self.expectation(description: "Wait for loading Products feature switch from app settings")

        // Action
        ProductDetailsFactory.productDetails(product: product,
                                             presentationStyle: .navigationStack,
                                             stores: mockStoresManager,
                                             forceReadOnly: false) { viewController in
                                                // Assert
                                                XCTAssertTrue(viewController is ProductFormViewController<ProductFormViewModel>)
                                                expectation.fulfill()
        }
        waitForExpectations(timeout: Constants.expectationTimeout, handler: nil)
    }

    func testFactoryCreatesReadonlyProductDetailsForVariableProductWhenProductsRelease3IsOff() {
        // Arrange
        let mockStoresManager = MockProductsAppSettingsStoresManager(isProductsFeatureSwitchEnabled: false, sessionManager: SessionManager.testingInstance)
        let product = MockProduct().product(productType: .variable)
        let expectation = self.expectation(description: "Wait for loading Products feature switch from app settings")

        // Action
        ProductDetailsFactory.productDetails(product: product,
                                             presentationStyle: .navigationStack,
                                             stores: mockStoresManager,
                                             forceReadOnly: false) { viewController in
                                                // Assert
                                                XCTAssertTrue(viewController is ProductDetailsViewController)
                                                expectation.fulfill()
        }
        waitForExpectations(timeout: Constants.expectationTimeout, handler: nil)
    }

    // MARK: Non-core product type

    func test_factory_creates_product_form_for_non_core_product_when_products_release3_is_on() {
        // Arrange
        let mockStoresManager = MockProductsAppSettingsStoresManager(isProductsFeatureSwitchEnabled: true, sessionManager: SessionManager.testingInstance)
        let product = MockProduct().product(productType: .custom("other"))

        // Action
        waitForExpectation { expectation in
            ProductDetailsFactory.productDetails(product: product,
                                                 presentationStyle: .navigationStack,
                                                 stores: mockStoresManager,
                                                 forceReadOnly: false) { viewController in
                                                    // Assert
                                                    XCTAssertTrue(viewController is ProductFormViewController<ProductFormViewModel>)
                                                    expectation.fulfill()
            }
        }
    }

    func test_factory_creates_product_form_for_non_core_product_when_products_release3_is_off() {
        // Arrange
        let mockStoresManager = MockProductsAppSettingsStoresManager(isProductsFeatureSwitchEnabled: false, sessionManager: SessionManager.testingInstance)
        let product = MockProduct().product(productType: .custom("other"))

        // Action
        waitForExpectation { expectation in
            ProductDetailsFactory.productDetails(product: product,
                                                 presentationStyle: .navigationStack,
                                                 stores: mockStoresManager,
                                                 forceReadOnly: false) { viewController in
                                                    // Assert
                                                    XCTAssertTrue(viewController is ProductDetailsViewController)
                                                    expectation.fulfill()
            }
        }
    }

    func test_factory_creates_readonly_product_details_for_product_when_forceReadOnly_is_on() {
        // Arrange
        let mockStoresManager = MockProductsAppSettingsStoresManager(isProductsFeatureSwitchEnabled: false, sessionManager: SessionManager.testingInstance)
        let product = MockProduct().product(productType: .simple)

        // Action
        waitForExpectation { expectation in
            ProductDetailsFactory.productDetails(product: product,
                                                 presentationStyle: .navigationStack,
                                                 stores: mockStoresManager,
                                                 forceReadOnly: true) { viewController in
                                                    // Assert
                                                    XCTAssertTrue(viewController is ProductDetailsViewController)
                                                    expectation.fulfill()
            }
        }
    }
}
