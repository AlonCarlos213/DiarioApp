import SwiftUI

struct SplashView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @State private var progress: CGFloat = 0.0
    @State private var isActive = false
    @State private var logoScale: CGFloat = 0.6
    @State private var logoOpacity = 0.0
    @State private var textOpacity = 0.0
    @State private var textOffset: CGFloat = 20

    var body: some View {
        if isActive {
            if authVM.user != nil {
                HomeView()
                    .onAppear {
                        authVM.cargarEstiloDelUsuario()
                    }
            } else {
                InicioView()
            }
        } else {
            ZStack {
                Color.white.ignoresSafeArea()

                VStack(spacing: 30) {
                    Image("mindscribe_logo")
                        .resizable()
                        .frame(width: 150, height: 150)
                        .clipShape(RoundedRectangle(cornerRadius: 25))
                        .scaleEffect(logoScale)
                        .opacity(logoOpacity)

                    Text("MindScribe")
                        .font(.largeTitle)
                        .bold()
                        .foregroundColor(.black)
                        .opacity(textOpacity)
                        .offset(y: textOffset)

                    ProgressView(value: progress, total: 1.0)
                        .progressViewStyle(LinearProgressViewStyle(tint: .purple))
                        .frame(width: 200)
                }
                .onAppear {
                    withAnimation(.easeOut(duration: 1.2)) {
                        logoScale = 1.0
                        logoOpacity = 1.0
                    }

                    withAnimation(.easeOut(duration: 1.0).delay(0.6)) {
                        textOpacity = 1.0
                        textOffset = 0
                    }

                    withAnimation(.linear(duration: 5.0)) {
                        progress = 1.0
                    }

                    DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                        isActive = true
                    }
                }
            }
        }
    }
}

