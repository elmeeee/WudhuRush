
import SwiftUI
import SpriteKit

// MARK: - Color Palette
struct GameTheme {
    // Primary Brand Colors
    static let primaryGreen = Color(hex: "1E6F5C")
    static let darkGreen = Color(hex: "144D40")
    static let lightGreen = Color(hex: "E6F2EE")
    
    // Backgrounds
    static let background = Color(hex: "F7F9F8")
    static let surface = Color.white
    
    // Accents
    static let gold = Color(hex: "D4AF37")
    static let goldHighlight = Color(hex: "F4D06F")
    static let error = Color(hex: "D9534F")
    static let success = Color(hex: "2ECC71")
    
    // Text
    static let textDark = Color(hex: "2C3E50")
    static let textLight = Color(hex: "95A5A6")
    
    // SpriteKit Variants
    static let skPrimaryGreen = SKColor(red: 0x1E/255.0, green: 0x6F/255.0, blue: 0x5C/255.0, alpha: 1.0)
    static let skDarkGreen = SKColor(red: 0x14/255.0, green: 0x4D/255.0, blue: 0x40/255.0, alpha: 1.0)
    static let skLightGreen = SKColor(red: 0xE6/255.0, green: 0xF2/255.0, blue: 0xEE/255.0, alpha: 1.0)
    static let skBackground = SKColor(red: 0xF7/255.0, green: 0xF9/255.0, blue: 0xF8/255.0, alpha: 1.0)
    static let skSurface = SKColor.white
    static let skGold = SKColor(red: 0xD4/255.0, green: 0xAF/255.0, blue: 0x37/255.0, alpha: 1.0)
    static let skError = SKColor(red: 0xD9/255.0, green: 0x53/255.0, blue: 0x4F/255.0, alpha: 1.0)
    static let skSuccess = SKColor(red: 0x2E/255.0, green: 0xCC/255.0, blue: 0x71/255.0, alpha: 1.0)
    static let skTextDark = SKColor(red: 0x2C/255.0, green: 0x3E/255.0, blue: 0x50/255.0, alpha: 1.0)
}

// MARK: - Color Extension
extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted))
        var hexNumber: UInt64 = 0
        if scanner.scanHexInt64(&hexNumber) {
            let r = Double((hexNumber & 0xff0000) >> 16) / 255
            let g = Double((hexNumber & 0x00ff00) >> 8) / 255
            let b = Double(hexNumber & 0x0000ff) / 255
            self.init(.sRGB, red: r, green: g, blue: b, opacity: 1)
        } else {
            self.init(.sRGB, red: 0, green: 0, blue: 0, opacity: 1)
        }
    }
}
