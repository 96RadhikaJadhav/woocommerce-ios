import XCTest
import Storage
import Yosemite
@testable import WooCommerce

final class StatsVersionStateCoordinatorTests: XCTestCase {
    private var mockStoresManager: MockupStatsVersionStoresManager!

    override func tearDown() {
        mockStoresManager = nil
        super.tearDown()
    }

    func testWhenV4IsAvailableWhileNoStatsVersionWasShownBefore() {
        mockStoresManager = MockupStatsVersionStoresManager(sessionManager: SessionManager.testingInstance)
        mockStoresManager.isStatsV4Available = true
        ServiceLocator.setStores(mockStoresManager)

        let expectedStates: [StatsVersionState] = [.initial(statsVersion: .v3), .v3ShownV4Eligible]
        let expectation = self.expectation(description: "Wait for states to match")
        expectation.expectedFulfillmentCount = 1

        var states: [StatsVersionState] = []
        let stateCoordinator = StatsVersionStateCoordinator(siteID: 134)
        stateCoordinator.onStateChange = { _, state in
            states.append(state)
            if states.count >= expectedStates.count {
                XCTAssertEqual(states, expectedStates)
                expectation.fulfill()
            }
        }
        stateCoordinator.loadLastShownVersionAndCheckV4Eligibility()
        waitForExpectations(timeout: 0.1, handler: nil)
    }

    func testWhenV4IsUnavailableWhileNoStatsVersionWasShownBefore() {
        mockStoresManager = MockupStatsVersionStoresManager(sessionManager: SessionManager.testingInstance)
        mockStoresManager.isStatsV4Available = false
        ServiceLocator.setStores(mockStoresManager)

        let expectedStates: [StatsVersionState] = [.initial(statsVersion: .v3), .eligible(statsVersion: .v3)]
        let expectation = self.expectation(description: "Wait for states to match")
        expectation.expectedFulfillmentCount = 1

        var states: [StatsVersionState] = []
        let stateCoordinator = StatsVersionStateCoordinator(siteID: 134)
        stateCoordinator.onStateChange = { _, state in
            states.append(state)
            if states.count >= expectedStates.count {
                XCTAssertEqual(states, expectedStates)
                expectation.fulfill()
            }
        }
        stateCoordinator.loadLastShownVersionAndCheckV4Eligibility()
        waitForExpectations(timeout: 0.1, handler: nil)
    }

    /// Stats v3 --> v4
    func testWhenV4IsAvailableWhileStatsV3IsLastShown() {
        mockStoresManager = MockupStatsVersionStoresManager(initialStatsVersionLastShown: .v3,
                                                            sessionManager: SessionManager.testingInstance)
        mockStoresManager.isStatsV4Available = true
        ServiceLocator.setStores(mockStoresManager)

        let expectedStates: [StatsVersionState] = [.initial(statsVersion: .v3), .v3ShownV4Eligible]
        let expectation = self.expectation(description: "Wait for states to match")
        expectation.expectedFulfillmentCount = 1

        var states: [StatsVersionState] = []
        let stateCoordinator = StatsVersionStateCoordinator(siteID: 134)
        stateCoordinator.onStateChange = { _, state in
            states.append(state)
            if states.count >= expectedStates.count {
                XCTAssertEqual(states, expectedStates)
                expectation.fulfill()
            }
        }
        stateCoordinator.loadLastShownVersionAndCheckV4Eligibility()
        waitForExpectations(timeout: 0.1, handler: nil)
    }

