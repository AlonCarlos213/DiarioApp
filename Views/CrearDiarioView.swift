import SwiftUI

struct CrearDiarioView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @EnvironmentObject var appSettings: AppSettings
    @Environment(\.dismiss) var dismiss
    
    // MARK: - Estados locales del formulario
    
    @State private var nombre = ""                      // Titulo del diario
    @State private var emocionSeleccionada = ""         // Emocion elegida por el usuario
    @State private var fecha = Date()                   // Fecha actual del diario
    @State private var firmaPuntos: [CGPoint] = []      // Firma dibujado por el usuario
    @State private var irAEscribir = false              // Control de navegacion al editor
    
    // MARK: - Lista de emociones disponibles
    
    let emociones = ["👍", "😌", "😠", "😍", "😘", "🥰", "😩", "😋", "😔"]
    
    // MARK: - Callbacks para notificar a la vista principal
    
    var onDiarioCreado: (_ diario: Diario, _ firma: [CGPoint]) -> Void
    var onFirmaRegistrada: (_ firma: [CGPoint]) -> Void

    var body: some View {
        NavigationStack {
            ZStack {
                Color.white.ignoresSafeArea()
                
                // MARK: - Contenido principal

                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        
                        // Titulo de la pantalla
                        Text("Personaliza tu Diario y dale un FEEL")
                            .font(.custom(appSettings.fuente, size: appSettings.tamanoFuente))
                            .padding(.top)
                        
                        // Campo para el nombre del diario
                        Text("Nombre de tu diario")
                            .font(.custom(appSettings.fuente, size: appSettings.tamanoFuente - 2))
                        TextField("Ej. Mi aventura", text: $nombre)
                            .padding()
                            .background(appSettings.colorTema.opacity(0.5))
                            .cornerRadius(12)
                            .font(.custom(appSettings.fuente, size: appSettings.tamanoFuente))
                        // Seleccion de emocion
                        Text("Elige una emoción")
                            .font(.custom(appSettings.fuente, size: appSettings.tamanoFuente - 2))
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(emociones, id: \.self) { emocion in
                                    Text(emocion)
                                        .font(.largeTitle)
                                        .padding(8)
                                        .background(emocion == emocionSeleccionada ? appSettings.colorTema.opacity(0.5) : Color.clear)
                                        .cornerRadius(10)
                                        .onTapGesture {
                                            emocionSeleccionada = emocion
                                        }
                                }
                            }
                        }
                        
                        // Mostrar fecha de creacion
                        Text("Fecha de creación")
                            .font(.custom(appSettings.fuente, size: appSettings.tamanoFuente - 2))
                        Text(fecha.format())
                            .padding(.vertical, 6)
                            .padding(.horizontal, 12)
                            .background(appSettings.colorTema.opacity(0.5))
                            .cornerRadius(10)
                            .font(.custom(appSettings.fuente, size: appSettings.tamanoFuente))
                        // Firma del diario
                        Text("Dibuja tu firma para continuar")
                            .font(.custom(appSettings.fuente, size: appSettings.tamanoFuente - 2))

                        FirmaView(trazos: $firmaPuntos)
                            .frame(height: 120)
                            .background(appSettings.colorTema.opacity(0.5))
                            .cornerRadius(12)
                        // Boton para limpiar la firma
                        Button("Limpiar Firma") {
                            firmaPuntos.removeAll()
                        }
                        .font(.custom(appSettings.fuente, size: appSettings.tamanoFuente - 4))
                        .foregroundColor(.red)
                        // Boton para continuar
                        Button("Continuar") {
                            onFirmaRegistrada(firmaPuntos)
                            irAEscribir = true
                        }
                        .font(.custom(appSettings.fuente, size: appSettings.tamanoFuente))
                        .fontWeight(.bold)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(appSettings.colorTema)
                        .foregroundColor(.white)
                        .cornerRadius(20)
                        .padding(.top, 30)
                        
                        // Navegacion al editor de contenido
                        NavigationLink(
                            destination: EscribirContenidoView(
                                nombreDiario: nombre,
                                emocion: emocionSeleccionada,
                                firmaPuntos: firmaPuntos,
                                onGuardar: { diario, firma in
                                    onDiarioCreado(diario, firma)
                                    // 🚀 Doble dismiss para volver a HomeView
                                    DispatchQueue.main.async {
                                        dismiss()
                                        dismiss()
                                    }
                                }
                            ).environmentObject(authVM),
                            isActive: $irAEscribir
                        ) {
                            EmptyView()
                        }
                    }
                    .padding()
                }
            }
            
            // MARK: - Toolbar
            
            .navigationBarBackButtonHidden(true)
            .toolbar {
                // Boton de retroceso
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.black)
                    }
                }
                
                // Titulo en la barra
                ToolbarItem(placement: .principal) {
                    Text("Crear Diario")
                        .font(.custom(appSettings.fuente, size: appSettings.tamanoFuente))
                        .foregroundColor(.black)
                }
            }
            .toolbarBackground(appSettings.colorTema.opacity(1), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
        .appStyle()
    }
}

