import SwiftUI

struct ContactoView: View {
    @EnvironmentObject var appSettings: AppSettings
    @Environment(\.dismiss) var dismiss
    @State private var mensaje = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Quejas o sugerencias")
                    .font(.custom(
                        appSettings.fuente == "System"
                            ? UIFont.systemFont(ofSize: appSettings.tamanoFuente).fontName
                            : appSettings.fuente,
                        size: appSettings.tamanoFuente
                    ))
                    .frame(maxWidth: .infinity, alignment: .leading)

                TextEditor(text: $mensaje)
                    .frame(height: 200)
                    .padding()
                    .background(appSettings.colorBoton.opacity(0.5))
                    .cornerRadius(12)

                Button("ENVIAR") {
                    print("Mensaje enviado: \(mensaje)")
                    mensaje = ""
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(appSettings.colorBoton.opacity(0.5))
                .foregroundColor(.white)
                .cornerRadius(12)

                Spacer()
            }
            .padding()
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
                    Text("Contacto")
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
}