    /// Stats v3 --> v3
    func testWhenV4IsUnavailableWhileStatsV3IsLastShown() {
        mockStoresManager = MockupStatsVersionStoresManager(initialStatsVersionLastShown: .v3,
                                                            sessionManager: SessionManager.testingInstance)
        mockStoresManager.isStatsV4Available = false
        ServiceLocator.setStores(mockStoresManager)

        let expectedStates: [StatsVersionState] = [.initial(statsVersion: .v3), .eligible(statsVersion: .v3)]
        let expectation = self.expectation(description: "Wait for states to match")
        expectation.expectedFulfillmentCount = 1

        var states: [StatsVersionState] = []
        let stateCoordinator = StatsVersionStateCoordinator(siteID: 134)
        stateCoordinator.onStateChange = { _, state in
            states.append(state)
            if states.count >= expectedStates.count {
                XCTAssertEqual(states, expectedStates)
                expectation.fulfill()
            }
        }
        stateCoordinator.loadLastShownVersionAndCheckV4Eligibility()
        waitForExpectations(timeout: 0.1, handler: nil)
    }

    /// Stats v4 --> v3
    func testWhenV4IsUnavailableWhileStatsV4IsLastShown() {
        mockStoresManager = MockupStatsVersionStoresManager(initialStatsVersionLastShown: .v4,
                                                            sessionManager: SessionManager.testingInstance)
        mockStoresManager.isStatsV4Available = false
        ServiceLocator.setStores(mockStoresManager)

        let expectedStates: [StatsVersionState] = [.initial(statsVersion: .v4), .v4RevertedToV3]
        let expectation = self.expectation(description: "Wait for states to match")
        expectation.expectedFulfillmentCount = 1

        var states: [StatsVersionState] = []
        let stateCoordinator = StatsVersionStateCoordinator(siteID: 134)
        stateCoordinator.onStateChange = { _, state in
            states.append(state)
            if states.count >= expectedStates.count {
                XCTAssertEqual(states, expectedStates)
                expectation.fulfill()
            }
        }
        stateCoordinator.loadLastShownVersionAndCheckV4Eligibility()
        waitForExpectations(timeout: 0.1, handler: nil)
    }

    /// V4 --> v4
    func testWhenV4IsAvailableWhileStatsV4IsLastShown() {
        mockStoresManager = MockupStatsVersionStoresManager(initialStatsVersionLastShown: .v4,
                                                            sessionManager: SessionManager.testingInstance)
        mockStoresManager.isStatsV4Available = true
        ServiceLocator.setStores(mockStoresManager)

        let expectedStates: [StatsVersionState] = [.initial(statsVersion: .v4), .eligible(statsVersion: .v4)]
        let expectation = self.expectation(description: "Wait for states to match")
        expectation.expectedFulfillmentCount = 1

        var states: [StatsVersionState] = []
        let stateCoordinator = StatsVersionStateCoordinator(siteID: 134)
        stateCoordinator.onStateChange = { _, state in
            states.append(state)
            if states.count >= expectedStates.count {
                XCTAssertEqual(states, expectedStates)
                expectation.fulfill()
            }
        }
        stateCoordinator.loadLastShownVersionAndCheckV4Eligibility()
        waitForExpectations(timeout: 0.1, handler: nil)
    }

    /// V3 --> v4 and then dismisses banner
    func testDismissV3ToV4Banner() {
        mockStoresManager = MockupStatsVersionStoresManager(initialStatsVersionLastShown: .v3,
                                                            sessionManager: SessionManager.testingInstance)
        mockStoresManager.isStatsV4Available = true
        ServiceLocator.setStores(mockStoresManager)

        let expectedStates: [StatsVersionState] = [.initial(statsVersion: .v3), .v3ShownV4Eligible, .eligible(statsVersion: .v3)]
        let expectation = self.expectation(description: "Wait for states to match")
        expectation.expectedFulfillmentCount = 1

        var states: [StatsVersionState] = []
        let stateCoordinator = StatsVersionStateCoordinator(siteID: 134)
        stateCoordinator.onStateChange = { _, state in
            states.append(state)
            if states.count >= expectedStates.count {
                XCTAssertEqual(states, expectedStates)
                expectation.fulfill()
            }
        }
        stateCoordinator.loadLastShownVersionAndCheckV4Eligibility()

        // Dismiss v3 to v4 banner.
        stateCoordinator.dismissV3ToV4Banner()

        waitForExpectations(timeout: 0.1, handler: nil)
    }

