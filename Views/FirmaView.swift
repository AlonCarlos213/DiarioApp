//
//  FirmaView.swift
//  DiarioApp
//
//  Created by Carlos Alonso Mamani Ccollque on 20/06/25.
//

import SwiftUI

struct FirmaView: View {
    @Binding var trazos: [CGPoint]
    @EnvironmentObject var appSettings: AppSettings

    var body: some View {
        ZStack {
            appSettings.colorBoton.opacity(0.2)
                .cornerRadius(12)
            Canvas { context, size in
                var path = Path()
                for point in trazos {
                    if point == .zero {
                        path.move(to: .zero)
                    } else {
                        path.addLine(to: point)
                    }
                }
                context.stroke(path, with: .color(.black), lineWidth: 2)
            }
            .gesture(DragGesture(minimumDistance: 0.1)
                .onChanged { value in
                    trazos.append(value.location)
                }
                .onEnded { _ in
                    trazos.append(.zero)
                }
            )
        }
        .frame(height: 120)
    }
}
