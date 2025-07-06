import SwiftUI
import Firebase
import FirebaseStorage
import PhotosUI
import FirebaseFirestore

struct EditarPerfilView: View {
    
    // MARK: - Dependencias del entorno
    
    @EnvironmentObject var authVM: AuthViewModel
    @EnvironmentObject var appSettings: AppSettings
    @Environment(\.dismiss) var dismiss
    
    // MARK: - Estados
    
    @State private var nombre = ""                                  // Nombre ingresado por el usuario
    @State private var descripcion = ""                             // Descripcion ingresada por el usuario
    @State private var imagenSeleccionada: UIImage?                 // Imagen de perfil seleccionada
    @State private var itemSeleccionado: PhotosPickerItem? = nil    // Item seleccionado desde la galeria o camara

    @State private var mostrarActionSheet = false                   // Mostrar opciones de seleccion de imagen
    @State private var mostrarPhotosPicker = false                  // Mostrar picker de fotos
    @State private var mostrarCameraPicker = false                  // Mostrar picker de camara

    var body: some View {
        NavigationStack {
            ZStack {
                Color.white.ignoresSafeArea()
                
                // MARK: - Formulario principal
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Imagen de perfil
                        ZStack(alignment: .bottomTrailing) {
                            if let imagen = imagenSeleccionada {
                                // Imagen seleccionada por el usuario
                                Image(uiImage: imagen)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 140, height: 140)
                                    .clipShape(Circle())
                                    .shadow(radius: 5)
                            } else {
                                // Imagen por efecto
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
                            // Boton para cambiar imagen
                            Button {
                                mostrarActionSheet = true
                            } label: {
                                Image(systemName: "pencil")
                                    .padding(6)
                                    .background(appSettings.colorBoton)
                                    .clipShape(Circle())
                                    .shadow(radius: 2)
                            }
                        }
                        .frame(width: 140, height: 140)

                        // Campo de nombre
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Nombres y Apellidos")
                                .font(.subheadline)
                            TextField("Nombre", text: $nombre)
                                .padding()
                                .background(appSettings.colorBoton.opacity(0.5))
                                .cornerRadius(12)
                        }

                        // Mostrar correo del usuario
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Correo Electrónico")
                                .font(.subheadline)
                            Text(authVM.user?.email ?? "")
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(appSettings.colorBoton.opacity(0.5))
                                .cornerRadius(12)
                        }

                        // Campo de descripcion
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Descripción")
                                .font(.subheadline)
                            TextEditor(text: $descripcion)
                                .padding()
                                .frame(height: 100)
                                .background(appSettings.colorBoton.opacity(0.5))
                                .cornerRadius(12)
                        }

                        // Botón para guardar
                        Button {
                            guardarPerfil()
                        } label: {
                            Text("Guardar cambios")
                                .bold()
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(appSettings.colorBoton)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }
                    }
                    .padding()
                }
            }
            
            // MARK: - Toolbar y navegacion
            
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button { dismiss() } label: {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.black)
                    }
                }
                ToolbarItem(placement: .principal) {
                    Text("Editar Perfil")
                        .font(.custom(appSettings.fuente, size: appSettings.tamanoFuente + 2))
                        .foregroundColor(.black)
                }
            }
            .toolbarBackground(appSettings.colorTema.opacity(1), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            
            // MARK: - Action sheet para seleccionar foto
            
            .actionSheet(isPresented: $mostrarActionSheet) {
                ActionSheet(
                    title: Text("Seleccionar foto"),
                    buttons: [
                        .default(Text("Galería")) { mostrarPhotosPicker = true },
                        .default(Text("Cámara")) { mostrarCameraPicker = true },
                        .cancel()
                    ]
                )
            }
            
            // MARK: - Pickers
            
            .photosPicker(isPresented: $mostrarPhotosPicker, selection: $itemSeleccionado, matching: .images, preferredItemEncoding: .automatic)
            .sheet(isPresented: $mostrarCameraPicker) {
                ImagePicker(sourceType: .camera, selectedImage: $imagenSeleccionada)
            }
            
            // MARK: - Reaccionar al cambio de foto seleccionada
            
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
            
            // Cargar datos actuales del usuario al aparecer
            .onAppear {
                if let user = authVM.user {
                    nombre = user.displayName ?? ""
                }
            }
            .appStyle()
        }
    }
    
    // MARK: - Guardar cambios en Firestore y Firebase Storage
    
    func guardarPerfil() {
        guard let user = authVM.user else { return }

        let db = Firestore.firestore()
        let userRef = db.collection("usuarios").document(user.uid)

        var datos: [String: Any] = [
            "nombre": nombre,
            "descripcion": descripcion
        ]
        
        // Si hay nueva imagen, subir al Storage y actualizar Firestore
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
            // Solo actualizar Firestore
            userRef.setData(datos, merge: true)
        }

        dismiss()
    }
}

