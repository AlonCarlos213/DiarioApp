import SwiftUI

struct DiarioCardView: View {
    let diario: Diario
    let firma: [CGPoint]
    let isVisible: Bool

    var body: some View {
        if isVisible {
            VStack(spacing: 10) {
                Text(diario.emocion)
                    .font(.largeTitle)

                Text(diario.titulo)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.black)
                    .lineLimit(2)
                    .frame(maxWidth: .infinity)
            }
            .padding()
            .frame(width: 160, height: 160)
            .background(Color.white.opacity(0.5))
            .cornerRadius(20)
            .transition(.scale.combined(with: .opacity))
        }
    }
}

