import SwiftUI

struct SobreNosotrosView: View {
    @EnvironmentObject var appSettings: AppSettings
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 15) {
                    Text("Nosotros somos DiarioFEEL")
                        .font(.custom(
                            appSettings.fuente == "System"
                                ? UIFont.systemFont(ofSize: appSettings.tamanoFuente).fontName
                                : appSettings.fuente,
                            size: appSettings.tamanoFuente
                        ))
                        .bold()

                    Text("""
En Diarios Feel, creemos en el poder de la escritura como herramienta de sanación, autoconocimiento y crecimiento personal. Somos un equipo comprometido con crear un espacio íntimo, seguro y emocionalmente libre donde cada persona pueda expresarse sin filtros ni juicios.

Nuestro diario no es solo una app: es un compañero diario, un espejo de emociones y un refugio creativo para quienes buscan reconectar consigo mismos.

Promovemos el bienestar emocional con una experiencia simple, intuitiva y hermosa. Aquí, cada entrada cuenta una historia, cada emoción tiene un color, y cada día es una oportunidad para sentir y soltar.
""")
                        .font(.custom(
                            appSettings.fuente == "System"
                                ? UIFont.systemFont(ofSize: appSettings.tamanoFuente).fontName
                                : appSettings.fuente,
                            size: appSettings.tamanoFuente
                        ))

                    Text("Síguenos en:")
                        .font(.custom(
                            appSettings.fuente == "System"
                                ? UIFont.systemFont(ofSize: appSettings.tamanoFuente).fontName
                                : appSettings.fuente,
                            size: appSettings.tamanoFuente
                        ))

                    HStack(spacing: 30) {
                        Image(systemName: "xmark.circle")
                        Image(systemName: "camera.circle")
                    }
                    .font(.title2)
                }
                .padding()
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.black)
                    }
                }
                ToolbarItem(placement: .principal) {
                    Text("Sobre nosotros")
                        .font(.custom(appSettings.fuente, size: appSettings.tamanoFuente + 2))
                        .foregroundColor(.black)
                }
            }
            .toolbarBackground(appSettings.colorTema.opacity(1), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .background(Color.white.ignoresSafeArea())
            .appStyle()
        }
    }
}

