//
//  VideoEmbedView.swift
//  StellarDaily
//
//  Created by Oleksandr Yevdokymov on 14.02.2026.
//

import SwiftUI
import WebKit

struct VideoEmbedView: UIViewRepresentable {
    let url: URL

    func makeCoordinator() -> Coordinator { Coordinator() }

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = [] // allow tap-to-play without extra restrictions

        let prefs = WKWebpagePreferences()
        prefs.allowsContentJavaScript = true
        config.defaultWebpagePreferences = prefs

        let webView = WKWebView(frame: .zero, configuration: config)
        webView.scrollView.isScrollEnabled = false
        webView.isOpaque = false
        webView.backgroundColor = .clear
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        // Prevent SwiftUI re-renders from reloading the same page
        guard context.coordinator.lastLoadedURL != url else { return }
        context.coordinator.lastLoadedURL = url

        var request = URLRequest(url: url)

        // Workaround for some YouTube embeds failing with "Error 153"
        let referrer = makeReferrer()
        request.setValue(referrer, forHTTPHeaderField: "Referer")
        request.setValue(referrer, forHTTPHeaderField: "Origin")

        webView.load(request)
    }

    private func makeReferrer() -> String {
        // Fallback keeps it non-empty even in weird test contexts
        let bundleId = Bundle.main.bundleIdentifier ?? "local.app"
        return "https://\(bundleId)".lowercased()
    }

    final class Coordinator {
        var lastLoadedURL: URL?
    }
}
