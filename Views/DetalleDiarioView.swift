import SwiftUI

struct DetalleDiarioView: View {
    var diario: Diario
    var firma: [CGPoint]

    var body: some View {
        ZStack {
            Color(hex: "#B1B3FB").ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Emoción y Título
                    HStack(spacing: 12) {
                        Text(diario.emocion)
                            .font(.system(size: 48))
                        Text(diario.titulo)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                    }

                    // Fecha
                    Text("📅 \(diario.fecha.formatted(date: .long, time: .shortened))")
                        .foregroundColor(.gray)
                        .font(.subheadline)

                    // Contenido
                    Text(diario.contenido)
                        .font(.body)
                        .foregroundColor(.black)
                        .padding(.top, 10)

                    // Firma dibujada si hay puntos
                    if !firma.isEmpty {
                        Text("✍️ Firma del diario")
                            .font(.subheadline)
                            .padding(.top, 20)

                        FirmaView(trazos: .constant(firma)) // ✅ Etiqueta corregida
                            .frame(height: 120)
                            .background(Color.white.opacity(0.3))
                            .cornerRadius(12)
                            .allowsHitTesting(false)
                    }

                    Spacer()
                }
                .padding()
            }
        }
        .navigationTitle("Detalle del Diario")
        .navigationBarTitleDisplayMode(.inline)
    }
}

