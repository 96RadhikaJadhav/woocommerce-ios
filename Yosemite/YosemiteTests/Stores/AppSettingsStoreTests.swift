import XCTest
@testable import Yosemite
@testable import Storage


/// Mock constants
///
private struct TestConstants {
    static let fileURL = Bundle(for: AppSettingsStoreTests.self)
        .url(forResource: "shipment-provider", withExtension: "plist")
    static let customFileURL = Bundle(for: AppSettingsStoreTests.self)
        .url(forResource: "custom-shipment-provider", withExtension: "plist")
    static let siteID: Int64 = 156590080
    static let providerName = "post.at"
    static let providerURL = "http://some.where"

    static let newSiteID: Int64 = 1234
    static let newProviderName = "Some provider"
    static let newProviderURL = "http://some.where"
}


/// AppSettingsStore unit tests
///
final class AppSettingsStoreTests: XCTestCase {
    /// Mockup Dispatcher!
    ///
    private var dispatcher: Dispatcher?

    /// Mockup Storage: InMemory
    ///
    private var storageManager: MockupStorageManager?

    /// Mockup File Storage: Load a plist in the test bundle
    ///
    private var fileStorage: MockInMemoryStorage?

    /// Test subject
    ///
    private var subject: AppSettingsStore?

    override func setUp() {
        super.setUp()
        dispatcher = Dispatcher()
        storageManager = MockupStorageManager()
        fileStorage = MockInMemoryStorage()
        subject = AppSettingsStore(dispatcher: dispatcher!, storageManager: storageManager!, fileStorage: fileStorage!)
        subject?.selectedProvidersURL = TestConstants.fileURL!
        subject?.customSelectedProvidersURL = TestConstants.customFileURL!
    }

    override func tearDown() {
        dispatcher = nil
        storageManager = nil
        fileStorage = nil
        subject = nil
        super.tearDown()
    }

    func testFileStorageIsRequestedToWriteWhenAddingANewShipmentProvider() {
        let expectation = self.expectation(description: "A write is requested")

        let action = AppSettingsAction.addTrackingProvider(siteID: TestConstants.newSiteID,
                                                           providerName: TestConstants.newProviderName) { error in
                                                            XCTAssertNil(error)

                                                            if self.fileStorage?.dataWriteIsHit == true {
                                                                expectation.fulfill()
                                                            }
        }

        subject?.onAction(action)

        waitForExpectations(timeout: 2, handler: nil)
    }

    func testFileStorageIsRequestedToWriteWhenAddingANewCustomShipmentProvider() {
        let expectation = self.expectation(description: "A write is requested")

        let action = AppSettingsAction.addCustomTrackingProvider(siteID: TestConstants.newSiteID,
                                                                 providerName: TestConstants.newProviderName,
                                                                 providerURL: TestConstants.newProviderURL) { error in
                                                            XCTAssertNil(error)

                                                            if self.fileStorage?.dataWriteIsHit == true {
                                                                expectation.fulfill()
                                                            }
        }

        subject?.onAction(action)

        waitForExpectations(timeout: 2, handler: nil)
    }

    func testFileStorageIsRequestedToWriteWhenAddingAShipmentProviderForExistingSite() {
        let expectation = self.expectation(description: "A write is requested")

        let action = AppSettingsAction.addTrackingProvider(siteID: TestConstants.siteID,
                                                           providerName: TestConstants.providerName) { error in
                                                            XCTAssertNil(error)

                                                            if self.fileStorage?.dataWriteIsHit == true {
                                                                expectation.fulfill()
                                                            }
        }

        subject?.onAction(action)

        waitForExpectations(timeout: 2, handler: nil)
    }

    func testFileStorageIsRequestedToWriteWhenAddingACustomShipmentProviderForExistingSite() {
        let expectation = self.expectation(description: "A write is requested")

        let action = AppSettingsAction.addCustomTrackingProvider(siteID: TestConstants.siteID,
                                                           providerName: TestConstants.providerName,
                                                           providerURL: TestConstants.providerURL) { error in
                                                            XCTAssertNil(error)

                                                            if self.fileStorage?.dataWriteIsHit == true {
                                                                expectation.fulfill()
                                                            }
        }

        subject?.onAction(action)

        waitForExpectations(timeout: 2, handler: nil)
    }

    func testAddingNewProviderToExistingSiteUpdatesFile() {
        let expectation = self.expectation(description: "File is updated")

        let action = AppSettingsAction
            .addTrackingProvider(siteID: TestConstants.siteID,
                                 providerName: TestConstants.newProviderName) { error in
                                    XCTAssertNil(error)
                                    let fileData = self.fileStorage?.data as? [PreselectedProvider]
                                    let updatedProvider = fileData?.filter({ $0.siteID == TestConstants.siteID}).first

                                    if updatedProvider?.providerName == TestConstants.newProviderName {
                                        expectation.fulfill()
                                    }

        }

        subject?.onAction(action)

        waitForExpectations(timeout: 2, handler: nil)
    }

