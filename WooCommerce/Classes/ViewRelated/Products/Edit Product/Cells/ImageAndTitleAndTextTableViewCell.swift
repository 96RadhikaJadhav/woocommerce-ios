import Combine
import UIKit

/// Displays an optional image, title and text.
///
final class ImageAndTitleAndTextTableViewCell: UITableViewCell {
    /// Supported font styles.
    enum FontStyle {
        case body
        case footnote
    }

    /// Use cases where an image, title, and text could be displayed.
    /// TODO-3419: add support for other use cases that are currently configured with individual `*ViewModel`.
    enum Style {
        /// Only the image and title label are displayed with a given font style for the title.
        case imageAndTitleOnly(fontStyle: FontStyle)
    }

    /// Contains configurable properties for the cell.
    struct DataConfiguration {
        let title: String?
        let text: String?
        let textTintColor: UIColor?
        let image: UIImage?
        let imageTintColor: UIColor?
        let numberOfLinesForTitle: Int
        let numberOfLinesForText: Int
        let isActionable: Bool
        let showsSeparator: Bool

        init(title: String?,
             text: String? = nil,
             textTintColor: UIColor? = nil,
             image: UIImage? = nil,
             imageTintColor: UIColor? = nil,
             numberOfLinesForTitle: Int = 1,
             numberOfLinesForText: Int = 1,
             isActionable: Bool = true,
             showsSeparator: Bool = true) {
            self.title = title
            self.text = text
            self.textTintColor = textTintColor
            self.image = image
            self.imageTintColor = imageTintColor
            self.numberOfLinesForTitle = numberOfLinesForTitle
            self.numberOfLinesForText = numberOfLinesForText
            self.isActionable = isActionable
            self.showsSeparator = showsSeparator
        }
    }

    struct ViewModel {
        let title: String?
        let text: String?
        let textTintColor: UIColor?
        let image: UIImage?
        let imageTintColor: UIColor?
        let numberOfLinesForTitle: Int
        let numberOfLinesForText: Int
        let isActionable: Bool
        let showsSeparator: Bool

        init(title: String?,
             text: String?,
             textTintColor: UIColor? = nil,
             image: UIImage? = nil,
             imageTintColor: UIColor? = nil,
             numberOfLinesForTitle: Int = 1,
             numberOfLinesForText: Int = 1,
             isActionable: Bool = true,
             showsSeparator: Bool = true) {
            self.title = title
            self.text = text
            self.textTintColor = textTintColor
            self.image = image
            self.imageTintColor = imageTintColor
            self.numberOfLinesForTitle = numberOfLinesForTitle
            self.numberOfLinesForText = numberOfLinesForText
            self.isActionable = isActionable
            self.showsSeparator = showsSeparator
        }
    }

    /// View model with a switch in the cell's accessory view.
    struct SwitchableViewModel {
        let viewModel: ViewModel
        let isSwitchOn: Bool
        let isActionable: Bool
        let onSwitchChange: (_ isOn: Bool) -> Void

        init(viewModel: ViewModel, isSwitchOn: Bool, isActionable: Bool, onSwitchChange: @escaping (_ isOn: Bool) -> Void) {
            self.viewModel = viewModel
            self.isSwitchOn = isSwitchOn
            self.isActionable = isActionable
            self.onSwitchChange = onSwitchChange
        }
    }

    /// View model for warning UI.
    struct WarningViewModel {
        let icon: UIImage
        let title: String?
    }

    /// View model to replace TopLeftImageTableViewCell
    struct TopLeftImageViewModel {
        let icon: UIImage
        let iconColor: UIColor?
        let title: String
        let isFootnoteStyle: Bool
    }

    @IBOutlet private weak var contentStackView: UIStackView!
    @IBOutlet private weak var contentImageStackView: UIStackView!
    @IBOutlet private weak var contentImageView: UIImageView!
    @IBOutlet private weak var titleAndTextStackView: UIStackView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!

    /// Disabled by default. When active, image is constrained to 24pt
    @IBOutlet private var contentImageViewWidthConstraint: NSLayoutConstraint!
    private var baseContentImageDimension: CGFloat = Constants.imageViewDefaultDimension

    private var cancellable: AnyCancellable?

    override func awakeFromNib() {
        super.awakeFromNib()
        configureLabels()
        configureImageView()
        configureContentStackView()
        configureTitleAndTextStackView()
        applyDefaultBackgroundStyle()
        cancellable = NotificationCenter.default
                .publisher(for: UIContentSizeCategory.didChangeNotification)
                .sink { [weak self] _ in
                    self?.applyAccessibilityChanges()
                }
    }
}

// MARK: Updates
//
extension ImageAndTitleAndTextTableViewCell {
    func updateUI(viewModel: ViewModel) {
        titleLabel.text = viewModel.title
        titleLabel.isHidden = viewModel.title == nil || viewModel.title?.isEmpty == true
        titleLabel.textColor = viewModel.text?.isEmpty == false ? .text: .textSubtle
        titleLabel.numberOfLines = viewModel.numberOfLinesForTitle
        descriptionLabel.text = viewModel.text
        descriptionLabel.textColor = .textSubtle
        descriptionLabel.isHidden = viewModel.text == nil || viewModel.text?.isEmpty == true
        descriptionLabel.numberOfLines = viewModel.numberOfLinesForText
        contentImageView.image = viewModel.image
        contentImageStackView.isHidden = viewModel.image == nil
        accessoryType = viewModel.isActionable ? .disclosureIndicator: .none
        selectionStyle = viewModel.isActionable ? .default: .none
        accessoryView = nil

        if let textTintColor = viewModel.textTintColor {
            titleLabel.textColor = textTintColor
            descriptionLabel.textColor = textTintColor
        }

        if let imageTintColor = viewModel.imageTintColor {
            contentImageView.tintColor = imageTintColor
        }
        contentView.backgroundColor = nil

        contentImageViewWidthConstraint.isActive = false

        if viewModel.showsSeparator {
            showSeparator()
        } else {
            hideSeparator()
        }
    }

