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
    let onCompletion: ((UIActivity.ActivityType?, Bool) -> Void)?
    
    init(
        items: [Any], 
        excludedActivityTypes: [UIActivity.ActivityType]? = nil,
        onCompletion: ((UIActivity.ActivityType?, Bool) -> Void)? = nil
    ) {
        self.items = items
        self.excludedActivityTypes = excludedActivityTypes
        self.onCompletion = onCompletion
    }
    
    /// Creates a ShareSheet optimized for saving images to Photos
    static func forImageSaving(
        image: UIImage, 
        onCompletion: ((UIActivity.ActivityType?, Bool) -> Void)? = nil
    ) -> ShareSheet {
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
        
        return ShareSheet(
            items: [image], 
            excludedActivityTypes: excludedTypes,
            onCompletion: onCompletion
        )
    }
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let activityViewController = UIActivityViewController(
            activityItems: items,
            applicationActivities: nil
        )
        activityViewController.excludedActivityTypes = excludedActivityTypes
        
        // Set completion handler
        activityViewController.completionWithItemsHandler = { activityType, completed, returnedItems, error in
            onCompletion?(activityType, completed)
        }
        
        return activityViewController
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        // No updates needed
    }
}
