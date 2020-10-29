import UIKit
import WebKit
import class Networking.UserAgent

/// Outputs of the the SurveyViewController
///
protocol SurveyViewControllerOutputs: UIViewController {
    /// Handler invoked when the survey has been completed
    ///
    var onCompletion: () -> Void { get }
}

/// Shows a web-based survey
///
final class SurveyViewController: UIViewController, SurveyViewControllerOutputs {

    /// Internal web view to render the survey
    ///
    @IBOutlet private weak var webView: WKWebView!

    /// Survey configuration provided by the consumer
    ///
    private let survey: Source

    /// Handler invoked when the survey has been completed
    ///
    let onCompletion: () -> Void

    /// Loading view displayed while the survey loads
    ///
    private let loadingView = SurveyLoadingView()

    init(survey: Source, onCompletion: @escaping () -> Void) {
        self.survey = survey
        self.onCompletion = onCompletion
        super.init(nibName: Self.nibName, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        addCloseNavigationBarButton()
        addLoadingView()
        configureAndLoadSurvey()
    }

    private func configureAndLoadSurvey() {
        title = survey.title

        let request = URLRequest(url: survey.url)
        webView.customUserAgent = UserAgent.defaultUserAgent
        webView.load(request)
        webView.navigationDelegate = self
    }

    /// Adds a loading view to the screen pinned at the center
    ///
    private func addLoadingView() {
        loadingView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(loadingView)
        view.pinSubviewAtCenter(loadingView)
    }

    /// Removes the loading view from the screen with a fade out animaition
    ///
    private func removeLoadingView() {
        loadingView.fadeOut { [weak self] _ in
            self?.loadingView.removeFromSuperview()
        }
    }
}

// MARK: Survey Configuration
//
extension SurveyViewController {
    enum Source {
        case inAppFeedback
        case productsM4Feedback

        fileprivate var url: URL {
            switch self {
            case .inAppFeedback:
                return WooConstants.URLs.inAppFeedback
                    .asURL()
                    .tagPlatform()

            case .productsM4Feedback:
                return WooConstants.URLs.productsM4Feedback
                    .asURL()
                    .tagPlatform()
                    .tagProductMilestone()
            }
        }

        fileprivate var title: String {
            switch self {
            case .inAppFeedback:
                return NSLocalizedString("How can we improve?", comment: "Title on the navigation bar for the in-app feedback survey")
            case .productsM4Feedback:
                return NSLocalizedString("Give feedback", comment: "Title on the navigation bar for the products feedback survey")
            }
        }

        /// The corresponding `FeedbackContext` for event tracking purposes.
        var feedbackContextForEvents: WooAnalyticsEvent.FeedbackContext {
            switch self {
            case .inAppFeedback:
                return .general
            case .productsM4Feedback:
                return .productsM4
            }
        }
    }
}

// MARK: WebView Delegate
//
extension SurveyViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {

        defer {
            decisionHandler(.allow)
        }

        // To consider the survey as completed, the following conditions need to occur:
        // - Survey Form is submitted.
        // - The request URL contains a `msg` parameter key with `done` as it's value
        //
        guard case .formSubmitted = navigationAction.navigationType,
            let url = navigationAction.request.url,
            let queryItems = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems,
            let surveyMessageValue = queryItems.first(where: { $0.name == Constants.surveyMessageParameterKey })?.value else {
                return
        }

        if surveyMessageValue == Constants.surveyCompletionParameterValue {
            onCompletion()
        }
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation) {
        removeLoadingView()
    }
}
// MARK: Survey Tags
//
extension URL {
    func tagPlatform() -> URL {
        appendingQueryItem(URLQueryItem(name: Tags.surveyRequestPlatformTag, value: Tags.surveyRequestPlatformValue))
    }

    func tagProductMilestone() -> URL {
        appendingQueryItem(URLQueryItem(name: Tags.surveyRequestProductMilestoneTag, value: Tags.surveyRequestProductMilestoneValue))
    }

    private func appendingQueryItem(_ queryItem: URLQueryItem) -> URL {
        guard var urlComponents = URLComponents(url: self, resolvingAgainstBaseURL: false) else {
            assertionFailure("Cannot create URL components from \(self)")
            return self
        }
        let queryItems: [URLQueryItem] = urlComponents.queryItems ?? []
        urlComponents.queryItems = queryItems + [queryItem]
        guard let url = try? urlComponents.asURL() else {
            assertionFailure("Cannot convert URL components to URL: \(urlComponents)")
            return self
        }
        return url
    }

    private enum Tags {
        static let surveyRequestPlatformValue = "ios"
        static let surveyRequestPlatformTag = "woo-mobile-platform"

        static let surveyRequestProductMilestoneValue = "4"
        static let surveyRequestProductMilestoneTag = "product_milestone"
    }
}

// MARK: Constants
//
private extension SurveyViewController {
    enum Constants {
        static let surveyMessageParameterKey = "msg"
        static let surveyCompletionParameterValue = "done"
    }
}
