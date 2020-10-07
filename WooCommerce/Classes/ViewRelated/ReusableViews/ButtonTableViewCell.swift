import UIKit

/// Displays a button inside a `UITableViewCell`.
///
final class ButtonTableViewCell: UITableViewCell {
    @IBOutlet private var button: UIButton!

    /// The style of this view, particularly the button.
    enum Style {
        /// Uses the primary button style. This is the default.
        case primary
        /// Uses the secondary button style.
        case secondary

        fileprivate static let `default` = Self.primary
    }

    var onFullfillTouchUp: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()

        configureBackground()
        apply(style: .default)
    }

    /// Define this cell's UI attributes.
    ///
    func configure(style: Style = .default, title: String?) {
        apply(style: style)
        button.setTitle(title, for: .normal)
    }
}

private extension ButtonTableViewCell {
    @IBAction func sendButtonTouchUpEvent() {
        onFullfillTouchUp?()
    }
}

private extension ButtonTableViewCell {
    func configureBackground() {
        applyDefaultBackgroundStyle()
    }

    func apply(style: Style) {
        switch style {
        case .primary:
            button.applyPrimaryButtonStyle()
        case .secondary:
            button.applySecondaryButtonStyle()
        }
    }
}