    /// V3 --> v4 and then dismisses banner
    func testUpgradeFromV3ToV4() {
        mockStoresManager = MockupStatsVersionStoresManager(initialStatsVersionLastShown: .v3,
                                                            sessionManager: SessionManager.testingInstance)
        mockStoresManager.isStatsV4Available = true
        ServiceLocator.setStores(mockStoresManager)

        let expectedStates: [StatsVersionState] = [.initial(statsVersion: .v3), .v3ShownV4Eligible, .eligible(statsVersion: .v4)]
        let expectation = self.expectation(description: "Wait for states to match")
        expectation.expectedFulfillmentCount = 1

        var states: [StatsVersionState] = []
        let stateCoordinator = StatsVersionStateCoordinator(siteID: 134)
        stateCoordinator.onStateChange = { _, state in
            states.append(state)
            if states.count >= expectedStates.count {
                XCTAssertEqual(states, expectedStates)
                expectation.fulfill()
            }
        }
        stateCoordinator.loadLastShownVersionAndCheckV4Eligibility()

        // Upgrade to v4 from banner.
        stateCoordinator.statsV4ButtonPressed()

        waitForExpectations(timeout: 0.1, handler: nil)
    }

    /// V4 --> v3 and then dismisses banner
    func testDismissV4ToV3Banner() {
        mockStoresManager = MockupStatsVersionStoresManager(initialStatsVersionLastShown: .v4,
                                                            sessionManager: SessionManager.testingInstance)
        mockStoresManager.isStatsV4Available = false
        ServiceLocator.setStores(mockStoresManager)

        let expectedStates: [StatsVersionState] = [.initial(statsVersion: .v4), .v4RevertedToV3, .eligible(statsVersion: .v3)]
        let expectation = self.expectation(description: "Wait for states to match")
        expectation.expectedFulfillmentCount = 1

        var states: [StatsVersionState] = []
        let stateCoordinator = StatsVersionStateCoordinator(siteID: 134)
        stateCoordinator.onStateChange = { _, state in
            states.append(state)
            if states.count >= expectedStates.count {
                XCTAssertEqual(states, expectedStates)
                expectation.fulfill()
            }
        }
        stateCoordinator.loadLastShownVersionAndCheckV4Eligibility()

        // Dismiss v4 to v3 banner.
        stateCoordinator.dismissV4ToV3Banner()

        waitForExpectations(timeout: 0.1, handler: nil)
    }

    /// Reloads (V3 --> v4), v4 remains available, then reloads again
    func testUpgradeFromV3ToV4ThenReload() {
        mockStoresManager = MockupStatsVersionStoresManager(initialStatsVersionLastShown: .v3,
                                                            sessionManager: SessionManager.testingInstance)
        mockStoresManager.isStatsV4Available = true
        ServiceLocator.setStores(mockStoresManager)

        let expectedStates: [StatsVersionState] = [
            // First reload
            .initial(statsVersion: .v3), .v3ShownV4Eligible,
            // Second reload
            .v3ShownV4Eligible]
        let expectation = self.expectation(description: "Wait for states to match")
        expectation.expectedFulfillmentCount = 1

        var states: [StatsVersionState] = []
        let stateCoordinator = StatsVersionStateCoordinator(siteID: 134)
        stateCoordinator.onStateChange = { _, state in
            states.append(state)
            if states.count >= expectedStates.count {
                XCTAssertEqual(states, expectedStates)
                expectation.fulfill()
            }
        }
        stateCoordinator.loadLastShownVersionAndCheckV4Eligibility()
        stateCoordinator.loadLastShownVersionAndCheckV4Eligibility()

        waitForExpectations(timeout: 0.1, handler: nil)
    }