    func testAddingNewCustomProviderToExistingSiteUpdatesFile() {
        let expectation = self.expectation(description: "File is updated")

        let action = AppSettingsAction
            .addCustomTrackingProvider(siteID: TestConstants.siteID,
                                 providerName: TestConstants.newProviderName,
                                 providerURL: TestConstants.newProviderURL) { error in
                                    XCTAssertNil(error)
                                    let fileData = self.fileStorage?.data as? [PreselectedProvider]
                                    let updatedProvider = fileData?.filter({ $0.siteID == TestConstants.siteID}).first

                                    if updatedProvider?.providerName == TestConstants.newProviderName {
                                        expectation.fulfill()
                                    }

        }

        subject?.onAction(action)

        waitForExpectations(timeout: 2, handler: nil)
    }

    func testRestoreResetProvidersHitsClearFile() {
        let expectation = self.expectation(description: "File is updated")

        let action = AppSettingsAction.resetStoredProviders { error in
            XCTAssertNil(error)

            if self.fileStorage?.deleteIsHit == true {
                expectation.fulfill()
            }
        }

        subject?.onAction(action)

        waitForExpectations(timeout: 2, handler: nil)
    }

    // MARK: - General App Settings

    func testItCanSaveTheAppInstallationDate() throws {
        // Given
        let date = Date(timeIntervalSince1970: 100)

        let existingSettings = GeneralAppSettings(installationDate: Date(timeIntervalSince1970: 4_810),
                                                  lastFeedbackDate: Date(timeIntervalSince1970: 9_971_311))
        try fileStorage?.write(existingSettings, to: expectedGeneralAppSettingsFileURL)

        // When
        var result: Result<Void, Error>?
        let action = AppSettingsAction.setInstallationDateIfNecessary(date: date) { aResult in
            result = aResult
        }
        subject?.onAction(action)

        // Then
        XCTAssertTrue(try XCTUnwrap(result).isSuccess)

        let savedSettings: GeneralAppSettings = try XCTUnwrap(fileStorage?.data(for: expectedGeneralAppSettingsFileURL))
        XCTAssertEqual(date, savedSettings.installationDate)

        // The other properties should be kept
        XCTAssertEqual(savedSettings.lastFeedbackDate, existingSettings.lastFeedbackDate)
    }

    func testItDoesNotSaveTheAppInstallationDateIfTheGivenDateIsNewer() throws {
        // Given
        let existingDate = Date(timeIntervalSince1970: 100)
        let newerDate = Date(timeIntervalSince1970: 101)

        try fileStorage?.deleteFile(at: expectedGeneralAppSettingsFileURL)

        // Save existingDate
        subject?.onAction(AppSettingsAction.setInstallationDateIfNecessary(date: existingDate, onCompletion: { _ in
            // noop
        }))

        // When
        // Save newerDate. This should be successful but the existingDate should be retained.
        var result: Result<Void, Error>?
        let action = AppSettingsAction.setInstallationDateIfNecessary(date: newerDate) { aResult in
            result = aResult
        }
        subject?.onAction(action)

        // Then
        XCTAssertTrue(try XCTUnwrap(result).isSuccess)

        let savedSettings: GeneralAppSettings = try XCTUnwrap(fileStorage?.data(for: expectedGeneralAppSettingsFileURL))
        XCTAssertEqual(existingDate, savedSettings.installationDate)
        XCTAssertNotEqual(newerDate, savedSettings.installationDate)
    }

    func testGivenNoExistingSettingsThenItCanSaveTheAppInstallationDate() throws {
        // Given
        let date = Date(timeIntervalSince1970: 100)

        try fileStorage?.deleteFile(at: expectedGeneralAppSettingsFileURL)

        // When
        var result: Result<Void, Error>?
        let action = AppSettingsAction.setInstallationDateIfNecessary(date: date) { aResult in
            result = aResult
        }
        subject?.onAction(action)

        // Then
        XCTAssertTrue(try XCTUnwrap(result).isSuccess)

        let savedSettings: GeneralAppSettings = try XCTUnwrap(fileStorage?.data(for: expectedGeneralAppSettingsFileURL))
        XCTAssertEqual(date, savedSettings.installationDate)
        XCTAssertNil(savedSettings.lastFeedbackDate)
    }

    func testItCanSaveTheLastFeedbackDate() throws {
        // Given
        let date = Date(timeIntervalSince1970: 300)

        let existingSettings = GeneralAppSettings(installationDate: Date(timeIntervalSince1970: 1),
                                                  lastFeedbackDate: Date(timeIntervalSince1970: 999))
        try fileStorage?.write(existingSettings, to: expectedGeneralAppSettingsFileURL)

        // When
        var result: Result<Void, Error>?
        let action = AppSettingsAction.setLastFeedbackDate(date: date) { aResult in
            result = aResult
        }
        subject?.onAction(action)

        // Then
        XCTAssertTrue(try XCTUnwrap(result).isSuccess)

        let savedSettings: GeneralAppSettings = try XCTUnwrap(fileStorage?.data(for: expectedGeneralAppSettingsFileURL))
        XCTAssertEqual(date, savedSettings.lastFeedbackDate)

        // The other properties should be kept
        XCTAssertEqual(savedSettings.installationDate, existingSettings.installationDate)
    }
}

// MARK: - Utils

private extension AppSettingsStoreTests {
    var expectedGeneralAppSettingsFileURL: URL {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        return documents!.appendingPathComponent("general-app-settings.plist")
    }
}
