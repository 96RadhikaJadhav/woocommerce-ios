import Storage
import Yosemite

/// Reflects the UI state associated with a stats version.
///
/// - initial: UI with the initial stats version from preferences in storage
enum StatsVersionState: Equatable {
    /// if initial(v3) = then show banner “Upgrade to keep seeing your stats”
    /// if initial(v4) = then default to stats
    case initial(statsVersion: StatsVersion)
}

/// Coordinates the stats version state changes from app settings and availability stores, and v3/v4 banner actions.
///
final class StatsVersionStateCoordinator {
    typealias StateChangeCallback = (_ previousState: StatsVersionState?, _ currentState: StatsVersionState) -> Void
    /// Called when stats version UI state is set.
    var onStateChange: StateChangeCallback?

    private let siteID: Int64

    private var state: StatsVersionState? {
        didSet {
            if let state = state {
                onStateChange?(oldValue, state)
            }
        }
    }

    /// Initializes `StatsVersionStateCoordinator` for a site ID.
    ///
    /// - Parameters:
    ///   - siteID: the ID of a site/store where the stats version is concerned.
    init(siteID: Int64) {
        self.siteID = siteID
    }

    func loadLastShownVersionAndCheckV4Eligibility() {
        // Load saved stats version from app settings
        let lastShownStatsVersionAction = AppSettingsAction.loadInitialStatsVersionToShow(siteID: siteID) { [weak self] initialStatsVersion in
            guard let self = self else {
                return
            }

            let lastStatsVersion: StatsVersion = initialStatsVersion ?? StatsVersion.v3
            let state = StatsVersionState.initial(statsVersion: lastStatsVersion)
            self.state = state

            // Execute network request to check if the API supports the V4 stats
            let action = AvailabilityAction.checkStatsV4Availability(siteID: self.siteID) { [weak self] isStatsV4Available in
                guard let self = self else {
                    return
                }
                let statsVersion: StatsVersion = isStatsV4Available ? .v4: .v3

                // Sets eligible stats version to app settings.
                let setEligibleStatsVersionAction = AppSettingsAction.setStatsVersionEligible(siteID: self.siteID, statsVersion: statsVersion)
                ServiceLocator.stores.dispatch(setEligibleStatsVersionAction)

                let nextState = StatsVersionState.initial(statsVersion: statsVersion)
                if nextState != self.state {
                    self.state = nextState
                }
            }
            ServiceLocator.stores.dispatch(action)
        }
        ServiceLocator.stores.dispatch(lastShownStatsVersionAction)
    }
}
