//
//  SafariWebView.swift
//  ScreenshotEditor
//
//  Created by Alastair McNeill on 15/08/2025.
//

import SwiftUI
import SafariServices

/// A SwiftUI wrapper for SFSafariViewController to display web content in-app
struct SafariWebView: UIViewControllerRepresentable {
    let url: URL
    
    func makeUIViewController(context: Context) -> SFSafariViewController {
        let config = SFSafariViewController.Configuration()
        config.entersReaderIfAvailable = false
        
        let safariViewController = SFSafariViewController(url: url, configuration: config)
        safariViewController.preferredBarTintColor = UIColor.systemBackground
        safariViewController.preferredControlTintColor = UIColor.systemBlue
        
        return safariViewController
    }
    
    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {
        // No updates needed
    }
}

/// A view modifier to present Safari web view
struct SafariView: ViewModifier {
    @Binding var isPresented: Bool
    let url: URL
    
    func body(content: Content) -> some View {
        content
            .sheet(isPresented: $isPresented) {
                SafariWebView(url: url)
                    .ignoresSafeArea()
            }
    }
}

extension View {
    /// Present an in-app Safari view for the given URL
    func safariView(isPresented: Binding<Bool>, url: URL) -> some View {
        modifier(SafariView(isPresented: isPresented, url: url))
    }
}
