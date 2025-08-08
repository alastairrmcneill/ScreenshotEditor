//
//  ShareSheet.swift
//  ScreenshotEditor
//
//  Created by Alastair McNeill on 08/08/2025.
//

import SwiftUI
import UIKit

/// A SwiftUI wrapper for UIActivityViewController
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    let excludedActivityTypes: [UIActivity.ActivityType]?
    
    init(items: [Any], excludedActivityTypes: [UIActivity.ActivityType]? = nil) {
        self.items = items
        self.excludedActivityTypes = excludedActivityTypes
    }
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let activityViewController = UIActivityViewController(
            activityItems: items,
            applicationActivities: nil
        )
        activityViewController.excludedActivityTypes = excludedActivityTypes
        return activityViewController
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        // No updates needed
    }
}
