import XCTest
import Gridicons
@testable import WooCommerce

final class IconsTests: XCTestCase {
    func testAddOutlineIconIsNotNil() {
        XCTAssertNotNil(UIImage.addOutlineImage)
    }

    func testNoticeImageIsNotNil() {
        XCTAssertNotNil(UIImage.noticeImage)
    }

    func testAsideIconIsNotNil() {
        XCTAssertNotNil(UIImage.asideImage)
    }

    func testBellIconIsNotNil() {
        XCTAssertNotNil(UIImage.bellImage)
    }

    func testShortDescriptionImageIconIsNotNil() {
        XCTAssertNotNil(UIImage.shortDescriptionImage)
    }

    func testCameraIconIsNotNil() {
        XCTAssertNotNil(UIImage.cameraImage)
    }

    func testAddImageIconIsNotNil() {
        XCTAssertNotNil(UIImage.addImage)
    }

    func testCheckmarkImageIconIsNotNil() {
        XCTAssertNotNil(UIImage.checkmarkImage)
    }

    func testCheckmarkInCellImageOverlayIsNotNil() {
        XCTAssertNotNil(UIImage.checkmarkInCellImageOverlay)
    }

    func testCheckmarkStyledImageIconIsNotNil() {
        XCTAssertNotNil(UIImage.checkmarkStyledImage)
    }

    func testChevronImageIconIsNotNil() {
        XCTAssertNotNil(UIImage.chevronImage)
    }

    func testChevronDownImageIconIsNotNil() {
        XCTAssertNotNil(UIImage.chevronDownImage)
    }

    func testChevronUpImageIconIsNotNil() {
        XCTAssertNotNil(UIImage.chevronUpImage)
    }

    func testCloseButtonIconIsNotNil() {
        XCTAssertNotNil(UIImage.closeButton)
    }

    func testCogImageIconIsNotNil() {
        XCTAssertNotNil(UIImage.cogImage)
    }

    func testCommentImageIconIsNotNil() {
        XCTAssertNotNil(UIImage.commentImage)
    }

    func testDeleteImageIconIsNotNil() {
        XCTAssertNotNil(UIImage.deleteImage)
    }

    func testDeleteCellImageIconIsNotNil() {
        XCTAssertNotNil(UIImage.deleteCellImage)
    }

    func testDeleteCellImageIconDefaultSize() {
        let deleteCellImage = UIImage.deleteCellImage
        XCTAssertEqual(deleteCellImage.size, CGSize(width: 22, height: 22))
    }

    func testEllipsisImageIconIsNotNil() {
        XCTAssertNotNil(UIImage.ellipsisImage)
    }

    func testEmptyProductsImageIconIsNotNil() {
        XCTAssertNotNil(UIImage.emptyProductsImage)
    }

    func testEmptyReviewsImageIconIsNotNil() {
        XCTAssertNotNil(UIImage.emptyReviewsImage)
    }

    func testEmptySearchResultsImageIconIsNotNil() {
        XCTAssertNotNil(UIImage.emptySearchResultsImage)
    }

    func testEmptyOrdersImageIsNotNil() {
        XCTAssertNotNil(UIImage.emptyOrdersImage)
    }

    func testErrorStateImageIconIsNotNil() {
        XCTAssertNotNil(UIImage.errorStateImage)
    }

    func testExternalImageIconIsNotNil() {
        XCTAssertNotNil(UIImage.externalImage)
    }

    func testExternalProductImageIconIsNotNil() {
        XCTAssertNotNil(UIImage.externalProductImage)
    }

    func testFilterImageIconIsNotNil() {
        XCTAssertNotNil(UIImage.filterImage)
    }

    func testGiftWithTopRightRedDotImageIsNotNil() {
        XCTAssertNotNil(UIImage.giftWithTopRightRedDotImage)
    }

    func testHeartOutlineImageIconIsNotNil() {
        XCTAssertNotNil(UIImage.heartOutlineImage)
    }

    func testIconImageIsNotNil() {
        XCTAssertNotNil(UIImage.infoImage)
    }

    func testSlantedRectangleIsNotNil() {
        XCTAssertNotNil(UIImage.slantedRectangle)
    }

    func testJetpackLogoImageIconIsNotNil() {
        XCTAssertNotNil(UIImage.jetpackLogoImage)
    }

    func testInfoOutlineImageIconIsNotNil() {
        XCTAssertNotNil(UIImage.infoOutlineImage)
    }

    func testInvisibleImageIconIsNotNil() {
        XCTAssertNotNil(UIImage.invisibleImage)
    }

    func testInventoryImageIconIsNotNil() {
        XCTAssertNotNil(UIImage.inventoryImage)
    }

    func testLinkImageIsNotNil() {
        XCTAssertNotNil(UIImage.linkImage)
    }

    func testLoginMagicLinkImageIsNotNil() {
        XCTAssertNotNil(UIImage.loginMagicLinkImage)
    }

    func testLoginSiteAddressInfoImageIsNotNil() {
        XCTAssertNotNil(UIImage.loginSiteAddressInfoImage)
    }

    func testMailImageIconIsNotNil() {
        XCTAssertNotNil(UIImage.mailImage)
    }

