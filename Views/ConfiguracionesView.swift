//
//  ConfiguracionesView.swift
//  DiarioApp
//
//  Created by Carlos Alonso Mamani Ccollque on 21/06/25.
//

import SwiftUI

struct ConfiguracionesView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authVM: AuthViewModel

    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("Cuenta")) {
                    NavigationLink(destination: Text("Editar perfil próximamente")) {
                        Label("Ajustes de cuenta", systemImage: "person.crop.circle")
                    }
                }

                Section(header: Text("Información")) {
                    NavigationLink(destination: Text("Formulario de contacto")) {
                        Label("Contacto", systemImage: "phone.fill")
                    }

                    NavigationLink(destination: Text("Información de la app")) {
                        Label("Sobre Nosotros", systemImage: "info.circle.fill")
                    }
                }

                Section {
                    Button(role: .destructive) {
                        authVM.signOut()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            dismiss() // cierra ConfiguracionesView
                        }
                    } label: {
                        Label("Cerrar sesión", systemImage: "rectangle.portrait.and.arrow.right")
                    }
                }
            }
            .navigationTitle("⚙️ Configuración")
        }
    }
}

#Preview {
    ConfiguracionesView()
        .environmentObject(AuthViewModel())
}

