import SwiftUI
import Firebase
import FirebaseStorage
import PhotosUI
import FirebaseFirestore

struct EditarPerfilView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @Environment(\.dismiss) var dismiss

    @State private var nombre = ""
    @State private var descripcion = ""
    @State private var imagenSeleccionada: UIImage?
    @State private var mostrarSelector = false
    @State private var itemSeleccionado: PhotosPickerItem? = nil

    var body: some View {
        ZStack {
            Color(hex: "#B1B3FB").ignoresSafeArea()

            VStack(spacing: 20) {
                // Encabezado
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.black)
                            .padding()
                    }
                    Spacer()
                    Text("Editar Perfil")
                        .font(.headline)
                    Spacer()
                    Image(systemName: "gearshape") // Ícono ficticio de configuración
                        .padding()
                        .opacity(0) // Para mantener simetría
                }

                Spacer()

                // Imagen de perfil
                ZStack {
                    if let imagen = imagenSeleccionada {
                        Image(uiImage: imagen)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 140, height: 140)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.white, lineWidth: 4))
                            .shadow(radius: 5)
                    } else {
                        Circle()
                            .fill(Color.white.opacity(0.3))
                            .frame(width: 140, height: 140)
                            .overlay(
                                Image(systemName: "person.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .padding(30)
                                    .foregroundColor(.white)
                            )
                    }

                    Button {
                        mostrarSelector = true
                    } label: {
                        Image(systemName: "pencil")
                            .padding(6)
                            .background(Color.white)
                            .clipShape(Circle())
                            .offset(x: 50, y: 50)
                    }
                }

                // Nombre
                VStack(alignment: .leading) {
                    Text("Nombres y Apellidos")
                        .font(.subheadline)
                    TextField("Nombre", text: $nombre)
                        .padding()
                        .background(Color.white.opacity(0.3))
                        .cornerRadius(12)
                }
                .padding(.horizontal)

                // Correo
                VStack(alignment: .leading) {
                    Text("Correo Electrónico")
                        .font(.subheadline)
                    Text(authVM.user?.email ?? "")
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.white.opacity(0.3))
                        .cornerRadius(12)
                }
                .padding(.horizontal)

                // Descripción
                VStack(alignment: .leading) {
                    Text("Descripción")
                        .font(.subheadline)
                    TextEditor(text: $descripcion)
                        .padding()
                        .frame(height: 100)
                        .background(Color.white.opacity(0.3))
                        .cornerRadius(12)
                }
                .padding(.horizontal)

                // Botón Guardar
                Button(action: {
                    guardarPerfil()
                }) {
                    Text("Guardar cambios")
                        .bold()
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color(hex: "#8A8CFF"))
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .padding(.horizontal)

                Spacer()
            }
            .padding()
        }
        .photosPicker(isPresented: $mostrarSelector, selection: $itemSeleccionado, matching: .images, preferredItemEncoding: .automatic)
        .onChange(of: itemSeleccionado) { nuevoItem in
            if let item = nuevoItem {
                item.loadTransferable(type: Data.self) { result in
                    DispatchQueue.main.async {
                        switch result {
                        case .success(let data):
                            if let data, let uiImage = UIImage(data: data) {
                                imagenSeleccionada = uiImage
                            }
                        case .failure(let error):
                            print("Error al cargar imagen: \(error.localizedDescription)")
                        }
                    }
                }
            }
        }
        .onAppear {
            if let user = authVM.user {
                nombre = user.displayName ?? ""
            }
        }
    }

    func guardarPerfil() {
        guard let user = authVM.user else { return }

        let db = Firestore.firestore()
        let userRef = db.collection("usuarios").document(user.uid)

        var datos: [String: Any] = [
            "nombre": nombre,
            "descripcion": descripcion
        ]

        if let imagen = imagenSeleccionada, let imageData = imagen.jpegData(compressionQuality: 0.8) {
            let storageRef = Storage.storage().reference().child("perfiles/\(user.uid).jpg")
            storageRef.putData(imageData, metadata: nil) { _, error in
                if let error = error {
                    print("Error al subir imagen:", error.localizedDescription)
                    return
                }

                storageRef.downloadURL { url, _ in
                    if let url = url {
                        datos["fotoURL"] = url.absoluteString
                        userRef.setData(datos, merge: true)
                    }
                }
            }
        } else {
            userRef.setData(datos, merge: true)
        }

        dismiss()
    }
}

