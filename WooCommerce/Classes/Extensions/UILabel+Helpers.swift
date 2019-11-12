import UIKit
import Yosemite


extension UILabel {
    func applyHeadlineStyle() {
        adjustsFontForContentSizeCategory = true
        font = .headline
        textColor = .text
    }

    func applySubheadlineStyle() {
        adjustsFontForContentSizeCategory = true
        font = .subheadline
        textColor = .text
    }

    func applyBodyStyle() {
        adjustsFontForContentSizeCategory = true
        font = .body
        textColor = .text
    }

    func applySecondaryBodyStyle() {
        adjustsFontForContentSizeCategory = true
        font = .body
        textColor = StyleManager.wooGreyTextMin
    }

    func applyFootnoteStyle() {
        adjustsFontForContentSizeCategory = true
        font = .footnote
        textColor = .text
    }

    func applySecondaryFootnoteStyle() {
        adjustsFontForContentSizeCategory = true
        font = .footnote
        textColor = StyleManager.wooGreyTextMin
    }

    func applyTitleStyle() {
        adjustsFontForContentSizeCategory = true
        font = .title1
        textColor = .text
    }

    func applyPaddedLabelDefaultStyles() {
        adjustsFontForContentSizeCategory = true
        layer.borderWidth = 1.0
        layer.cornerRadius = 4.0
        font = .footnote
    }

    func applyPaddedLabelSubheadStyles() {
        adjustsFontForContentSizeCategory = true
        layer.borderWidth = 1.0
        layer.cornerRadius = 4.0
        font = .subheadline
    }

    func applyEmptyStateTitleStyle() {
        adjustsFontForContentSizeCategory = true
        font = .body
        textColor = StyleManager.wooGreyMid
    }
}
