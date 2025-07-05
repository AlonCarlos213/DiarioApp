//
//  MarkdownView.swift
//  DiarioApp
//
//  Created by Carlos Alonso Mamani Ccollque on 30/06/25.
//

import SwiftUI
import Down

struct MarkdownView: UIViewRepresentable {
    var markdownText: String

    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.isEditable = false
        textView.backgroundColor = .clear
        textView.isScrollEnabled = false
        return textView
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        let down = Down(markdownString: markdownText)
        do {
            let attributedString = try down.toAttributedString()
            uiView.attributedText = attributedString
        } catch {
            uiView.text = markdownText // fallback si falla el parseo
        }
    }
}
