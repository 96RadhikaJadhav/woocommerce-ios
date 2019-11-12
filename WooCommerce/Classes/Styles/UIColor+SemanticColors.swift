import UIKit

// MARK: - Base colors.
extension UIColor {
    /// Accent. Pink-50 (< iOS 13 and Light Mode) and Pink-30 (Dark Mode)
    ///
    static var accent: UIColor {
        return UIColor(light: muriel(color: .pink, .shade50),
                        dark: muriel(color: .pink, .shade30))
    }

    /// Accent Dark. Pink-70 (< iOS 13 and Light Mode) and Pink-50 (Dark Mode)
    ///
    static var accentDark: UIColor {
        return UIColor(light: muriel(color: .pink, .shade70),
                        dark: muriel(color: .pink, .shade50))
    }

    /// Brand. WooCommercePurple-60 (all versions of iOS, Light and Dark Mode)
    ///
    static var brand = UIColor.muriel(color: .brand)

    /// Error. Red-50 (< iOS 13 and Light Mode) and Red-30 (Dark Mode)
    ///
    static var error: UIColor {
        return UIColor(light: muriel(color: .red, .shade50),
                        dark: muriel(color: .red, .shade30))
    }

    /// Error Dark. Red-70 (< iOS 13 and Light Mode) and Red-50 (Dark Mode)
    ///
    static var errorDark: UIColor {
        return UIColor(light: muriel(color: .red, .shade70),
                        dark: muriel(color: .red, .shade50))
    }

    /// Primary. WooCommercePurple-60 (< iOS 13 and Light Mode) and WooCommercePurple-30 (Dark Mode)
    ///
    static var primary: UIColor {
        return UIColor(light: muriel(color: .wooCommercePurple, .shade60),
                        dark: muriel(color: .wooCommercePurple, .shade30))
    }

    /// Primary Dark. WooCommercePurple-80 (< iOS 13 and Light Mode) and WooCommercePurple-50 (Dark Mode)
    ///
    static var primaryDark: UIColor {
        return UIColor(light: muriel(color: .wooCommercePurple, .shade80),
                        dark: muriel(color: .wooCommercePurple, .shade50))
    }

    /// Success. Green-50 (< iOS 13 and Light Mode) and Green-30 (Dark Mode)
    ///
    static var success: UIColor {
        return UIColor(light: muriel(color: .green, .shade50),
                        dark: muriel(color: .green, .shade30))
    }

    /// Warning. Yellow-50 (< iOS 13 and Light Mode) and Yellow-30 (Dark Mode)
    ///
    static var warning: UIColor {
        return UIColor(light: muriel(color: .yellow, .shade50),
                        dark: muriel(color: .yellow, .shade30))
    }

    /// Blue. Blue-50 (< iOS 13 and Light Mode) and Blue-30 (Dark Mode)
    ///
    static var blue: UIColor {
        return UIColor(light: muriel(color: .blue, .shade50),
                        dark: muriel(color: .blue, .shade30))
    }

    /// Orange. Orange-50 (< iOS 13 and Light Mode) and Orange-30 (Dark Mode)
    ///
    static var orange: UIColor {
        return UIColor(light: muriel(color: .orange, .shade50),
                        dark: muriel(color: .orange, .shade30))
    }
}


// MARK: - Text Colors.
extension UIColor {
    /// Text. Gray-80 (< iOS 13) and `UIColor.label` (> iOS 13)
    ///
    static var text: UIColor {
        if #available(iOS 13, *) {
            return .label
        }

        return .gray(.shade80)
    }

    /// Text Subtle. Gray-50 (< iOS 13) and `UIColor.secondaryLabel` (> iOS 13)
    ///
    static var textSubtle: UIColor {
        if #available(iOS 13, *) {
            return .secondaryLabel
        }

        return .gray(.shade50)
    }

    /// Text Tertiary. Gray-20 (< iOS 13) and `UIColor.tertiaryLabel` (> iOS 13)
    ///
    static var textTertiary: UIColor {
        if #available(iOS 13, *) {
            return .tertiaryLabel
        }

        return .gray(.shade20)
    }

    /// Text Quaternary. Gray-10 (< iOS 13) and `UIColor.quaternaryLabel` (> iOS 13)
    ///
    static var textQuaternary: UIColor {
        if #available(iOS 13, *) {
            return .quaternaryLabel
        }

        return .gray(.shade10)
    }

    /// Text Inverted. White(< iOS 13 and Light Mode) and Gray-90 (Dark Mode)
    ///
    static var textInverted: UIColor {
        return UIColor(light: .white,
                       dark: muriel(color: .gray, .shade90))
    }

    /// Text Placeholder. Gray-30 (< iOS 13) and `UIColor.placeholderText` (> iOS 13)
    ///
    static var textPlaceholder: UIColor {
        if #available(iOS 13, *) {
            return .placeholderText
        }

        return .gray(.shade30)
    }
}


// MARK: - UI elements.
extension UIColor {
    /// Basic Background. White (< iOS 13) and `UIColor.systemBackground` (> iOS 13)
    ///
    static var basicBackground: UIColor {
        if #available(iOS 13, *) {
            return .systemBackground
        }

