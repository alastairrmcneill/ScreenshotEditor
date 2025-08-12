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
    
    /// Creates a ShareSheet optimized for saving images to Photos
    static func forImageSaving(image: UIImage) -> ShareSheet {
        // Exclude less relevant activities to make "Save to Photos" more prominent
        let excludedTypes: [UIActivity.ActivityType] = [
            .assignToContact,
            .print,
            .addToReadingList,
            .postToVimeo,
            .postToWeibo,
            .postToFlickr,
            .postToTencentWeibo,
            .openInIBooks,
            .markupAsPDF
        ]
        
        return ShareSheet(items: [image], excludedActivityTypes: excludedTypes)
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
