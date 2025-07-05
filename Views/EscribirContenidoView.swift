import SwiftUI
import FirebaseFirestore
import FirebaseStorage

struct EscribirContenidoView: View {
    var nombreDiario: String
    var emocion: String
    var firmaPuntos: [CGPoint]
    @EnvironmentObject var appSettings: AppSettings
    @EnvironmentObject var authVM: AuthViewModel
    @Environment(\.dismiss) var dismiss

    var onGuardar: (_ diario: Diario, _ firma: [CGPoint]) -> Void

    @State private var contenidoAttr = NSAttributedString(string: "")
    @State private var selectedImage: UIImage? = nil
    @State private var mostrandoPicker = false

    @State private var imageScale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var imageOffset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                Color.white.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("*\(nombreDiario)")
                            .font(.custom(appSettings.fuente, size: appSettings.tamanoFuente + 2))
                            .fontWeight(.semibold)
                            .foregroundColor(.black)
                            .padding(.top)
                            .padding(.bottom, 4)
                            .background(appSettings.colorTema.opacity(0.5))
                            .cornerRadius(10)

                        HStack(spacing: 14) {
                            ForEach(toolbarItems, id: \.0) { item in
                                Button {
                                    NotificationCenter.default.post(name: item.1, object: nil)
                                } label: {
                                    Image(systemName: item.0)
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(.black)
                                        .padding(8)
                                        .background(appSettings.colorBoton.opacity(0.5))
                                        .clipShape(Circle())
                                }
                            }
                        }
                        .padding(8)
                        .background(appSettings.colorBoton.opacity(0.5))
                        .cornerRadius(12)

                        RichTextView(attributedText: $contenidoAttr)
                            .frame(minHeight: 250)
                            .padding(6)
                            .background(appSettings.colorBoton.opacity(0.5))
                            .cornerRadius(16)

                        if let image = selectedImage {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .scaleEffect(imageScale)
                                .offset(imageOffset)
                                .gesture(
                                    SimultaneousGesture(
                                        DragGesture()
                                            .onChanged { value in
                                                imageOffset = CGSize(
                                                    width: value.translation.width + lastOffset.width,
                                                    height: value.translation.height + lastOffset.height
                                                )
                                            }
                                            .onEnded { _ in
                                                lastOffset = imageOffset
                                            },
                                        MagnificationGesture()
                                            .onChanged { value in
                                                imageScale = lastScale * value
                                            }
                                            .onEnded { _ in
                                                lastScale = imageScale
                                            }
                                    )
                                )
                                .frame(maxWidth: .infinity, maxHeight: 250)
                                .cornerRadius(16)
                                .shadow(radius: 4)
                                .padding(.vertical)
                        }

                        Button {
                            mostrandoPicker = true
                        } label: {
                            HStack {
                                Image(systemName: "photo")
                                Text("Adjuntar imagen")
                            }
                            .font(.body)
                            .foregroundColor(appSettings.colorBoton)
                        }

                        Text("Firma registrada:")
                            .font(.custom(appSettings.fuente, size: appSettings.tamanoFuente - 2))
                            .foregroundColor(.gray)
                            .padding(.top, 8)

                        FirmaView(trazos: .constant(firmaPuntos))
                            .frame(height: 100)
                            .background(appSettings.colorBoton.opacity(0.5))
                            .cornerRadius(12)
                            .allowsHitTesting(false)
                    }
                    .padding()
                }

                Button(action: guardarDiario) {
                    Image(systemName: "checkmark")
                        .font(.system(size: 26, weight: .bold))
                        .foregroundColor(.white)
                        .padding()
                        .background(appSettings.colorBoton)
                        .clipShape(Circle())
                        .shadow(radius: 4)
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
                    Text("Escribir Contenido")
                        .font(.custom(appSettings.fuente, size: appSettings.tamanoFuente + 2))
                        .foregroundColor(.black)
                }
            }
            .toolbarBackground(appSettings.colorTema.opacity(1), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .sheet(isPresented: $mostrandoPicker) {
                ImagePicker(selectedImage: $selectedImage)
            }
            .appStyle()
        }
    }

    var toolbarItems: [(String, Notification.Name)] {
        [
            ("bold", .applyBold),
            ("italic", .applyItalic),
            ("underline", .applyUnderline),
            ("highlighter", .applyHighlight),
            ("paintbrush", .applyTextColor),
            ("textformat.size.larger", .applyLarger),
            ("textformat.size.smaller", .applySmaller),
            ("textformat", .applyTitle)
        ]
    }

    func guardarDiario() {
        guard let userId = authVM.user?.uid else { return }

        let firmaConvertida = firmaPuntos.map { ["x": $0.x, "y": $0.y] }

        let htmlData = try? contenidoAttr.data(
            from: NSRange(location: 0, length: contenidoAttr.length),
            documentAttributes: [.documentType: NSAttributedString.DocumentType.html]
        )
        let htmlString = htmlData.flatMap { String(data: $0, encoding: .utf8) } ?? ""

        if let image = selectedImage {
            subirImagen(image) { urlString in
                guardarEnFirestore(userId: userId, htmlString: htmlString, firma: firmaConvertida, imagenURL: urlString)
            }
        } else {
            guardarEnFirestore(userId: userId, htmlString: htmlString, firma: firmaConvertida, imagenURL: nil)
        }
    }

    func subirImagen(_ image: UIImage, completion: @escaping (String?) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            completion(nil)
            return
        }

        let storageRef = Storage.storage().reference().child("diarios/\(UUID().uuidString).jpg")
        storageRef.putData(imageData, metadata: nil) { _, error in
            if let error = error {
                print("Error al subir imagen: \(error.localizedDescription)")
                completion(nil)
            } else {
                storageRef.downloadURL { url, error in
                    completion(url?.absoluteString)
                }
            }
        }
    }

    func guardarEnFirestore(userId: String, htmlString: String, firma: [[String: CGFloat]], imagenURL: String?) {
        let db = Firestore.firestore()
        var data: [String: Any] = [
            "titulo": nombreDiario,
            "contenido": htmlString,
            "emocion": emocion,
            "fecha": Timestamp(date: Date()),
            "firma": firma,
            "userId": userId
        ]

        if let imagenURL = imagenURL {
            data["imagenURL"] = imagenURL
        }

        db.collection("usuarios")
            .document(userId)
            .collection("diarios")
            .addDocument(data: data) { error in
                if let error = error {
                    print("Error al guardar: \(error.localizedDescription)")
                } else {
                    let diario = Diario(
                        id: nil,
                        titulo: nombreDiario,
                        contenido: htmlString,
                        emocion: emocion,
                        fecha: Date(),
                        userId: userId,
                        firma: firma,
                        imagenURL: imagenURL
                    )
                    onGuardar(diario, firmaPuntos)
                    // 🚀 Cierra la pila de navegación hasta HomeView
                    DispatchQueue.main.async {
                        // Doble dismiss por seguridad
                        dismiss()
                        dismiss()
                    }
                }
            }
    }
}

