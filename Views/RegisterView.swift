import SwiftUI
import FirebaseAuth

struct RegisterView: View {
    @EnvironmentObject var appSettings: AppSettings
    @EnvironmentObject var authVM: AuthViewModel
    @Environment(\.dismiss) var dismiss

    @State private var nombres = ""
    @State private var apellidos = ""
    @State private var email = ""
    @State private var password = ""
    @State private var error: String?
    @State private var showVerificationAlert = false

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    Text("Crear cuenta")
                        .font(.custom(appSettings.fuente, size: appSettings.tamanoFuente + 4))
                        .fontWeight(.semibold)
                        .foregroundColor(.black)

                    Group {
                        TextField("Nombres", text: $nombres)
                        TextField("Apellidos", text: $apellidos)
                        TextField("Correo electrónico", text: $email)
                            .keyboardType(.emailAddress)
                        SecureField("Contraseña", text: $password)
                    }
                    .padding()
                    .background(appSettings.colorTema.opacity(0.3))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(appSettings.colorTema, lineWidth: 1)
                    )
                    .font(.custom(appSettings.fuente, size: appSettings.tamanoFuente))
                    .padding(.horizontal)
                    .foregroundColor(.black)

                    if let error = error {
                        Text(error)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                            .font(.custom(appSettings.fuente, size: appSettings.tamanoFuente - 2))
                            .padding(.horizontal)
                    }

                    Button("Registrarse") {
                        authVM.registerWithEmail(email: email, password: password) { err in
                            if let err = err as NSError? {
                                if err.code == AuthErrorCode.emailAlreadyInUse.rawValue {
                                    error = "Este correo ya está registrado. Intenta iniciar sesión."
                                } else {
                                    error = err.localizedDescription
                                }
                            } else {
                                error = nil
                                showVerificationAlert = true
                                if let user = Auth.auth().currentUser {
                                    let changeRequest = user.createProfileChangeRequest()
                                    changeRequest.displayName = "\(nombres) \(apellidos)"
                                    changeRequest.commitChanges(completion: nil)
                                }
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
                Text("Registro")
                    .font(.custom(appSettings.fuente, size: appSettings.tamanoFuente + 2))
                    .foregroundColor(.black)
            }
        }
        .toolbarBackground(appSettings.colorTema.opacity(1), for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .alert("Verificación enviada", isPresented: $showVerificationAlert) {
            Button("Entendido", role: .cancel) { }
        } message: {
            Text("Te hemos enviado un correo de verificación. Revisa tu bandeja de entrada antes de iniciar sesión.")
        }
    }
}

