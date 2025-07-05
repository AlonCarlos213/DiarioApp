//
//  Diario.swift
//  DiarioApp
//
//  Created by Carlos Alonso Mamani Ccollque on 19/06/25.
//

import Foundation
import FirebaseFirestore

struct Diario: Identifiable, Codable, Equatable {
    @DocumentID var id: String?
    var titulo: String
    var contenido: String
    var emocion: String
    var fecha: Date
    var userId: String
    var firma: [[String: CGFloat]]? // 👈 firma serializada
    var imagenURL: String?          // 👈 URL de la imagen adjunta
    var compartidoCon: [String] = []

    enum CodingKeys: String, CodingKey {
        case id
        case titulo
        case contenido
        case emocion
        case fecha
        case userId
        case firma
        case imagenURL
        case compartidoCon
    }

    // 👉 AGREGA ESTE INIT
    init(
        id: String? = nil,
        titulo: String,
        contenido: String,
        emocion: String,
        fecha: Date,
        userId: String,
        firma: [[String: CGFloat]]? = nil,
        imagenURL: String? = nil,
        compartidoCon: [String] = []
    ) {
        self.id = id
        self.titulo = titulo
        self.contenido = contenido
        self.emocion = emocion
        self.fecha = fecha
        self.userId = userId
        self.firma = firma
        self.imagenURL = imagenURL
        self.compartidoCon = compartidoCon
    }
}
