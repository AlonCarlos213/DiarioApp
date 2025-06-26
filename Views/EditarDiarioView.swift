import SwiftUI
import FirebaseFirestore

struct EditarDiarioView: View {
    @Environment(\.dismiss) var dismiss
    var diario: Diario
    var onGuardar: () -> Void

    @State private var nuevoTitulo: String
    @State private var nuevoContenido: String
    @State private var mostrandoAlerta = false
    @State private var mostrandoConfirmacion = false

    init(diario: Diario, onGuardar: @escaping () -> Void) {
        self.diario = diario
        self.onGuardar = onGuardar
        _nuevoTitulo = State(initialValue: diario.titulo)
        _nuevoContenido = State(initialValue: diario.contenido)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "#B1B3FB").ignoresSafeArea()

                VStack(spacing: 20) {
                    TextField("Título", text: $nuevoTitulo)
                        .padding()
                        .background(Color.white.opacity(0.3))
                        .cornerRadius(10)

                    TextEditor(text: $nuevoContenido)
                        .padding()
                        .background(Color.white.opacity(0.3))
                        .cornerRadius(10)
                        .frame(height: 250)

                    Button("Guardar cambios") {
                        actualizarDiario()
                    }
                    .padding()
                    .background(Color(hex: "#8A8CFF"))
                    .foregroundColor(.white)
                    .cornerRadius(10)

                    // ✅ MENSAJE FIJO DE CONFIRMACIÓN DEBAJO DEL BOTÓN
                    if mostrandoConfirmacion {
                        Text("✅ Diario actualizado con éxito")
                            .foregroundColor(.green)
                            .font(.subheadline)
                            .transition(.opacity)
                    }

                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Editar Diario")
            .navigationBarTitleDisplayMode(.inline)
            .alert("Error", isPresented: $mostrandoAlerta) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("No se pudo actualizar el diario. Intenta nuevamente.")
            }
        }
    }

    func actualizarDiario() {
        guard let id = diario.id else { return }

        let db = Firestore.firestore()
        db.collection("diarios").document(id).updateData([
            "titulo": nuevoTitulo,
            "contenido": nuevoContenido
        ]) { error in
            if let error = error {
                print("Error al actualizar diario: \(error.localizedDescription)")
                mostrandoAlerta = true
            } else {
                mostrandoConfirmacion = true
                onGuardar() // por si deseas recargar datos en pantalla principal
            }
        }
    }
}

