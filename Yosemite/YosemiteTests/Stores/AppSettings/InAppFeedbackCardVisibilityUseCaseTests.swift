import XCTest

@testable import Yosemite
import struct Storage.GeneralAppSettings

final class InAppFeedbackCardVisibilityUseCaseTests: XCTestCase {

    private var dateFormatter: DateFormatter!
    private var calendar: Calendar!
    private var fileManager: MockupFileManager!

    override func setUp() {
        super.setUp()
        dateFormatter = DateFormatter.Defaults.iso8601
        calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = dateFormatter.timeZone
        fileManager = MockupFileManager()
    }

    override func tearDown() {
        fileManager = MockupFileManager()
        calendar = nil
        dateFormatter = nil
        super.tearDown()
    }

    func test_shouldBeVisible_is_false_if_installationDate_is_less_than_90_days_ago() throws {
        // Given
        let installationDate = try date(from: "2020-08-08T00:00:00Z")
        let currentDate = try date(from: "2020-11-05T23:59:59Z")
        let settings = GeneralAppSettings(installationDate: installationDate, lastFeedbackDate: nil)

        fileManager.whenRetrievingAttributesOfItem(atPath: try documentDirectoryURL().path, thenReturn: [:])

        let useCase = InAppFeedbackCardVisibilityUseCase(settings: settings, fileManager: fileManager, calendar: calendar)

        // When
        let shouldBeVisible = try useCase.shouldBeVisible(currentDate: currentDate)

        // Then
        XCTAssertFalse(shouldBeVisible)
    }

    func test_shouldBeVisible_is_false_if_lastFeedback_is_less_than_180_days_ago() throws {
        // Given
        let installationDate = try date(from: "2020-08-08T00:00:00Z")
        let lastFeedbackDate = try date(from: "2020-11-06T00:00:00Z")
        let currentDate = try date(from: "2021-05-04T23:59:59Z")
        let settings = GeneralAppSettings(installationDate: installationDate, lastFeedbackDate: lastFeedbackDate)

        fileManager.whenRetrievingAttributesOfItem(atPath: try documentDirectoryURL().path, thenReturn: [:])

        let useCase = InAppFeedbackCardVisibilityUseCase(settings: settings, fileManager: fileManager, calendar: calendar)

        // When
        let shouldBeVisible = try useCase.shouldBeVisible(currentDate: currentDate)

        // Then
        XCTAssertFalse(shouldBeVisible)
    }

    func test_shouldBeVisible_is_true_if_lastFeedback_is_more_than_or_equal_to_180_days_ago() throws {
        // Given
        let installationDate = try date(from: "2020-08-08T00:00:00Z")
        let lastFeedbackDate = try date(from: "2020-11-06T00:00:00Z")
        let currentDate = try date(from: "2021-05-05T00:00:00Z")
        let settings = GeneralAppSettings(installationDate: installationDate, lastFeedbackDate: lastFeedbackDate)

        fileManager.whenRetrievingAttributesOfItem(atPath: try documentDirectoryURL().path, thenReturn: [:])

        let useCase = InAppFeedbackCardVisibilityUseCase(settings: settings, fileManager: fileManager, calendar: calendar)

        // When
        let shouldBeVisible = try useCase.shouldBeVisible(currentDate: currentDate)

        // Then
        XCTAssertTrue(shouldBeVisible)
    }
}

// MARK: - Utils

private extension InAppFeedbackCardVisibilityUseCaseTests {
    func date(from iso8601Date: String) throws -> Date {
        try XCTUnwrap(dateFormatter.date(from: iso8601Date))
    }

    func documentDirectoryURL() throws -> URL {
        try XCTUnwrap(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last)
    }
}
