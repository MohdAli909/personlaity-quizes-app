//

//

import UIKit

extension UIColor {
    // MARK: - App Colors
    
    static let primaryPurple = UIColor(red: 102/255, green: 102/255, blue: 204/255, alpha: 1.0)
    static let secondaryPurple = UIColor(red: 136/255, green: 119/255, blue: 238/255, alpha: 1.0)
    static let accentYellow = UIColor(red: 255/255, green: 193/255, blue: 7/255, alpha: 1.0)
    static let cardPurple = UIColor(red: 119/255, green: 102/255, blue: 204/255, alpha: 0.4)
    static let selectedCardPurple = UIColor(red: 136/255, green: 119/255, blue: 238/255, alpha: 0.6)
    
    // MARK: - Gradient Colors
    
    static func createGradientLayer(colors: [UIColor], frame: CGRect) -> CAGradientLayer {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = frame
        gradientLayer.colors = colors.map { $0.cgColor }
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
        return gradientLayer
    }
    
    static var backgroundGradientColors: [UIColor] {
        return [
            UIColor(red: 102/255, green: 102/255, blue: 204/255, alpha: 1.0),
            UIColor(red: 119/255, green: 102/255, blue: 204/255, alpha: 1.0)
        ]
    }
}