        return .white
    }

    /// App Bar. WooCommercePurple-60 (< iOS 13 and Light Mode) and `UIColor.systemThickMaterial` (Dark Mode)
    ///
    static var appBar: UIColor {
        if #available(iOS 13, *) {
            return UIColor(light: muriel(color: .wooCommercePurple, .shade60),
                           dark: .systemBackground)
        }


        return muriel(color: .wooCommercePurple, .shade60)
    }

    /// Tab Unselected. Gray-20 (< iOS 13 and Light Mode) and Gray-60 (Dark Mode)
    ///
    static var tabUnselected: UIColor {
        return UIColor(light: muriel(color: .gray, .shade20),
                       dark: muriel(color: .gray, .shade60))
    }

    /// Divider. Gray-10 (< iOS 13) and `UIColor.separator` (> iOS 13)
    ///
    static var divider: UIColor {
        if #available(iOS 13, *) {
            return .separator
        }

        return muriel(color: .gray, .shade10)
    }

    /// Primary Button Background. Resolves to `accent`
    ///
    static var primaryButtonBackground = accent

    /// Primary Button Border. Resolves to `accent`
    ///
    static var primaryButtonBorder = accent

    /// Primary Button Down Background. Pink-80 (< iOS 13 and Light Mode) and Pink-50 (Dark Mode)
    ///
    static var primaryButtonDownBackground: UIColor {
        return UIColor(light: muriel(color: .pink, .shade80),
                       dark: muriel(color: .pink, .shade50))
    }

    /// Primary Button Down Border. Resolves to `primaryButtonDownBackground`
    ///
    static var primaryButtonDownBorder = primaryButtonDownBackground

    /// Filter Bar Selected. `primary` (< iOS 13 and Light Mode) and `UIColor.label` (Dark Mode)
    ///
    static var filterBarSelected: UIColor {
        if #available(iOS 13, *) {
            return UIColor(light: .primary,
                           dark: .label)
        }


        return .primary
    }

    /// Filter Bar Background. `white` (< iOS 13 and Light Mode) and Gray-90 (Dark Mode)
    ///
    static var filterBarBackground: UIColor {
        return UIColor(light: .white,
                       dark: muriel(color: .gray, .shade90))
    }
}


// MARK: - Table Views.
extension UIColor {
    /// List Icon. Gray-20 (< iOS 13) and `UIColor.secondaryLabel` (> iOS 13)
    ///
    static var listIcon: UIColor {
        if #available(iOS 13, *) {
            return .secondaryLabel
        }

        return muriel(color: .gray, .shade20)
    }

    /// List Small Icon. Gray-20 (< iOS 13) and `UIColor.systemGray` (> iOS 13)
    ///
    static var listSmallIcon: UIColor {
        if #available(iOS 13, *) {
            return .systemGray
        }

        return muriel(color: .gray, .shade20)
    }

    /// List BackGround. Gray-0 (< iOS 13) and `UIColor.systemGroupedBackground` (> iOS 13)
    ///
    static var listBackground: UIColor {
        if #available(iOS 13, *) {
            return .systemGroupedBackground
        }

        return muriel(color: .gray, .shade0)
    }

    /// List ForeGround. `UIColor.white` (< iOS 13) and `UIColor.secondarySystemGroupedBackground` (> iOS 13)
    ///
    static var listForeground: UIColor {
        if #available(iOS 13, *) {
            return .secondarySystemGroupedBackground
        }

        return .white
    }

    /// List ForeGround Unread. Blue-0 (< iOS 13) and `UIColor.tertiarySystemGroupedBackground` (> iOS 13)
    ///
    static var listForegroundUnread: UIColor {
        if #available(iOS 13, *) {
            return .tertiarySystemGroupedBackground
        }

        return muriel(color: .blue, .shade0)
    }
}


// MARK: - Grays
extension UIColor {
    /// Muriel gray palette
    /// - Parameter shade: a MurielColorShade of the desired shade of gray
    class func gray(_ shade: MurielColorShade) -> UIColor {
        return muriel(color: .gray, shade)
    }

    /// Muriel neutral colors, which invert in dark mode
    /// - Parameter shade: a MurielColorShade of the desired neutral shade
    static var neutral: UIColor {
        return neutral(.shade50)
    }
    class func neutral(_ shade: MurielColorShade) -> UIColor {
        switch shade {
        case .shade0:
            return UIColor(light: muriel(color: .gray, .shade0), dark: muriel(color: .gray, .shade100))
            case .shade5:
            return UIColor(light: muriel(color: .gray, .shade5), dark: muriel(color: .gray, .shade90))
            case .shade10:
            return UIColor(light: muriel(color: .gray, .shade10), dark: muriel(color: .gray, .shade80))
            case .shade20:
            return UIColor(light: muriel(color: .gray, .shade20), dark: muriel(color: .gray, .shade70))
            case .shade30:
            return UIColor(light: muriel(color: .gray, .shade30), dark: muriel(color: .gray, .shade60))
            case .shade40:
            return UIColor(light: muriel(color: .gray, .shade40), dark: muriel(color: .gray, .shade50))
            case .shade50:
            return UIColor(light: muriel(color: .gray, .shade50), dark: muriel(color: .gray, .shade40))
            case .shade60:
            return UIColor(light: muriel(color: .gray, .shade60), dark: muriel(color: .gray, .shade30))
            case .shade70:
            return UIColor(light: muriel(color: .gray, .shade70), dark: muriel(color: .gray, .shade20))
            case .shade80:
            return UIColor(light: muriel(color: .gray, .shade80), dark: muriel(color: .gray, .shade10))
            case .shade90:
            return UIColor(light: muriel(color: .gray, .shade90), dark: muriel(color: .gray, .shade5))
            case .shade100:
            return UIColor(light: muriel(color: .gray, .shade100), dark: muriel(color: .gray, .shade0))
        }
    }
}
