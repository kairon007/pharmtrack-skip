import SwiftUI
import AppModel

// Color helper for hex colors - Skip-compatible
public struct ColorHelper {
    // iOS/macOS implementation
    #if !SKIP
    public static func hex(_ hex: String) -> Color {
        let h = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: h).scanHexInt64(&int)
        let r = Double((int >> 16) & 0xFF) / 255.0
        let g = Double((int >> 8) & 0xFF) / 255.0
        let b = Double(int & 0xFF) / 255.0
        return Color(red: r, green: g, blue: b)
    }
    #endif

    #if SKIP
    // Android implementation - manual hex parsing without Scanner
    public static func hex(_ hex: String) -> Color {
        var h = hex
        if h.hasPrefix("#") {
            h = String(h.dropFirst())
        }
        if h.count == 6 {
            let r = hexCharToDouble(h[0]) * 16 + hexCharToDouble(h[1])
            let g = hexCharToDouble(h[2]) * 16 + hexCharToDouble(h[3])
            let b = hexCharToDouble(h[4]) * 16 + hexCharToDouble(h[5])
            return Color(red: r, green: g, blue: b)
        }
        return Color(red: 0.5, green: 0.5, blue: 0.5)
    }

    private static func hexCharToDouble(_ c: Character) -> Double {
        let chars = "0123456789abcdef"
        if let idx = chars.firstIndex(of: Character(String(c).lowercased())) {
            return Double(chars.distance(from: chars.startIndex, to: idx)) / 255.0
        }
        return 0.0
    }
    #endif
}

// Convenience shorthand
public extension Color {
    #if !SKIP
    static func hex(_ hex: String) -> Color {
        ColorHelper.hex(hex)
    }
    #else
    static func hex(_ hex: String) -> Color {
        ColorHelper.hex(hex)
    }
    #endif
}
