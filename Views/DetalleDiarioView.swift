import SwiftUI

struct DetalleDiarioView: View {
    @EnvironmentObject var appSettings: AppSettings
    @Environment(\.dismiss) var dismiss
    var diario: Diario
    var firma: [CGPoint]

    var body: some View {
        NavigationStack {
            ZStack {
                Color.white.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        // Emoción y Título
                        HStack(alignment: .center, spacing: 8) {
                            Text(diario.emocion)
                                .font(.system(size: 32))
                            Text(diario.titulo)
                                .font(.custom(appSettings.fuente, size: appSettings.tamanoFuente + 2))
                                .fontWeight(.semibold)
                                .foregroundColor(.black)
                        }
                        .padding()
                        .background(appSettings.colorTema.opacity(0.5))
                        .cornerRadius(12)

                        // Fecha
                        Text("📅 \(diario.fecha.formatted(date: .long, time: .shortened))")
                            .foregroundColor(.gray)
                            .font(.custom(appSettings.fuente, size: appSettings.tamanoFuente - 2))

                        // Contenido (se respeta su HTML, sin cambios externos)
                        HTMLTextView(html: diario.contenido)
                            .frame(minHeight: 200)
                            .padding()
                            .background(appSettings.colorTema.opacity(0.5))
                            .cornerRadius(12)

                        // Imagen
                        if let urlStr = diario.imagenURL, let url = URL(string: urlStr) {
                            AsyncImage(url: url) { image in
                                image
                                    .resizable()
                                    .scaledToFit()
                                    .cornerRadius(12)
                                    .shadow(radius: 4)
                            } placeholder: {
                                ProgressView()
                            }
                            .frame(maxHeight: 250)
                            .padding(.vertical)
                        }

                        // Firma
                        if !firma.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("✍️ Firma del diario")
                                    .font(.custom(appSettings.fuente, size: appSettings.tamanoFuente - 2))

                                FirmaView(trazos: .constant(firma))
                                    .frame(height: 120)
                                    .background(appSettings.colorTema.opacity(0.5))
                                    .cornerRadius(12)
                                    .allowsHitTesting(false)
                            }
                        }

                        Spacer()
                    }
                    .padding()
                }
            }
            .navigationTitle(Text("Detalle del Diario Creado")
                                .font(.custom(appSettings.fuente, size: appSettings.tamanoFuente + 2)))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Detalle del Diario Creado")
                        .font(.custom(appSettings.fuente, size: appSettings.tamanoFuente + 2))
                        .foregroundColor(.black)
                }

                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.black)
                    }
                }
            }
            .toolbarBackground(appSettings.colorTema.opacity(0.8), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
    }
}