    func testMoreImageIconIsNotNil() {
        XCTAssertNotNil(UIImage.moreImage)
    }

    func testPlusImageIconIsNotNil() {
        XCTAssertNotNil(UIImage.plusImage)
    }

    func testPriceImageIconIsNotNil() {
        XCTAssertNotNil(UIImage.priceImage)
    }

    func testProductReviewsImageIsNotNil() {
        XCTAssertNotNil(UIImage.productReviewsImage)
    }

    func testProductReviewsImageMatchesExpectedSize() {
        let size = CGSize(width: 24, height: 24)
        let image = UIImage.productReviewsImage
        XCTAssertEqual(size, image.size)
    }

    func testProductPlaceholderImageIconIsNotNil() {
        XCTAssertNotNil(UIImage.productPlaceholderImage)
    }

    func testProductImageIconIsNotNil() {
        XCTAssertNotNil(UIImage.productImage)
    }

    func testProductsTabWorkInProgressBannerIconIsNotNil() {
        XCTAssertNotNil(UIImage.workInProgressBanner)
    }

    func testPencilImageIconIsNotNil() {
        XCTAssertNotNil(UIImage.pencilImage)
    }

    func testQuoteImageIconIsNotNil() {
        XCTAssertNotNil(UIImage.quoteImage)
    }

    func testPagesImageIconIsNotNil() {
        XCTAssertNotNil(UIImage.pagesImage)
    }

    func testScanImageIconIsNotNil() {
        XCTAssertNotNil(UIImage.scanImage)
    }

    func testSearchImageIconIsNotNil() {
        XCTAssertNotNil(UIImage.searchImage)
    }

    func testShippingImageIconIsNotNil() {
        XCTAssertNotNil(UIImage.shippingImage)
    }

    func testShippingClassListSelectorEmptyImageIsNotNil() {
        XCTAssertNotNil(UIImage.shippingClassListSelectorEmptyImage)
    }

    func testSpamImageIconIsNotNil() {
        XCTAssertNotNil(UIImage.spamImage)
    }

    func testStarImageIconIsNotNil() {
        XCTAssertNotNil(UIImage.starImage(size: 1))
    }

    func testStarImageMatchesExpectedSize() {
        let size = Double(1)
        let starImage = UIImage.starImage(size: size)
        XCTAssertEqual(starImage.size, CGSize(width: size, height: size))
    }

    func testStarOutlineImageMatchesExpectedSize() {
        let size = Double(1)
        let starOutlineImage = UIImage.starOutlineImage(size: size)
        XCTAssertEqual(starOutlineImage.size, CGSize(width: size, height: size))
    }

    func testStarOutlineImageDefaultSize() {
        let starOutlineImage = UIImage.starOutlineImage()
        XCTAssertEqual(starOutlineImage.size, Gridicon.defaultSize)
    }

    func testStatsImageIconIsNotNil() {
        XCTAssertNotNil(UIImage.statsImage)
    }

    func testStatsAltImageIconIsNotNil() {
        XCTAssertNotNil(UIImage.statsAltImage)
    }

    func testTrashImageIconIsNotNil() {
        XCTAssertNotNil(UIImage.trashImage)
    }

    func testVariationsImageIconIsNotNil() {
        XCTAssertNotNil(UIImage.variationsImage)
    }

    func testVisibleImageIsNotNil() {
        XCTAssertNotNil(UIImage.visibilityImage)
    }

    func testWooLogoImageIconIsNotNil() {
        XCTAssertNotNil(UIImage.wooLogoImage())
    }

    func testWooLogoImageMatchesExpectedSize() {
        let size = CGSize(width: 20, height: 20)
        let image = UIImage.wooLogoImage(withSize: size, tintColor: .clear)
        XCTAssertEqual(size, image!.size)
    }

    func testWaitingForCustomersImageIconIsNotNil() {
        XCTAssertNotNil(UIImage.waitingForCustomersImage)
    }

    func testWidgetsImageIconIsNotNil() {
        XCTAssertNotNil(UIImage.widgetsImage)
    }

    func testCategoriesIconIsNotNil() {
        XCTAssertNotNil(UIImage.categoriesIcon)
    }

    func testCategoriesIconHasDefaultSize() {
        let categoriesIcon = UIImage.categoriesIcon
        XCTAssertEqual(categoriesIcon.size, Gridicon.defaultSize)
    }

    func testTagsIconIsNotNil() {
        XCTAssertNotNil(UIImage.tagsIcon)
    }

    func testTagsIconHasDefaultSize() {
        let tagsIcon = UIImage.tagsIcon
        XCTAssertEqual(tagsIcon.size, Gridicon.defaultSize)
    }

    func testSyncIconIsNotNil() {
        XCTAssertNotNil(UIImage.syncImage)
    }

    func testNoStoreImageIsNotNil() {
        XCTAssertNotNil(UIImage.noStoreImage)
    }

    func test_megaphoneIcon_is_not_nil() {
        XCTAssertNotNil(UIImage.megaphoneIcon)
    }

    func testCloudImageIsNotNil() {
        XCTAssertNotNil(UIImage.cloudImage)
    }

    func testMenuImageIconIsNotNil() {
        XCTAssertNotNil(UIImage.menuImage)
    }
}
