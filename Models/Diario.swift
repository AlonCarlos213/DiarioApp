//
//  Diario.swift
//  DiarioApp
//
//  Created by Carlos Alonso Mamani Ccollque on 19/06/25.
//

import Foundation
import FirebaseFirestore

struct Diario: Identifiable, Codable,Equatable {
    @DocumentID var id: String?
    var titulo: String
    var contenido: String
    var emocion: String
    var fecha: Date
    var userId: String
    var firma: [[String: CGFloat]]? // 👈 firma serializada

    enum CodingKeys: String, CodingKey {
        case id
        case titulo
        case contenido
        case emocion
        case fecha
        case userId
        case firma
    }
}
