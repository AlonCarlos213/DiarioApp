//
//  LoginView.swift
//  DiarioApp
//
//  Created by Carlos Alonso Mamani Ccollque on 13/06/25.
//

// Reemplaza el contenido actual de LoginView.swift por esto:

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var error: String?

    var body: some View {
        ZStack {
            Color(hex: "#B1B3FB").ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    Spacer(minLength: 40)

                    // Logo
                    Image("mindscribe_logo")
                        .resizable()
                        .frame(width: 120, height: 120)
                        .clipShape(RoundedRectangle(cornerRadius: 20))

                    // Título
                    Text("MindScribe")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.black)

                    // Campo: Email
                    TextField("Correo electrónico", text: $email)
                        .padding()
                        .background(Color(hex: "#8A8CFF"))
                        .foregroundColor(.black)
                        .cornerRadius(12)
                        .padding(.horizontal)

                    // Campo: Contraseña
                    SecureField("Contraseña", text: $password)
                        .padding()
                        .background(Color(hex: "#8A8CFF"))
                        .foregroundColor(.black)
                        .cornerRadius(12)
                        .padding(.horizontal)

                    // Error
                    if let error = error {
                        Text(error)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }

                    // Botón: Iniciar sesión
                    Button("Iniciar sesión") {
                        authVM.signInWithEmail(email: email, password: password) { err in
                            if let err = err {
                                error = err.localizedDescription
                            }
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(hex: "#8A8CFF"))
                    .foregroundColor(.white)
                    .cornerRadius(16)
                    .padding(.horizontal)

                    // Separador
                    Text("o")
                        .font(.caption)
                        .padding(.top, 10)

                    // Social buttons
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

                    // Ir a registro
                    NavigationLink(destination: RegisterView()) {
                        Text("Registrarse")
                            .font(.headline)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color(hex: "#8A8CFF"))
                            .foregroundColor(.white)
                            .cornerRadius(16)
                            .padding(.horizontal)
                    }

                    Spacer()
                }
                .padding(.bottom, 40)
            }
        }
        .ignoresSafeArea(.keyboard)
    }
}
