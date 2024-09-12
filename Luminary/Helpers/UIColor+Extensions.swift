import UIKit

// MARK: - Color Manipulation

extension UIColor {
    
    /// Stores default shimmer CGColor array
    static var defaultShimmerColors: [CGColor] {
        [
            lavender.cgColor(multipliedBy: 0.95),
            lavender.cgColor(multipliedBy: 1.1),
            lavender.cgColor(multipliedBy: 0.95)
        ]
    }
    
    /// Stores default shimmer border CGColor array
    static var defaultShimmerBorderColors: [CGColor] {
        [
            lavender.cgColor,
            lavender.cgColor(multipliedBy: 1.8),
            lavender.cgColor
        ]
    }
    
    /// Returns a CGColor with each of its components (except alpha) multiplied by the specified multiplier.
    func cgColor(multipliedBy multiplier: CGFloat) -> CGColor {
        
        var red: CGFloat = .zero
        var green: CGFloat = .zero
        var blue: CGFloat = .zero
        var alpha: CGFloat = .zero
        
        getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        red *= multiplier
        green *= multiplier
        blue *= multiplier
        
        return UIColor(red: red, green: green, blue: blue, alpha: alpha).cgColor
    }
}
