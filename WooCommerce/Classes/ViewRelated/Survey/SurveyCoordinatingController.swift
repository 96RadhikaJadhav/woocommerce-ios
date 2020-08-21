import UIKit

/// Controls navigation for the in-app feedback flow. Meant to be presented modally
///
final class SurveyCoordinatingController: WooNavigationController {

    /// Used to present the Contact Support dialog
    private let zendeskManager: ZendeskManagerProtocol

    /// Factory that creates view controllers needed for this flow
    private let viewControllersFactory: SurveyViewControllersFactoryProtocol

    private let analytics: Analytics

    /// What kind of survey to present.
    private let survey: SurveyViewController.Source

    init(survey: SurveyViewController.Source,
         zendeskManager: ZendeskManagerProtocol = ZendeskManager.shared,
         viewControllersFactory: SurveyViewControllersFactoryProtocol = SurveyViewControllersFactory(),
         analytics: Analytics = ServiceLocator.analytics) {
        self.survey = survey
        self.zendeskManager = zendeskManager
        self.viewControllersFactory = viewControllersFactory
        self.analytics = analytics
        super.init(nibName: nil, bundle: nil)
        startSurveyNavigation()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Navigation
private extension SurveyCoordinatingController {

    /// Starts navigation with `SurveyViewController` as root view controller.
    ///
    func startSurveyNavigation() {
        let surveyViewController = viewControllersFactory.makeSurveyViewController(survey: survey) { [weak self] in
            self?.navigateToSurveySubmitted()
        }
        setViewControllers([surveyViewController], animated: false)
    }

    /// Proceeds navigation to `SurveySubmittedViewController`
    ///
    func navigateToSurveySubmitted() {
        let completionViewController = viewControllersFactory.makeSurveySubmittedViewController(onContactUsAction: { [weak self] in
            guard let self = self else {
                return
            }
            self.zendeskManager.showNewRequestIfPossible(from: self, with: nil)
        }, onBackToStoreAction: { [weak self] in
            self?.finishSurveyNavigation()
        })
        setViewControllers([completionViewController], animated: true)
    }

    /// Dismisses the flow modally
    ///
    func finishSurveyNavigation() {
        dismiss(animated: true)
    }
}
