//
//  AppStyleModifier..swift
//  DiarioApp
//
//  Created by Carlos Alonso Mamani Ccollque on 2/07/25.
//

import SwiftUI

struct AppStyleModifier: ViewModifier {
    @EnvironmentObject var appSettings: AppSettings

    func body(content: Content) -> some View {
        content
            .font(.custom(
                appSettings.fuente == "System"
                    ? UIFont.systemFont(ofSize: appSettings.tamanoFuente).fontName
                    : appSettings.fuente,
                size: appSettings.tamanoFuente
            ))
            .background(appSettings.colorTema.opacity(0.05))
    }
}

extension View {
    func appStyle() -> some View {
        self.modifier(AppStyleModifier())
    }
}

