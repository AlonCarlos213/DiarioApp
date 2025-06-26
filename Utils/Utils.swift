//
//  Utils.swift
//  DiarioApp
//
//  Created by Carlos Alonso Mamani Ccollque on 19/06/25.
//

import SwiftUI

// ✅ Permite usar colores hexadecimales como Color(hex: "#B1B3FB")
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r, g, b: UInt64
        (r, g, b) = ((int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        self.init(.sRGB, red: Double(r) / 255,
                         green: Double(g) / 255,
                         blue: Double(b) / 255)
    }
}

// ✅ Validación básica de correo electrónico
extension String {
    var isValidEmail: Bool {
        let regex = #"^\S+@\S+\.\S+$"#
        return self.range(of: regex, options: .regularExpression) != nil
    }
}

// ✅ Formateo de fechas en español peruano
extension Date {
    func format() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "es_PE")
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: self)
    }
}
