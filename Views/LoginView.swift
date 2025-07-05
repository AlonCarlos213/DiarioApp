import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @EnvironmentObject var appSettings: AppSettings
    @Environment(\.dismiss) var dismiss

    @State private var email = ""
    @State private var password = ""
    @State private var error: String?

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    Image("mindscribe_logo")
                        .resizable()
                        .frame(width: 120, height: 120)
                        .clipShape(RoundedRectangle(cornerRadius: 20))

                    Text("MindScribe")
                        .font(.custom(appSettings.fuente, size: appSettings.tamanoFuente + 4))
                        .fontWeight(.semibold)
                        .foregroundColor(.black)

                    TextField("Correo electrónico", text: $email)
                        .padding()
                        .background(appSettings.colorTema.opacity(0.3))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(appSettings.colorTema, lineWidth: 1)
                        )
                        .font(.custom(appSettings.fuente, size: appSettings.tamanoFuente))
                        .padding(.horizontal)

                    SecureField("Contraseña", text: $password)
                        .padding()
                        .background(appSettings.colorTema.opacity(0.3))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(appSettings.colorTema, lineWidth: 1)
                        )
                        .font(.custom(appSettings.fuente, size: appSettings.tamanoFuente))
                        .padding(.horizontal)

                    if let error = error {
                        Text(error)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                            .font(.custom(appSettings.fuente, size: appSettings.tamanoFuente - 2))
                            .padding(.horizontal)
                    }

                    Button("Iniciar sesión") {
                        authVM.signInWithEmail(email: email, password: password) { err in
                            if let err = err {
                                error = err.localizedDescription
                            }
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(appSettings.colorTema)
                    .foregroundColor(.white)
                    .cornerRadius(16)
                    .font(.custom(appSettings.fuente, size: appSettings.tamanoFuente + 2))
                    .padding(.horizontal)

                    Text("o")
                        .font(.custom(appSettings.fuente, size: appSettings.tamanoFuente - 2))
                        .foregroundColor(.gray)

                    HStack(spacing: 30) {
                        Button {
                            authVM.signInWithFacebook()
                        } label: {
                            Image("facebook_icon")
                                .resizable()
                                .frame(width: 44, height: 44)
                                .clipShape(Circle())
                        }

                        Button {
                            authVM.signInWithGoogle()
                        } label: {
                            Image("google_icon")
                                .resizable()
                                .frame(width: 44, height: 44)
                                .clipShape(Circle())
                        }
                    }

                    NavigationLink(destination: RegisterView()) {
                        Text("Registrarse")
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(appSettings.colorTema.opacity(0.5))
                            .foregroundColor(.white)
                            .cornerRadius(16)
                            .font(.custom(appSettings.fuente, size: appSettings.tamanoFuente + 2))
                            .padding(.horizontal)
                    }

                    Spacer()
                }
                .padding()
            }
        }
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
                Text("Iniciar sesión")
                    .font(.custom(appSettings.fuente, size: appSettings.tamanoFuente + 2))
                    .foregroundColor(.black)
            }
        }
        .toolbarBackground(appSettings.colorTema.opacity(1), for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }
}

