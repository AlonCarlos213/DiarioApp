import SwiftUI

struct CrearDiarioView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @EnvironmentObject var appSettings: AppSettings
    @Environment(\.dismiss) var dismiss

    @State private var nombre = ""
    @State private var emocionSeleccionada = ""
    @State private var fecha = Date()
    @State private var firmaPuntos: [CGPoint] = []
    @State private var irAEscribir = false

    let emociones = ["👍", "😌", "😠", "😍", "😘", "🥰", "😩", "😋", "😔"]

    var onDiarioCreado: (_ diario: Diario, _ firma: [CGPoint]) -> Void
    var onFirmaRegistrada: (_ firma: [CGPoint]) -> Void

    var body: some View {
        NavigationStack {
            ZStack {
                Color.white.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Personaliza tu Diario y dale un FEEL")
                            .font(.custom(appSettings.fuente, size: appSettings.tamanoFuente))
                            .padding(.top)

                        Text("Nombre de tu diario")
                            .font(.custom(appSettings.fuente, size: appSettings.tamanoFuente - 2))
                        TextField("Ej. Mi aventura", text: $nombre)
                            .padding()
                            .background(appSettings.colorTema.opacity(0.5))
                            .cornerRadius(12)
                            .font(.custom(appSettings.fuente, size: appSettings.tamanoFuente))

                        Text("Elige una emoción")
                            .font(.custom(appSettings.fuente, size: appSettings.tamanoFuente - 2))
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(emociones, id: \.self) { emocion in
                                    Text(emocion)
                                        .font(.largeTitle)
                                        .padding(8)
                                        .background(emocion == emocionSeleccionada ? appSettings.colorTema.opacity(0.5) : Color.clear)
                                        .cornerRadius(10)
                                        .onTapGesture {
                                            emocionSeleccionada = emocion
                                        }
                                }
                            }
                        }

                        Text("Fecha de creación")
                            .font(.custom(appSettings.fuente, size: appSettings.tamanoFuente - 2))
                        Text(fecha.format())
                            .padding(.vertical, 6)
                            .padding(.horizontal, 12)
                            .background(appSettings.colorTema.opacity(0.5))
                            .cornerRadius(10)
                            .font(.custom(appSettings.fuente, size: appSettings.tamanoFuente))

                        Text("Dibuja tu firma para continuar")
                            .font(.custom(appSettings.fuente, size: appSettings.tamanoFuente - 2))

                        FirmaView(trazos: $firmaPuntos)
                            .frame(height: 120)
                            .background(appSettings.colorTema.opacity(0.5))
                            .cornerRadius(12)

                        Button("Limpiar Firma") {
                            firmaPuntos.removeAll()
                        }
                        .font(.custom(appSettings.fuente, size: appSettings.tamanoFuente - 4))
                        .foregroundColor(.red)

                        Button("Continuar") {
                            onFirmaRegistrada(firmaPuntos)
                            irAEscribir = true
                        }
                        .font(.custom(appSettings.fuente, size: appSettings.tamanoFuente))
                        .fontWeight(.bold)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(appSettings.colorTema)
                        .foregroundColor(.white)
                        .cornerRadius(20)
                        .padding(.top, 30)

                        NavigationLink(
                            destination: EscribirContenidoView(
                                nombreDiario: nombre,
                                emocion: emocionSeleccionada,
                                firmaPuntos: firmaPuntos,
                                onGuardar: { diario, firma in
                                    onDiarioCreado(diario, firma)
                                    // 🚀 Doble dismiss para volver a HomeView
                                    DispatchQueue.main.async {
                                        dismiss()
                                        dismiss()
                                    }
                                }
                            ).environmentObject(authVM),
                            isActive: $irAEscribir
                        ) {
                            EmptyView()
                        }
                    }
                    .padding()
                }
            }
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
                    Text("Crear Diario")
                        .font(.custom(appSettings.fuente, size: appSettings.tamanoFuente))
                        .foregroundColor(.black)
                }
            }
            .toolbarBackground(appSettings.colorTema.opacity(1), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
        .appStyle()
    }
}

