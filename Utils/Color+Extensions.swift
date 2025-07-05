import SwiftUI

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)

        let r, g, b: UInt64
        switch hex.count {
        case 6: // RGB (24-bit)
            (r, g, b) = (
                int >> 16,
                int >> 8 & 0xFF,
                int & 0xFF
            )
        default:
            (r, g, b) = (0, 0, 0) // negro por defecto si algo falla
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255
        )
    }

    var toHex: String? {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0

        guard UIColor(self).getRed(&r, green: &g, blue: &b, alpha: &a) else {
            return nil
        }

        return String(
            format: "#%02X%02X%02X",
            Int(r * 255),
            Int(g * 255),
            Int(b * 255)
        )
    }

    func adjustBrightness(by amount: Double) -> Color {
        return Color(UIColor(self).adjust(by: amount))
    }
}

extension UIColor {
    func adjust(by amount: Double) -> UIColor {
        var hue: CGFloat = 0
        var sat: CGFloat = 0
        var bri: CGFloat = 0
        var alpha: CGFloat = 0
        if getHue(&hue, saturation: &sat, brightness: &bri, alpha: &alpha) {
            return UIColor(
                hue: hue,
                saturation: sat,
                brightness: min(max(bri + CGFloat(amount), 0), 1),
                alpha: alpha
            )
        }
        return self
    }
}

