//
//  Utils.swift
//  DiarioApp
//
//  Created by Carlos Alonso Mamani Ccollque on 19/06/25.
//

import SwiftUI

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
