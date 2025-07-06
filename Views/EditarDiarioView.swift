import SwiftUI
import FirebaseFirestore
import FirebaseStorage

struct EditarDiarioView: View {
    
    // MARK: - Dependencias del entorno y propiedades externas
    
    @EnvironmentObject var appSettings: AppSettings
    @Environment(\.dismiss) var dismiss
    var diario: Diario                      // Diario que se esta editando
    var onGuardar: () -> Void               // Callback al guardar
    
    // MARK: - Estados
    
    @State private var nuevoTitulo: String                      // Nuevo titulo del diario
    @State private var contenidoAttr: NSAttributedString        // Contenido con formato
    @State private var selectedImage: UIImage? = nil            // Imagen seleccionada
    @State private var mostrandoPicker = false                  // Mostrar picker de imagen
    @State private var mostrandoAlerta = false                  // Mostrar alerta de error
    @State private var mostrandoConfirmacion = false            // Mostrar confirmacion de guardado
    @State private var eliminarImagenActual = false             // Bandera para eliminar imagen actual
    
    // MARK: - Inicialización
    
    init(diario: Diario, onGuardar: @escaping () -> Void) {
        self.diario = diario
        self.onGuardar = onGuardar
        _nuevoTitulo = State(initialValue: diario.titulo)
        
        // Convertir el contenido HTML en NSAttributedString
        if let data = diario.contenido.data(using: .utf8),
           let attrStr = try? NSAttributedString(
                data: data,
                options: [.documentType: NSAttributedString.DocumentType.html],
                documentAttributes: nil
           ) {
            _contenidoAttr = State(initialValue: attrStr)
        } else {
            _contenidoAttr = State(initialValue: NSAttributedString(string: diario.contenido))
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.white.ignoresSafeArea()
                
                // MARK: - Contenido principal
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Campo para editar el título
                        TextField("Título", text: $nuevoTitulo)
                            .padding()
                            .background(appSettings.colorTema.opacity(0.5))
                            .cornerRadius(10)
                        
                        // Botones para aplicar formato al texto
                        HStack(spacing: 12) {
                            ForEach(toolbarItems, id: \.0) { item in
                                Button {
                                    NotificationCenter.default.post(name: item.1, object: nil)
                                } label: {
                                    Image(systemName: item.0)
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(.white)
                                        .padding(8)
                                        .background(appSettings.colorTema)
                                        .clipShape(Circle())
                                }
                            }
                        }
                        .padding(8)
                        .background(appSettings.colorTema.opacity(0.5))
                        .cornerRadius(12)
                        
                        // Area de contenido enriquecido
                        RichTextView(attributedText: $contenidoAttr)
                            .frame(minHeight: 250)
                            .padding(6)
                            .background(appSettings.colorTema.opacity(0.5))
                            .cornerRadius(12)
                        
                        // Mostrar imagen nueva o actual
                        if let image = selectedImage {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .cornerRadius(12)
                                .frame(maxHeight: 250)
                        } else if let urlStr = diario.imagenURL, !eliminarImagenActual, let url = URL(string: urlStr) {
                            AsyncImage(url: url) { image in
                                image
                                    .resizable()
                                    .scaledToFit()
                                    .cornerRadius(12)
                            } placeholder: {
                                ProgressView()
                            }
                            .frame(maxHeight: 250)
                            
                            // Boton para eliminar la imagen actual
                            Button("Eliminar imagen actual") {
                                eliminarImagenActual = true
                            }
                            .foregroundColor(.red)
                        }
                        
                        // Boton para seleccionar una nueva imagen
                        Button {
                            mostrandoPicker = true
                        } label: {
                            HStack {
                                Image(systemName: "photo")
                                Text("Adjuntar imagen")
                            }
                            .padding(8)
                            .foregroundColor(.white)
                            .background(appSettings.colorTema)
                            .cornerRadius(8)
                        }
                        
                        // Buton para guardar los cambios
                        Button("Guardar cambios") {
                            actualizarDiario()
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(appSettings.colorTema)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .shadow(color: appSettings.colorTema.opacity(0.5), radius: 5, x: 0, y: 3)
                        
                        // Confirmacion de guardado
                        if mostrandoConfirmacion {
                            Text("✅ Diario actualizado con éxito")
                                .foregroundColor(.green)
                                .font(.subheadline)
                                .transition(.opacity)
                        }
                    }
                    .padding()
                }
            }
            
