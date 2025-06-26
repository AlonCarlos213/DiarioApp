//
//  RegisterView.swift
//  DiarioApp
//
//  Created by Carlos Alonso Mamani Ccollque on 13/06/25.
//

import SwiftUI
import FirebaseAuth

struct RegisterView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @State private var nombres = ""
    @State private var apellidos = ""
    @State private var email = ""
    @State private var password = ""
    @State private var error: String?
    @State private var showVerificationAlert = false

    var body: some View {
        ZStack {
            Color(hex: "#B1B3FB").ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    Spacer(minLength: 30)

                    // Título
                    Text("Crear cuenta")
                        .font(.system(size: 26, weight: .bold))
                        .foregroundColor(.black)

                    // Campos de entrada
                    Group {
                        TextField("Nombres", text: $nombres)
                        TextField("Apellidos", text: $apellidos)
                        TextField("Correo electrónico", text: $email)
                            .keyboardType(.emailAddress)
                        SecureField("Contraseña", text: $password)
                    }
                    .padding()
                    .background(Color(hex: "#8A8CFF"))
                    .foregroundColor(.black)
                    .cornerRadius(12)
                    .padding(.horizontal)

                    // Error si existe
                    if let error = error {
                        Text(error)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }

                    // Separador
                    Text("o")
                        .font(.caption)
                        .padding(.top, 10)

                    // Botones sociales
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

                    // Botón principal
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
                    .background(Color(hex: "#8A8CFF"))
                    .foregroundColor(.white)
                    .cornerRadius(16)
                    .padding(.horizontal)

                    Spacer()
                }
                .padding(.bottom)
            }
        }
        .alert("Verificación enviada", isPresented: $showVerificationAlert) {
            Button("Entendido", role: .cancel) { }
        } message: {
            Text("Te hemos enviado un correo de verificación. Revisa tu bandeja de entrada antes de iniciar sesión.")
        }
    }
}