    /// Reloads (V3 --> v4), v4 becomes unavailable, then reloads again
    func testUpgradeFromV3ToV4ThenV4IsUnavailableThenReload() {
        mockStoresManager = MockupStatsVersionStoresManager(initialStatsVersionLastShown: .v3,
                                                            sessionManager: SessionManager.testingInstance)
        mockStoresManager.isStatsV4Available = true
        ServiceLocator.setStores(mockStoresManager)

        let expectedStates: [StatsVersionState] = [
            // First reload
            .initial(statsVersion: .v3), .v3ShownV4Eligible,
            // Second reload
            .v3ShownV4Eligible, .v4RevertedToV3]
        let expectation = self.expectation(description: "Wait for states to match")
        expectation.expectedFulfillmentCount = 1

        var states: [StatsVersionState] = []
        let stateCoordinator = StatsVersionStateCoordinator(siteID: 134)
        stateCoordinator.onStateChange = { _, state in
            states.append(state)
            if states.count >= expectedStates.count {
                XCTAssertEqual(states, expectedStates)
                expectation.fulfill()
            }
        }
        stateCoordinator.loadLastShownVersionAndCheckV4Eligibility()

        mockStoresManager.isStatsV4Available = false
        stateCoordinator.loadLastShownVersionAndCheckV4Eligibility()

        waitForExpectations(timeout: 0.1, handler: nil)
    }

    // Reloads (V4 --> v3), v4 remains unavailable, then reloads again
    func testWhenV4IsUnavailableWhileStatsV4IsLastShownThenReload() {
        mockStoresManager = MockupStatsVersionStoresManager(initialStatsVersionLastShown: .v4,
                                                            sessionManager: SessionManager.testingInstance)
        mockStoresManager.isStatsV4Available = false
        ServiceLocator.setStores(mockStoresManager)

        let expectedStates: [StatsVersionState] = [
            // First reload
            .initial(statsVersion: .v4), .v4RevertedToV3,
            // Second reload
            .v4RevertedToV3]
        let expectation = self.expectation(description: "Wait for states to match")
        expectation.expectedFulfillmentCount = 1

        var states: [StatsVersionState] = []
        let stateCoordinator = StatsVersionStateCoordinator(siteID: 134)
        stateCoordinator.onStateChange = { _, state in
            states.append(state)
            if states.count >= expectedStates.count {
                XCTAssertEqual(states, expectedStates)
                expectation.fulfill()
            }
        }
        stateCoordinator.loadLastShownVersionAndCheckV4Eligibility()

        mockStoresManager.statsVersionLastShown = .v3
        stateCoordinator.loadLastShownVersionAndCheckV4Eligibility()

        waitForExpectations(timeout: 0.1, handler: nil)
    }

    // Reloads (V4 --> v3), v4 becomes available, then reloads again
    func testWhenV4IsUnavailableWhileStatsV4IsLastShownThenV4IsAvailableThenReload() {
        mockStoresManager = MockupStatsVersionStoresManager(initialStatsVersionLastShown: .v4,
                                                            sessionManager: SessionManager.testingInstance)
        mockStoresManager.isStatsV4Available = false
        ServiceLocator.setStores(mockStoresManager)

        let expectedStates: [StatsVersionState] = [
            // First reload
            .initial(statsVersion: .v4), .v4RevertedToV3,
            // Second reload
            .v4RevertedToV3, .v3ShownV4Eligible]
        let expectation = self.expectation(description: "Wait for states to match")
        expectation.expectedFulfillmentCount = 1

        var states: [StatsVersionState] = []
        let stateCoordinator = StatsVersionStateCoordinator(siteID: 134)
        stateCoordinator.onStateChange = { _, state in
            states.append(state)
            if states.count >= expectedStates.count {
                XCTAssertEqual(states, expectedStates)
                expectation.fulfill()
            }
        }
        stateCoordinator.loadLastShownVersionAndCheckV4Eligibility()

        mockStoresManager.statsVersionLastShown = .v3
        mockStoresManager.isStatsV4Available = true
        stateCoordinator.loadLastShownVersionAndCheckV4Eligibility()

        waitForExpectations(timeout: 0.1, handler: nil)
    }
}