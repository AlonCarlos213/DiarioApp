import SwiftUI
import FirebaseFirestore

struct EscribirContenidoView: View {
    var nombreDiario: String
    var emocion: String
    var firmaPuntos: [CGPoint]

    @EnvironmentObject var authVM: AuthViewModel
    @Environment(\.dismiss) var dismiss

    var onGuardar: (_ diario: Diario, _ firma: [CGPoint]) -> Void

    @State private var contenido = ""
    @FocusState private var isFocused: Bool

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Color(hex: "#B1B3FB").ignoresSafeArea()

            VStack(alignment: .leading, spacing: 10) {
                Text("*\(nombreDiario)")
                    .font(.headline)
                    .padding(.top)

                TextEditor(text: $contenido)
                    .padding()
                    .background(Color.white.opacity(0.3))
                    .cornerRadius(20)
                    .shadow(color: isFocused ? Color.purple.opacity(0.5) : .clear, radius: 10, x: 0, y: 4)
                    .focused($isFocused)
                    .animation(.easeInOut(duration: 0.3), value: isFocused)
                    .frame(maxHeight: .infinity)

                Text("Firma registrada:")
                    .font(.subheadline)
                    .padding(.top)

                FirmaView(trazos: .constant(firmaPuntos))
                    .frame(height: 100)
                    .allowsHitTesting(false)
            }
            .padding()

            Button(action: {
                guardarDiario()
            }) {
                Image(systemName: "checkmark")
                    .foregroundColor(.black)
                    .font(.system(size: 24, weight: .bold))
                    .padding()
                    .background(Color(hex: "#8A8CFF"))
                    .clipShape(Circle())
            }
            .padding()
        }
    }

    func guardarDiario() {
        guard let userId = authVM.user?.uid else { return }

        let db = Firestore.firestore()
        let firmaConvertida = firmaPuntos.map { ["x": $0.x, "y": $0.y] }

        let data: [String: Any] = [
            "titulo": nombreDiario,
            "contenido": contenido,
            "emocion": emocion,
            "fecha": Timestamp(date: Date()), // ✅ importante para ordenar
            "userId": userId,
            "firma": firmaConvertida
        ]

        db.collection("diarios").addDocument(data: data) { error in
            if let error = error {
                print("Error al guardar: \(error.localizedDescription)")
            } else {
                // Crear modelo local para callback
                let diario = Diario(
                    id: nil, // El HomeView lo recargará correctamente con ID
                    titulo: nombreDiario,
                    contenido: contenido,
                    emocion: emocion,
                    fecha: Date(),
                    userId: userId,
                    firma: firmaConvertida
                )
                onGuardar(diario, firmaPuntos)
                dismiss()
            }
        }
    }
}

