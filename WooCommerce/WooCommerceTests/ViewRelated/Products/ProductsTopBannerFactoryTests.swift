import XCTest
import TestKit

@testable import WooCommerce

import Yosemite

final class ProductsTopBannerFactoryTests: XCTestCase {

    private var analyticsProvider: MockupAnalyticsProvider!
    private var analytics: WooAnalytics!
    private var storesManager: MockupStoresManager!

    override func setUp() {
        super.setUp()
        analyticsProvider = MockupAnalyticsProvider()
        analytics = WooAnalytics(analyticsProvider: analyticsProvider)
        storesManager = MockupStoresManager(sessionManager: .makeForTesting())
    }

    override func tearDown() {
        storesManager = nil
        analytics = nil
        analyticsProvider = nil
        super.tearDown()
    }

    func test_it_tracks_featureFeedbackBanner_gaveFeedback_event_when_giveFeedback_button_is_pressed() throws {
        // Given
        let bannerMirror = try makeBannerViewMirror()
        let giveFeedbackButton = try XCTUnwrap(bannerMirror.actionButtons.first)

        assertEmpty(analyticsProvider.receivedEvents)

        // When
        giveFeedbackButton.sendActions(for: .touchUpInside)

        // Then
        XCTAssertEqual(analyticsProvider.receivedEvents.count, 1)
        XCTAssertEqual(analyticsProvider.receivedEvents.first, "feature_feedback_banner")

        let properties = try XCTUnwrap(analyticsProvider.receivedProperties.first)
        XCTAssertEqual(properties["context"] as? String, "products_m3")
        XCTAssertEqual(properties["action"] as? String, "gave_feedback")
    }

    func test_it_tracks_featureFeedbackBanner_dismissed_event_when_dismiss_button_is_pressed() throws {
        // Given
        let bannerMirror = try makeBannerViewMirror()
        let dismissButton = try XCTUnwrap(bannerMirror.actionButtons.last)

        assertEmpty(analyticsProvider.receivedEvents)

        // When
        dismissButton.sendActions(for: .touchUpInside)

        // Then
        XCTAssertEqual(analyticsProvider.receivedEvents.count, 1)
        XCTAssertEqual(analyticsProvider.receivedEvents.first, "feature_feedback_banner")

        let properties = try XCTUnwrap(analyticsProvider.receivedProperties.first)
        XCTAssertEqual(properties["context"] as? String, "products_m3")
        XCTAssertEqual(properties["action"] as? String, "dismissed")
    }
}

private extension ProductsTopBannerFactoryTests {
    func makeBannerViewMirror() throws -> TopBannerViewMirror {
        storesManager.whenReceivingAction(ofType: AppSettingsAction.self) { action in
            if case let .loadProductsFeatureSwitch(onCompletion) = action {
                onCompletion(true)
            }
        }

        var banner: TopBannerView?
        waitForExpectation { exp in
            ProductsTopBannerFactory.topBanner(isExpanded: false,
                                               stores: storesManager,
                                               analytics: analytics,
                                               expandedStateChangeHandler: {

            }, onGiveFeedbackButtonPressed: {

            }, onDismissButtonPressed: {

            }) { aBanner in
                banner = aBanner
                exp.fulfill()
            }
        }

        return try TopBannerViewMirror(from: try XCTUnwrap(banner))
    }
}
