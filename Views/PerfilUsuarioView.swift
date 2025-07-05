import SwiftUI
import Firebase
import FirebaseStorage
import FirebaseFirestore

struct PerfilUsuarioView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @EnvironmentObject var appSettings: AppSettings
    @Environment(\.dismiss) var dismiss

    @State private var descripcion = ""
    @State private var nombre = ""
    @State private var fotoURL: URL?

    @State private var navigateToConfiguraciones = false
    @State private var navigateToEditarPerfil = false

    @State private var showImagePicker = false
    @State private var selectedImage: UIImage?
    @State private var useCamera = true

    var body: some View {
        NavigationStack {
            ZStack {
                Color.white.ignoresSafeArea()

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 20) {
                        ZStack(alignment: .topTrailing) {
                            if let fotoURL = fotoURL {
                                AsyncImage(url: fotoURL) { image in
                                    image.resizable()
                                } placeholder: {
                                    ProgressView()
                                }
                                .frame(width: 140, height: 140)
                                .clipShape(Circle())
                                .shadow(radius: 5)
                            } else if let selectedImage = selectedImage {
                                Image(uiImage: selectedImage)
                                    .resizable()
                                    .frame(width: 140, height: 140)
                                    .clipShape(Circle())
                                    .shadow(radius: 5)
                            } else {
                                Circle()
                                    .fill(appSettings.colorBoton.opacity(0.5))
                                    .frame(width: 140, height: 140)
                                    .overlay(
                                        Image(systemName: "person.fill")
                                            .resizable()
                                            .scaledToFit()
                                            .foregroundColor(.white)
                                            .padding(30)
                                    )
                            }

                            Button {
                                navigateToEditarPerfil = true
                            } label: {
                                Image(systemName: "pencil")
                                    .padding(8)
                                    .background(Color.white)
                                    .clipShape(Circle())
                                    .shadow(radius: 2)
                            }
                            .offset(x: 10, y: -10)
                        }

                        Text(nombre.isEmpty ? "Alias" : nombre)
                            .font(.custom(appSettings.fuente, size: appSettings.tamanoFuente + 2))
                            .fontWeight(.semibold)

                        Group {
                            perfilCampo(titulo: "Nombres y Apellidos", valor: nombre)
                            perfilCampo(titulo: "Correo Electrónico", valor: authVM.user?.email ?? "Sin correo")
                            perfilCampo(titulo: "Descripción", valor: descripcion)
                        }
                        .padding(.horizontal)
                    }
                    .padding(.top, 10)
                    .padding(.bottom, 40)
                }

                NavigationLink("", destination: ConfiguracionesView(), isActive: $navigateToConfiguraciones)
                NavigationLink("", destination: EditarPerfilView(), isActive: $navigateToEditarPerfil)
            }
            .onAppear { cargarDatos() }
            .sheet(isPresented: $showImagePicker, onDismiss: subirImagen) {
                ImagePicker(sourceType: .camera, selectedImage: $selectedImage)
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
                    Text("Perfil de Usuario")
                        .font(.custom(appSettings.fuente, size: appSettings.tamanoFuente + 2))
                        .foregroundColor(.black)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        navigateToConfiguraciones = true
                    } label: {
                        Image(systemName: "gearshape")
                            .foregroundColor(.black)
                    }
                }
            }
            .toolbarBackground(appSettings.colorTema.opacity(1), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .appStyle()
        }
    }

    func cargarDatos() {
        guard let user = authVM.user else { return }
        let db = Firestore.firestore()

        db.collection("usuarios").document(user.uid).getDocument { snapshot, error in
            if let data = snapshot?.data() {
                self.nombre = data["nombre"] as? String ?? ""
                self.descripcion = data["descripcion"] as? String ?? ""
                if let urlString = data["fotoURL"] as? String, let url = URL(string: urlString) {
                    self.fotoURL = url
                }
            }
        }
    }

    func subirImagen() {
        guard let image = selectedImage,
              let imageData = image.jpegData(compressionQuality: 0.4),
              let user = authVM.user else { return }

        let storageRef = Storage.storage().reference().child("usuarios/\(user.uid)/fotoPerfil.jpg")

        storageRef.putData(imageData, metadata: nil) { metadata, error in
            if let error = error {
                print("Error al subir imagen: \(error.localizedDescription)")
                return
            }

            storageRef.downloadURL { url, error in
                if let url = url {
                    self.fotoURL = url
                    Firestore.firestore().collection("usuarios").document(user.uid)
                        .updateData(["fotoURL": url.absoluteString])
                }
            }
        }
    }

    func perfilCampo(titulo: String, valor: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(titulo)
                .font(.subheadline)
            RoundedRectangle(cornerRadius: 12)
                .fill(appSettings.colorBoton.opacity(0.5))
                .frame(height: 50)
                .overlay(
                    Text(valor)
                        .padding(.horizontal)
                        .frame(maxWidth: .infinity, alignment: .leading)
                )
        }
    }
}

