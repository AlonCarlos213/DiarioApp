import SwiftUI

struct ConfiguracionesView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authVM: AuthViewModel
    @EnvironmentObject var appSettings: AppSettings

    let colores: [Color] = [
        Color(hex: "#B1B3FB"),
        Color(hex: "#FF6B81"),
        Color(hex: "#FF66C4"),
        Color(hex: "#6BCB77"),
        Color(hex: "#4D96FF")
    ]

    let fuentes = ["System", "Klee One", "Arial", "Courier", "Chalkboard SE"]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    colorPicker
                    fontPicker
                    fontSizeButtons
                    links
                    cerrarSesionButton
                }
                .padding()
                .font(.custom(
                    appSettings.fuente == "System"
                        ? UIFont.systemFont(ofSize: appSettings.tamanoFuente).fontName
                        : appSettings.fuente,
                    size: appSettings.tamanoFuente
                ))
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
                    Text("Configuraciones")
                        .font(.custom(appSettings.fuente, size: appSettings.tamanoFuente + 2))
                        .foregroundColor(.black)
                }
            }
            .toolbarBackground(appSettings.colorTema.opacity(1), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .background(Color.white)
        }
        .appStyle()
    }

    var colorPicker: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Elige el color de tu agrado")
                .font(.headline)

            HStack {
                ForEach(colores, id: \.self) { color in
                    Circle()
                        .fill(color)
                        .frame(width: 30, height: 30)
                        .overlay(
                            Circle()
                                .stroke(color == appSettings.colorTema ? Color.black : Color.clear, lineWidth: 2)
                        )
                        .onTapGesture {
                            appSettings.colorTema = color
                            authVM.guardarEstiloActual() // Guarda al cambiar color
                        }
                }
            }
        }
    }

    var fontPicker: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Elige tu tipo de fuente")
                .font(.headline)

            Picker("Fuente", selection: $appSettings.fuente) {
                ForEach(fuentes, id: \.self) { fuente in
                    Text(fuente).tag(fuente)
                }
            }
            .pickerStyle(.menu)
            .padding()
            .background(appSettings.colorBoton.opacity(0.5))
            .cornerRadius(10)
            .onChange(of: appSettings.fuente) { _ in
                authVM.guardarEstiloActual() // Guarda al cambiar fuente
            }
        }
    }

    var fontSizeButtons: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Tamaño de fuente")
                .font(.headline)

            HStack(spacing: 30) {
                Button {
                    appSettings.tamanoFuente = 14
                    authVM.guardarEstiloActual() // Guarda al cambiar tamaño
                } label: {
                    Text("Aa")
                        .font(.system(size: 14))
                        .foregroundColor(.black)
                }

                Button {
                    appSettings.tamanoFuente = 22
                    authVM.guardarEstiloActual() // Guarda al cambiar tamaño
                } label: {
                    Text("Aa")
                        .font(.system(size: 22))
                        .foregroundColor(.black)
                }
            }
        }
    }

    var links: some View {
        VStack(spacing: 10) {
            NavigationLink(destination: ContactoView()) {
                Text("Contáctanos")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(appSettings.colorBoton.opacity(0.5))
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }

            NavigationLink(destination: SobreNosotrosView()) {
                Text("Sobre nosotros")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(appSettings.colorBoton.opacity(0.5))
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
    }

    var cerrarSesionButton: some View {
        Button("Cerrar sesión") {
            authVM.signOut()
            dismiss()
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.red.opacity(0.7))
        .foregroundColor(.white)
        .cornerRadius(10)
    }
}