    func updateUI(switchableViewModel: SwitchableViewModel) {
        updateUI(viewModel: switchableViewModel.viewModel)
        titleLabel.textColor = .text

        let toggleSwitch = UISwitch()
        toggleSwitch.onTintColor = switchableViewModel.isActionable ? .primary: .switchDisabledColor
        toggleSwitch.isOn = switchableViewModel.isSwitchOn
        toggleSwitch.isUserInteractionEnabled = switchableViewModel.isActionable
        if switchableViewModel.isActionable {
            toggleSwitch.on(.touchUpInside) { visibilitySwitch in
                switchableViewModel.onSwitchChange(visibilitySwitch.isOn)
            }
        }
        accessoryView = toggleSwitch
        contentView.backgroundColor = nil
    }

    func updateUI(warningViewModel: WarningViewModel) {
        let viewModel = ViewModel(title: warningViewModel.title,
                                  text: nil,
                                  textTintColor: .warning,
                                  image: warningViewModel.icon,
                                  imageTintColor: .warning,
                                  isActionable: false)
        updateUI(viewModel: viewModel)

        titleLabel.textColor = .text
        titleLabel.numberOfLines = 0
        contentView.backgroundColor = .warningBackground
    }

    func updateUI(topLeftImageViewModel: TopLeftImageViewModel) {
        let viewModel = ViewModel(title: topLeftImageViewModel.title,
                                  text: nil,
                                  image: topLeftImageViewModel.icon,
                                  imageTintColor: topLeftImageViewModel.iconColor,
                                  numberOfLinesForTitle: 0,
                                  isActionable: false)
        updateUI(viewModel: viewModel)

        if topLeftImageViewModel.isFootnoteStyle {
            titleLabel.applyFootnoteStyle()
        } else {
            titleLabel.applyBodyStyle()
        }

        contentImageViewWidthConstraint.isActive = true
    }

    /// Updates cell with the given style and data configuration.
    func update(with style: Style, data: DataConfiguration) {
        switch style {
        case .imageAndTitleOnly(let fontStyle):
            applyImageAndTitleOnlyStyle(fontStyle: fontStyle, data: data)
        }
        applyAccessibilityChanges()
    }
}

// MARK: Private update helpers
//
private extension ImageAndTitleAndTextTableViewCell {
    func applyImageAndTitleOnlyStyle(fontStyle: FontStyle, data: DataConfiguration) {
        switch fontStyle {
        case .body:
            titleLabel.applyBodyStyle()
        case .footnote:
            titleLabel.applyFootnoteStyle()
        }
        baseContentImageDimension = fontStyle.imageDimension
        applyDefaultStyle(data: data)
        contentImageViewWidthConstraint.isActive = true
    }

    func applyDefaultStyle(data: DataConfiguration) {
        let viewModel = ViewModel(title: data.title,
                                  text: data.text,
                                  textTintColor: data.textTintColor,
                                  image: data.image,
                                  imageTintColor: data.imageTintColor,
                                  numberOfLinesForTitle: data.numberOfLinesForTitle,
                                  numberOfLinesForText: data.numberOfLinesForText,
                                  isActionable: data.isActionable,
                                  showsSeparator: data.showsSeparator)
        updateUI(viewModel: viewModel)
    }
}

// MARK: Configurations
//
private extension ImageAndTitleAndTextTableViewCell {
    func configureLabels() {
        titleLabel.applyBodyStyle()
        titleLabel.textColor = .text

        descriptionLabel.applySubheadlineStyle()
        descriptionLabel.textColor = .textSubtle
    }

    func configureImageView() {
        contentImageView.contentMode = .scaleAspectFit
        contentImageView.setContentHuggingPriority(.required, for: .horizontal)
    }

    func configureContentStackView() {
        contentStackView.alignment = .firstBaseline
        contentStackView.spacing = 16
    }

    func configureTitleAndTextStackView() {
        titleAndTextStackView.spacing = 2
    }
}

private extension ImageAndTitleAndTextTableViewCell.FontStyle {
    var imageDimension: CGFloat {
        switch self {
        case .body:
            return 24
        case .footnote:
            return 20
        }
    }
}

// MARK: Accessibility
//
private extension ImageAndTitleAndTextTableViewCell {
    func applyAccessibilityChanges() {
        adjustImageViewWidth()
    }

    /// Changes the image view width according to the base image dimension.
    func adjustImageViewWidth() {
        contentImageViewWidthConstraint.constant = UIFontMetrics.default.scaledValue(for: baseContentImageDimension, compatibleWith: traitCollection)
    }
}

private extension ImageAndTitleAndTextTableViewCell {
    enum Constants {
        static let imageViewDefaultDimension: CGFloat = 24
    }
}

