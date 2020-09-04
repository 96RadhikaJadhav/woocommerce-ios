import XCTest
import TestKit

import Yosemite

@testable import WooCommerce

/// Test cases for `SwitchStoreNoticePresenter`.
///
final class SwitchStoreNoticePresenterTests: XCTestCase {

    private var sessionManager: SessionManager!
    private var noticePresenter: MockNoticePresenter!

    override func setUp() {
        super.setUp()

        sessionManager = SessionManager.testingInstance
        noticePresenter = MockNoticePresenter()
    }

    override func tearDown() {
        noticePresenter = nil
        sessionManager = nil

        super.tearDown()
    }

    func test_it_enqueues_a_notice_when_switching_stores() throws {
        // Given
        let site = makeSite()
        sessionManager.defaultSite = site

        let presenter = SwitchStoreNoticePresenter(sessionManager: sessionManager, noticePresenter: noticePresenter)

        assertEmpty(noticePresenter.queuedNotices)

        // When
        presenter.presentStoreSwitchedNotice(configuration: .switchingStores)

        // Then
        XCTAssertEqual(noticePresenter.queuedNotices.count, 1)

        let notice = try XCTUnwrap(noticePresenter.queuedNotices.first)
        assertThat(notice.title, contains: site.name)
    }

    func test_it_does_not_enqueue_a_notice_when_not_switching_stores() throws {
        // Given
        let presenter = SwitchStoreNoticePresenter(sessionManager: sessionManager, noticePresenter: noticePresenter)

        // When
        presenter.presentStoreSwitchedNotice(configuration: .login)

        // Then
        assertEmpty(noticePresenter.queuedNotices)
    }
}

// MARK: - Private Utils

private extension SwitchStoreNoticePresenterTests {
    func makeSite() -> Site {
        Site(siteID: 999,
             name: "Fugiat",
             description: "",
             url: "",
             plan: "",
             isWooCommerceActive: true,
             isWordPressStore: true,
             timezone: "",
             gmtOffset: 0)
    }
}
