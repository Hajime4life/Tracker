import UIKit

extension UIColor {
    static var trackerCellColors: [UIColor] {
        return [
            .cellRed,
            .cellOrange,
            .cellBlue,
            .cellPurple,
            .cellGreen,
            .cellPink,
            .cellLightPink,
            .cellLightBlue,
            .cellMint,
            .cellDarkBlue,
            .cellCoral,
            .cellBabyPink,
            .cellPeach,
            .cellPeriwinkle,
            .cellViolet,
            .cellLavender,
            .cellLightPurple,
            .cellLime
        ]
    }
    
    static func ypBlackForTheme(for traitCollection: UITraitCollection) -> UIColor {
        if traitCollection.userInterfaceStyle == .dark {
            return UIColor(named: "ypBlack", in: nil, compatibleWith: traitCollection) ?? .black
        } else {
            return UIColor(named: "ypWhite", in: nil, compatibleWith: traitCollection) ?? .white
        }
    }
    
    static func ypWhiteForTheme(for traitCollection: UITraitCollection) -> UIColor {
        if traitCollection.userInterfaceStyle == .dark {
            return UIColor(named: "ypWhite", in: nil, compatibleWith: traitCollection) ?? .white
        } else {
            return UIColor(named: "ypBlack", in: nil, compatibleWith: traitCollection) ?? .black
        }
    }
}
