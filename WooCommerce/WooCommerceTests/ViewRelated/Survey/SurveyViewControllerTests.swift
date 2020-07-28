import Foundation
import WebKit
import XCTest

@testable import WooCommerce

/// Test cases for `SurveyViewController`.
///
final class SurveyViewControllerTests: XCTestCase {

    func testItLoadsTheCorrectInAppFeedbackSurvey() throws {
        // Given
        let viewController = SurveyViewController(survey: .inAppFeedback)

        // When
        _ = try XCTUnwrap(viewController.view)
        let mirror = try self.mirror(of: viewController)

        // Then
        XCTAssertTrue(mirror.webView.isLoading)
        XCTAssertEqual(mirror.webView.url, WooConstants.inAppFeedbackURL)
    }
}

// MARK: - Mirroring

private extension SurveyViewControllerTests {
    struct SurveyViewControllerMirror {
        let webView: WKWebView
    }

    func mirror(of viewController: SurveyViewController) throws -> SurveyViewControllerMirror {
        let mirror = Mirror(reflecting: viewController)
        return SurveyViewControllerMirror(webView: try XCTUnwrap(mirror.descendant("webView") as? WKWebView))
    }
}
