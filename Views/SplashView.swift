import SwiftUI

struct SplashView: View {
    @State private var progress: CGFloat = 0.0
    @State private var isActive = false
    @State private var logoScale: CGFloat = 0.6
    @State private var logoOpacity = 0.0
    @State private var textOpacity = 0.0
    @State private var textOffset: CGFloat = 20

    var body: some View {
        if isActive {
            InicioView() // Cambia si necesitas redirigir según sesión
        } else {
            ZStack {
                Color(hex: "#B1B3FB").ignoresSafeArea()

                VStack(spacing: 30) {
                    // Imagen con animación de escala y opacidad
                    Image("mindscribe_logo")
                        .resizable()
                        .frame(width: 150, height: 150)
                        .clipShape(RoundedRectangle(cornerRadius: 25))
                        .scaleEffect(logoScale)
                        .opacity(logoOpacity)

                    // Texto con fade y desplazamiento suave
                    Text("MindScribe")
                        .font(.largeTitle)
                        .bold()
                        .foregroundColor(.black)
                        .opacity(textOpacity)
                        .offset(y: textOffset)

                    // Barra de progreso lineal animada
                    ProgressView(value: progress, total: 1.0)
                        .progressViewStyle(LinearProgressViewStyle(tint: .purple))
                        .frame(width: 200)
                }
                .onAppear {
                    // Animación imagen
                    withAnimation(.easeOut(duration: 1.2)) {
                        logoScale = 1.0
                        logoOpacity = 1.0
                    }

                    // Animación texto
                    withAnimation(.easeOut(duration: 1.0).delay(0.6)) {
                        textOpacity = 1.0
                        textOffset = 0
                    }

                    // Barra de carga
                    withAnimation(.linear(duration: 5.0)) {
                        progress = 1.0
                    }

                    // Transición después de 5 segundos
                    DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                        isActive = true
                    }
                }
            }
        }
    }
}

