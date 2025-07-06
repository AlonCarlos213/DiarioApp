import SwiftUI
import FirebaseFirestore

struct HomeView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @EnvironmentObject var appSettings: AppSettings
    
    // MARK: - Estados principales
    
    @State private var diarios: [Diario] = []
    @State private var busqueda = ""
    @State private var firmas: [String: [CGPoint]] = [:]
    
    // MARK: - Control de navegación y acciones/
    
    @State private var mostrarEditor = false
    @State private var diarioSeleccionado: Diario?
    @State private var mostrarDetalle = false
    @State private var mostrarCompartir = false
    @State private var diariosEliminando: Set<String> = []
    @State private var mostrarPerfil = false
    @State private var fotoURL: String? = nil
    @State private var mostrarCrearDiario = false
    
    // MARK: - Filtro de búsqueda
    
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
    
    // MARK: - Vista principal

    var body: some View {
        NavigationStack {
            ZStack {
                Color.white.ignoresSafeArea()
                VStack(spacing: 10) {
                    // MARK: - Barra de búsqueda + perfil
                    HStack {
                        TextField("Buscar...", text: $busqueda)
                            .padding(9)
                            .background(appSettings.colorBoton.opacity(0.3))
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
                                        .foregroundColor(appSettings.colorBoton)
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

                    // MARK: - Grid de diarios
                    
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
                                            withAnimation(.easeOut(duration: 0.3)) {
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
                        .padding(.top, 20) // o ajusta a 30 o 40 si aún está muy pegado
                    }
                }

                // MARK: - Botón flotante de creación
                
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button {
                            mostrarCrearDiario = true
                        } label: {
                            Image(systemName: "plus")
                                .font(.title)
                                .foregroundColor(.white)
                                .padding()
                                .background(appSettings.colorBoton)
                                .clipShape(Circle())
                                .shadow(radius: 5)
                        }
                        .padding()
                    }
                }
            }
            
            // MARK: - Eventos del ciclo de vida
            
            .appStyle()
            .onAppear {
                cargarDiarios()
                cargarFotoPerfil()
                cargarDiariosCompartidos()
            }
            
            // MARK: - Sheets
            
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
                if let diario = diarioSeleccionado, let id = diario.id {
                    let enlace = URL(string: "diarioapp://diario?id=\(id)")!
                    ActivityView(activityItems: [enlace])
                } else if let diario = diarioSeleccionado {
                    let texto = """
                    📝 Diario: \(diario.titulo)
                    😄 Emoción: \(diario.emocion)
                    ✍️ Contenido:
                    \(diario.contenido)
                    """
                    ActivityView(activityItems: [texto])
                }
            }
            .sheet(isPresented: $mostrarCrearDiario) {
                CrearDiarioView(
                    onDiarioCreado: { diario, firma in
                        if let id = diario.id {
                            firmas[id] = firma
                        }
                        cargarDiarios()
                        mostrarCrearDiario = false // Esto cierra el sheet
                    },
                    onFirmaRegistrada: { _ in }
                )
                .environmentObject(authVM)
            }
        }
    }
    
    // MARK: - Cargar Diarios del usuario actual
    
    func cargarDiarios() {
        // Asegurarse que el usuario esté autenticado
        guard let userId = authVM.user?.uid else { return }

        let db = Firestore.firestore()
        // Consultar la colección de diarios del usuario ordenados por fecha
        db.collection("usuarios").document(userId).collection("diarios")
            .order(by: "fecha", descending: true)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error al cargar: \(error.localizedDescription)")
                    return
                }
                
                // Mapear los documentos obtenidos a instancias de Diario
                diarios = snapshot?.documents.compactMap { doc in
                    let data = doc.data()
                    let id = doc.documentID
                    let titulo = data["titulo"] as? String ?? ""
                    let contenido = data["contenido"] as? String ?? ""
                    let emocion = data["emocion"] as? String ?? ""
                    let fecha = (data["fecha"] as? Timestamp)?.dateValue() ?? Date()
                    let userId = data["userId"] as? String ?? ""
                    let firma = data["firma"] as? [[String: CGFloat]]
                    let compartidoCon = data["compartidoCon"] as? [String] ?? []
                    let imagenURL = data["imagenURL"] as? String

                    // Procesar firma y guardarla en el diccionario local
                    if let firmaArray = firma {
                        let puntos = firmaArray.compactMap { dict -> CGPoint? in
                            if let x = dict["x"], let y = dict["y"] {
                                return CGPoint(x: x, y: y)
                            }
                            return nil
                        }
                        firmas[id] = puntos
                    }

                    return Diario(
                        id: id,
                        titulo: titulo,
                        contenido: contenido,
                        emocion: emocion,
                        fecha: fecha,
                        userId: userId,
                        firma: firma,
                        imagenURL: imagenURL,
                        compartidoCon: compartidoCon
                    )
                } ?? []
            }
    }
    
    // MARK: - Eliminar un diario
    
    func eliminarDiario(_ diario: Diario) {
        // Verificar ID y usuario
        guard let id = diario.id, let userId = authVM.user?.uid else { return }

        Firestore.firestore()
            .collection("usuarios")
            .document(userId)
            .collection("diarios")
            .document(id)
            .delete { error in
                if let error = error {
                    print("Error al eliminar: \(error.localizedDescription)")
                } else {
                    // Eliminar de la lista local
                    diarios.removeAll { $0.id == id }
                }
            }
    }
    
    // MARK: - Formatear fecha a cadena legible
    
    func formatearFecha(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "es_PE")
        return formatter.string(from: date)
    }
    
    // MARK: - Cargar foto de perfil del usuario
    
    func cargarFotoPerfil() {
        guard let userId = authVM.user?.uid else { return }

        let db = Firestore.firestore()
        db.collection("usuarios").document(userId).getDocument { snapshot, error in
            if let data = snapshot?.data(), let url = data["fotoURL"] as? String {
                self.fotoURL = url
            }
        }
    }
    
    // MARK: - Cargar diarios compartidos con el usuario
    
    func cargarDiariosCompartidos() {
        guard let userId = authVM.user?.uid else { return }

        let db = Firestore.firestore()
        db.collectionGroup("diarios")
            .whereField("compartidoCon", arrayContains: userId)
            .order(by: "fecha", descending: true)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error al cargar compartidos: \(error.localizedDescription)")
                    return
                }
                // Mapear y agregar los diarios compartidos
                let compartidos: [Diario] = snapshot?.documents.compactMap { doc in
                    let data = doc.data()
                    let id = doc.documentID
                    let titulo = data["titulo"] as? String ?? ""
                    let contenido = data["contenido"] as? String ?? ""
                    let emocion = data["emocion"] as? String ?? ""
                    let fecha = (data["fecha"] as? Timestamp)?.dateValue() ?? Date()
                    let userId = data["userId"] as? String ?? ""
                    let firma = data["firma"] as? [[String: CGFloat]]
                    let compartidoCon = data["compartidoCon"] as? [String] ?? []
                    let imagenURL = data["imagenURL"] as? String

                    // Guardar firma en el diccionario
                    if let firmaArray = firma {
                        let puntos = firmaArray.compactMap { dict -> CGPoint? in
                            if let x = dict["x"], let y = dict["y"] {
                                return CGPoint(x: x, y: y)
                            }
                            return nil
                        }
                        firmas[id] = puntos
                    }
                    return Diario(
                        id: id,
                        titulo: titulo,
                        contenido: contenido,
                        emocion: emocion,
                        fecha: fecha,
                        userId: userId,
                        firma: firma,
                        imagenURL: imagenURL,
                        compartidoCon: compartidoCon
                    )
                } ?? []

                diarios.append(contentsOf: compartidos)
            }
    }
}
