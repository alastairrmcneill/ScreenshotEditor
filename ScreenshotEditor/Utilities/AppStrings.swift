//
//  AppStrings.swift
//  ScreenshotEditor
//
//  Created by Alastair McNeill on 08/08/2025.
//

import Foundation

/// Centralized string constants for the app to avoid duplication and improve maintainability
struct AppStrings {
    
    // MARK: - UI Labels
    struct UI {
        static let importPhoto = "Import Photo"
        static let back = "Back"
        static let share = "Share"
        static let crop = "Crop"
        static let style = "Style"
        static let background = "Background"
        static let editPhoto = "Edit Photo"
        static let premium = "Premium"
        static let free = "Free"
        static let noImageSelected = "No Image Selected"
        static let importPhotoToGetStarted = "Import a photo to get started"
        static let madeWithSnapPolish = "Made with SnapPolish"
        static let cancel = "Cancel"
        static let done = "Done"
        static let reset = "Reset"
    }
    
    // MARK: - Analytics Events
    struct Analytics {
        static let importPhotoButtonTapped = "Import Photo Button Tapped"
        static let editorBackButtonTapped = "Editor Back Button Tapped"
        static let editorShareButtonTapped = "Editor Share Button Tapped"
        static let cropButtonTapped = "Crop Button Tapped"
        static let styleButtonTapped = "Style Button Tapped"
        static let backgroundButtonTapped = "Background Button Tapped"
        static let editorOpened = "Editor Opened"
        static let photoImportCancelled = "Photo Import Cancelled"
        static let photoImportFailed = "Photo Import Failed"
        static let photoImportSuccess = "Photo Import Success"
    }
    
    // MARK: - Analytics Properties
    struct AnalyticsProperties {
        static let imageWidth = "image_width"
        static let imageHeight = "image_height"
        static let hasAlpha = "has_alpha"
        static let error = "error"
    }
}
