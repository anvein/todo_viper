
import UIKit

// MARK: - Colors

//extension UIColor {
//    static let isDoneButtonCompletedBg = ColorAsset(name: "isDoneButtonCompletedBg").color
//    static let isDoneButtonBorder = ColorAsset(name: "isDoneButtonBorder").color
//
//    static let textBlack = ColorAsset(name: "textBlack").color
//    
//    static let taskCellHighlighted = ColorAsset(name: "taskCellHighlighted").color
//}

// MARK: - ColorAsset

final class ColorAsset {
    fileprivate(set) var name: String

    private(set) lazy var color: UIColor =  {
        guard let color = UIColor(named: name, in: Bundle.main, compatibleWith: nil) else {
          fatalError("Unable to load color asset named \(name).")
        }
        return color
    }()

    init(name: String) {
        self.name = name
    }
}
