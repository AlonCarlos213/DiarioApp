import SwiftUI
import FirebaseFirestore

struct HomeView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @State private var diarios: [Diario] = []
    @State private var busqueda = ""
    @State private var firmas: [String: [CGPoint]] = [:]

    @State private var mostrarEditor = false
    @State private var diarioSeleccionado: Diario?
    @State private var mostrarDetalle = false
    @State private var mostrarCompartir = false
    @State private var diariosEliminando: Set<String> = []
    @State private var mostrarPerfil = false
    @State private var fotoURL: String? = nil

    var diariosFiltrados: [Diario] {
        let texto = busqueda.lowercased()
        if texto.isEmpty {
            return diarios
        } else {
            return diarios.filter { diario in
                diario.titulo.lowercased().contains(texto) ||
                diario.contenido.lowercased().contains(texto)
            }
        }
    }

    let columnas = [
        GridItem(.flexible(), spacing: 15),
        GridItem(.flexible(), spacing: 15)
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "#B1B3FB").ignoresSafeArea()

                VStack(spacing: 10) {
                    // 🔍 Barra de búsqueda + botón de perfil
                    HStack {
                        TextField("Buscar...", text: $busqueda)
                            .padding(9)
                            .background(Color(hex: "#9DA6E8"))
                            .cornerRadius(20)
                            .padding(.leading)

                        Button {
                            mostrarPerfil = true
                        } label: {
                            if let url = fotoURL, let imageURL = URL(string: url) {
                                AsyncImage(url: imageURL) { image in
                                    image
                                        .resizable()
                                        .scaledToFill()
                                } placeholder: {
                                    ProgressView()
                                }
                                .frame(width: 40, height: 40)
                                .clipShape(Circle())
                            } else {
                                ZStack {
                                    Circle()
                                        .fill(Color.white)
                                        .frame(width: 42, height: 42)
                                        .shadow(radius: 3)

                                    Image(systemName: "person.crop.circle.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 36, height: 36)
                                        .foregroundColor(Color(hex: "#8A8CFF"))
                                }
                            }
                        }
                        .sheet(isPresented: $mostrarPerfil, onDismiss: {
                            cargarFotoPerfil()
                        }) {
                            PerfilUsuarioView()
                        }
                    }
                    .padding(.top)

                    // 📜 Grid de diarios
                    ScrollView {
                        LazyVGrid(columns: columnas, spacing: 15) {
                            ForEach(diariosFiltrados) { diario in
                                DiarioCardView(
                                    diario: diario,
                                    firma: firmas[diario.id ?? ""] ?? [],
                                    isVisible: !diariosEliminando.contains(diario.id ?? "")
                                )
                                .contextMenu {
                                    Button("Ver detalle") {
                                        diarioSeleccionado = diario
                                        mostrarDetalle = true
                                    }
                                    Button("Editar") {
                                        diarioSeleccionado = diario
                                        mostrarEditor = true
                                    }
                                    Button("Eliminar", role: .destructive) {
                                        if let id = diario.id {
                                            withAnimation {
                                                diariosEliminando.insert(id)
                                            }
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                                eliminarDiario(diario)
                                                diariosEliminando.remove(id)
                                            }
                                        }
                                    }
                                    Button("Compartir") {
                                        diarioSeleccionado = diario
                                        mostrarCompartir = true
                                    }
                                }
                            }
                        }
                        .padding([.horizontal, .bottom])
                        .animation(.spring(), value: diariosFiltrados)
                        .padding(.top, 20) // o ajusta a 30 o 40 si aún está muy pegado
                    }
                }

                // ➕ Botón flotante
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        NavigationLink(destination:
                            CrearDiarioView(
                                onDiarioCreado: { diario, firma in
                                    if let id = diario.id {
                                        firmas[id] = firma
                                    }
                                    cargarDiarios()
                                },
                                onFirmaRegistrada: { _ in }
                            ).environmentObject(authVM)
                        ) {
                            Image(systemName: "plus")
                                .font(.title)
                                .foregroundColor(.white)
                                .padding()
                                .background(Color(hex: "#8A8CFF"))
                                .clipShape(Circle())
                                .shadow(radius: 5)
                        }
                        .padding()
                    }
                }
            }
            .onAppear {
                cargarDiarios()
                cargarFotoPerfil()
            }
            .sheet(isPresented: Binding<Bool>(
                get: { diarioSeleccionado != nil && (mostrarEditor || mostrarDetalle) },
                set: { newValue in
                    if !newValue {
                        diarioSeleccionado = nil
                        mostrarEditor = false
                        mostrarDetalle = false
                        cargarDiarios()
                    }
                })
            ) {
                if let diario = diarioSeleccionado {
                    if mostrarEditor {
                        EditarDiarioView(
                            diario: diario,
                            onGuardar: {
                                mostrarEditor = false
                                diarioSeleccionado = nil
                                cargarDiarios()
                            }
                        )
                    } else if mostrarDetalle {
                        DetalleDiarioView(
                            diario: diario,
                            firma: firmas[diario.id ?? ""] ?? []
                        )
                    }
                }
            }
            .sheet(isPresented: $mostrarCompartir) {
                if let diario = diarioSeleccionado {
                    let titulo = diario.titulo
                    let emocion = diario.emocion
                    let fecha = formatearFecha(diario.fecha)
                    let contenido = diario.contenido.isEmpty ? "Sin contenido registrado." : diario.contenido

                    ActivityView(activityItems: [
                        """
                        📝 Diario: \(titulo)
                        😄 Emoción: \(emocion)
                        📅 Fecha: \(fecha)

                        ✍️ Contenido:
                        \(contenido)
                        """
                    ])
                }
            }
        }
    }

    func cargarDiarios() {
        guard let userId = authVM.user?.uid else { return }

        let db = Firestore.firestore()
        db.collection("diarios")
            .whereField("userId", isEqualTo: userId)
            .order(by: "fecha", descending: true)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error al cargar: \(error.localizedDescription)")
                    return
                }

                diarios = snapshot?.documents.compactMap {
                    var diario = try? $0.data(as: Diario.self)
                    diario?.id = $0.documentID

                    if let firmaArray = $0.data()["firma"] as? [[String: CGFloat]],
                       let id = diario?.id {
                        let puntos = firmaArray.compactMap { dict in
                            if let x = dict["x"], let y = dict["y"] {
                                return CGPoint(x: x, y: y)
                            }
                            return nil
                        }
                        firmas[id] = puntos
                    }

                    return diario
                } ?? []
            }
    }

    func eliminarDiario(_ diario: Diario) {
        guard let id = diario.id else { return }

        Firestore.firestore().collection("diarios").document(id).delete { error in
            if let error = error {
                print("Error al eliminar: \(error.localizedDescription)")
            } else {
                diarios.removeAll { $0.id == id }
            }
        }
    }
    func formatearFecha(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "es_PE")
        return formatter.string(from: date)
    }
    func cargarFotoPerfil() {
        guard let userId = authVM.user?.uid else { return }

        let db = Firestore.firestore()
        db.collection("usuarios").document(userId).getDocument { snapshot, error in
            if let data = snapshot?.data(), let url = data["fotoURL"] as? String {
                self.fotoURL = url
            }
        }
    }
}
    
