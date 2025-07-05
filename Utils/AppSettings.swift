//
//  AppSettings.swift
//  DiarioApp
//
//  Created by Carlos Alonso Mamani Ccollque on 1/07/25.
//

import SwiftUI

class AppSettings: ObservableObject {
    @Published var colorTema: Color {
        didSet {
            saveColor(colorTema)
        }
    }

    @Published var fuente: String {
        didSet {
            UserDefaults.standard.set(fuente, forKey: "fuente")
        }
    }

    @Published var tamanoFuente: CGFloat {
        didSet {
            UserDefaults.standard.set(Double(tamanoFuente), forKey: "tamanoFuente")
        }
    }

    var colorBoton: Color {
        colorTema.adjustBrightness(by: -0.15)
    }

    init() {
        // Cargar color guardado o valor por defecto
        if let hex = UserDefaults.standard.string(forKey: "colorTema") {
            self.colorTema = Color(hex: hex)
        } else {
            self.colorTema = Color(hex: "#B1B3FB")
        }

        // Cargar fuente guardada o valor por defecto
        self.fuente = UserDefaults.standard.string(forKey: "fuente") ?? "System"

        // Cargar tamaño guardado o valor por defecto
        let tamañoGuardado = UserDefaults.standard.double(forKey: "tamanoFuente")
        self.tamanoFuente = tamañoGuardado == 0 ? 16 : CGFloat(tamañoGuardado)
    }

    private func saveColor(_ color: Color) {
        if let hex = color.toHex {
            UserDefaults.standard.set(hex, forKey: "colorTema")
        }
    }
}
