import SwiftUI

struct DiarioCardView: View {
    @EnvironmentObject var appSettings: AppSettings
    let diario: Diario
    let firma: [CGPoint]
    let isVisible: Bool

    var body: some View {
        if isVisible {
            VStack(spacing: 10) {
                Text(diario.emocion)
                    .font(.largeTitle)

                Text(diario.titulo)
                    .font(.custom(
                        appSettings.fuente == "System"
                            ? UIFont.systemFont(ofSize: appSettings.tamanoFuente).fontName
                            : appSettings.fuente,
                        size: appSettings.tamanoFuente
                    ))
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.black)
                    .lineLimit(2)
                    .frame(maxWidth: .infinity)
            }
            .padding()
            .frame(width: 160, height: 160)
            .background(appSettings.colorTema.opacity(0.5)) // ✅ Fondo dinámico
            .cornerRadius(20)
            .transition(.opacity.animation(.easeOut(duration: 0.3)))
        }
    }
}