            // MARK: - Toolbar y navegación/
            
            .navigationTitle("") // Deja vacío y colocamos el título como un ToolbarItem
            .navigationBarTitleDisplayMode(.inline)
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
                    Text("Editar Diario")
                        .font(.custom(appSettings.fuente, size: appSettings.tamanoFuente + 2))
                        .foregroundColor(.black)
                }
            }
            .toolbarBackground(appSettings.colorTema.opacity(0.8), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .sheet(isPresented: $mostrandoPicker) {
                ImagePicker(selectedImage: $selectedImage)
            }
            .alert("Error", isPresented: $mostrandoAlerta) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("No se pudo actualizar el diario. Intenta nuevamente.")
            }
        }
        .appStyle()
    }
    
    // MARK: - Botones del toolbar para dar formato
    
    var toolbarItems: [(String, Notification.Name)] {
        [
            ("bold", .applyBold),
            ("italic", .applyItalic),
            ("underline", .applyUnderline),
            ("highlighter", .applyHighlight),
            ("paintbrush", .applyTextColor),
            ("plus.magnifyingglass", .applyLarger),
            ("minus.magnifyingglass", .applySmaller)
        ]
    }
    
    // MARK: - Actualizar el diario en Firestore
    
    func actualizarDiario() {
        guard let id = diario.id else {
            mostrandoAlerta = true
            return
        }
        
        // Convertir el contenido enriquecido a HTML
        let mutableAttr = NSMutableAttributedString(attributedString: contenidoAttr)
        mutableAttr.addAttribute(
            .font,
            value: UIFont(name: "Arial", size: 18) ?? UIFont.systemFont(ofSize: 18),
            range: NSRange(location: 0, length: mutableAttr.length)
        )

        let htmlData = try? mutableAttr.data(
            from: NSRange(location: 0, length: mutableAttr.length),
            documentAttributes: [.documentType: NSAttributedString.DocumentType.html]
        )
        let htmlString = htmlData.flatMap { String(data: $0, encoding: .utf8) } ?? ""

        if let image = selectedImage {
            subirImagen(image) { url in
                guardarFirestore(titulo: nuevoTitulo, contenido: htmlString, imagenURL: url)
            }
        } else if eliminarImagenActual {
            guardarFirestore(titulo: nuevoTitulo, contenido: htmlString, imagenURL: nil)
        } else {
            guardarFirestore(titulo: nuevoTitulo, contenido: htmlString, imagenURL: diario.imagenURL)
        }
    }
    
    // MARK: - Subir imagen a Firebase Storage
    
    func subirImagen(_ image: UIImage, completion: @escaping (String?) -> Void) {
        guard let data = image.jpegData(compressionQuality: 0.8) else {
            completion(nil)
            return
        }

        let ref = Storage.storage().reference().child("diarios/\(UUID().uuidString).jpg")
        ref.putData(data, metadata: nil) { _, error in
            if let error = error {
                print("Error al subir imagen: \(error.localizedDescription)")
                completion(nil)
            } else {
                ref.downloadURL { url, _ in
                    completion(url?.absoluteString)
                }
            }
        }
    }
    
    // MARK: - Guardar cambios en Firestore
    
    func guardarFirestore(titulo: String, contenido: String, imagenURL: String?) {
        let db = Firestore.firestore()
        db.collection("usuarios")
            .document(diario.userId)
            .collection("diarios")
            .document(diario.id!)
            .updateData([
                "titulo": titulo,
                "contenido": contenido,
                "imagenURL": imagenURL ?? ""
            ]) { error in
                if let error = error {
                    print("Error al actualizar diario: \(error.localizedDescription)")
                    mostrandoAlerta = true
                } else {
                    mostrandoConfirmacion = true
                    onGuardar()
                }
            }
    }
}

