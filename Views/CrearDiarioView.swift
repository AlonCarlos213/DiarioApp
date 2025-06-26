import SwiftUI

struct CrearDiarioView: View {
    @EnvironmentObject var authVM: AuthViewModel

    @State private var nombre = ""
    @State private var emocionSeleccionada = ""
    @State private var fecha = Date()
    @State private var firmaPuntos: [CGPoint] = []
    @State private var irAEscribir = false

    let emociones = ["👍", "😌", "😠", "😍", "😘", "🥰", "😩", "😋", "😔"]

    var onDiarioCreado: (_ diario: Diario, _ firma: [CGPoint]) -> Void
    var onFirmaRegistrada: (_ firma: [CGPoint]) -> Void

    var body: some View {
        ZStack {
            Color(hex: "#B1B3FB").ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Personaliza tu Diario y dale un FEEL")
                        .font(.headline)
                        .padding(.top)

                    Text("Nombre de tu diario")
                        .font(.subheadline)
                    TextField("Ej. Mi aventura", text: $nombre)
                        .padding()
                        .background(Color.white.opacity(0.3))
                        .cornerRadius(12)

                    Text("Elige una emoción")
                        .font(.subheadline)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(emociones, id: \.self) { emocion in
                                Text(emocion)
                                    .font(.largeTitle)
                                    .padding(8)
                                    .background(emocion == emocionSeleccionada ? Color(hex: "#8A8CFF") : Color.clear)
                                    .cornerRadius(10)
                                    .onTapGesture {
                                        emocionSeleccionada = emocion
                                    }
                            }
                        }
                    }

                    Text("Fecha de creación")
                        .font(.subheadline)
                    Text(fecha.format())
                        .padding(.vertical, 6)
                        .padding(.horizontal, 12)
                        .background(Color.white.opacity(0.3))
                        .cornerRadius(10)

                    Text("Dibuja tu firma para continuar")
                        .font(.subheadline)

                    FirmaView(trazos: $firmaPuntos)
                        .frame(height: 120)

                    Button("Limpiar Firma") {
                        firmaPuntos.removeAll()
                    }
                    .font(.caption)
                    .foregroundColor(.red)

                    Button("Continuar") {
                        onFirmaRegistrada(firmaPuntos)
                        irAEscribir = true
                    }
                    .fontWeight(.bold)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(hex: "#8A8CFF"))
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
    }
}

