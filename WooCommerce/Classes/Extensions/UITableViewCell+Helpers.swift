import Foundation
import UIKit


/// UITableViewCell Helpers
///
extension UITableViewCell {

    /// Returns a reuseIdentifier that matches the receiver's classname (non namespaced).
    ///
    class var reuseIdentifier: String {
        return classNameWithoutNamespaces
    }

    /// Applies the default background color
    ///
    func applyDefaultBackgroundStyle() {
        backgroundColor = .listForeground
    }

    /// Hides the separator for a cell.
    ///
    func hideSeparator() {
        separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
    }
}
