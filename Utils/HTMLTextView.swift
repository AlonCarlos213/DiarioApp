//
//  HTMLTextView.swift
//  DiarioApp
//
//  Created by Carlos Alonso Mamani Ccollque on 1/07/25.
//

import SwiftUI
import WebKit

struct HTMLTextView: UIViewRepresentable {
    var html: String

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.backgroundColor = .clear
        webView.isOpaque = false
        webView.scrollView.isScrollEnabled = false
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        let wrappedHTML = """
        <html>
        <head>
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <style>
        body { font-family: -apple-system; background-color: transparent; color: black; }
        </style>
        </head>
        <body>\(html)</body>
        </html>
        """
        uiView.loadHTMLString(wrappedHTML, baseURL: nil)
    }
}
