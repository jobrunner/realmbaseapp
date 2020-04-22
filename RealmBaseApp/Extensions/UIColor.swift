import UIKit

extension UIColor {
    /**
     Initializes a `UIColor` instance with a hex value as `UInt32` and an alpha value that is 1.0 by default.
     - Parameter hex: A color value as hexadecimal number (UInt32)
     - Parameter alpha: An optional alpha value between 0.0 and 1.0.
     ```
     let color = UIColor(fromString: 0x336699)
     let color = UIColor(fromString: 0x336699, alpha: 0.5)
     ```
     */
    convenience init(hex: UInt32, alpha: CGFloat = 1.0) {
        let red = CGFloat((hex & 0xff0000) >> 16) / 255.0
        let green = CGFloat((hex & 0xff00) >> 8) / 255.0
        let blue = CGFloat((hex & 0xff) >> 0) / 255.0
        
        self.init(red: red, green: green, blue: blue, alpha: alpha);
    }
    
    /**
     Initializes a `UIColor` instance with a color value string (as usual on the web) in the form of a six-digit hex code.
     - Parameter fromString: Color value in hexadecimal notation. E.g. FFFFFF for white.
     - Parameter alpha: An optional alpha value between 0.0 and 1.0.
     Aufruf:
     ```
     let color = UIColor(fromString: "333333")
     let color = UIColor(fromString: "666666", alpha: 0.5)
     ```
     */
    convenience init(fromString: String, alpha: CGFloat = 1.0) {
        let scanner: Scanner = Scanner(string: fromString)
        scanner.scanLocation = 1
        
        var value: UInt32 = 0
        scanner.scanHexInt32(&value)
        
        self.init(hex: value, alpha: alpha)
    }
}
