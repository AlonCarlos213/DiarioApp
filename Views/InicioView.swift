//
//  InicioView.swift
//  DiarioApp
//
//  Created by Carlos Alonso Mamani Ccollque on 19/06/25.
//

import SwiftUI

struct InicioView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                Spacer()

                // Imagen del logo
                Image("mindscribe_logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 160, height: 160)
                    .clipShape(RoundedRectangle(cornerRadius: 20))

                // Título
                Text("MindScribe")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.black)

                // Botón Iniciar sesión
                NavigationLink(destination: LoginView()) {
                    Text("Iniciar sesión")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(hex: "#8A8CFF"))
                        .foregroundColor(.white)
                        .cornerRadius(16)
                }

                // Botón Registrarse
                NavigationLink(destination: RegisterView()) {
                    Text("Registrarse")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(hex: "#8A8CFF"))
                        .foregroundColor(.white)
                        .cornerRadius(16)
                }

                Spacer()
            }
            .padding()
            .background(Color(hex: "#B1B3FB").ignoresSafeArea())
        }
    }
}

