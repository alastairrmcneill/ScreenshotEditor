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
        static let cornerRadius = "Corner Radius"
        static let padding = "Padding"
        static let shadow = "Shadow"
        static let solid = "Solid"
        static let gradient = "Gradient"
        static let aspectRatio = "Aspect Ratio"
        static let square = "1:1"
        static let portrait = "9:16"
        static let landscape = "16:9"
        
        // Paywall
        static let exportLimitReached = "Export Limit Reached"
        static let upgradeToPremium = "Upgrade to Premium"
        static let exportLimitMessage = "You've reached your limit of 3 free exports. Upgrade to Premium for unlimited exports and remove the watermark."
        static let continueFree = "Continue with Free"
        static let getUnlimitedExports = "Get Unlimited Exports"
        static let premiumFeatures = "Premium Features:"
        static let unlimitedExports = "• Unlimited exports"
        static let noWatermark = "• No watermark"
        static let restorePurchases = "Restore Purchases"
    }
    
    // MARK: - Analytics Events
    struct Analytics {
        static let importPhotoButtonTapped = "Import Photo Button Tapped"
        static let editorBackButtonTapped = "Editor Back Button Tapped"
        static let editorShareButtonTapped = "Editor Share Button Tapped"
        static let cropButtonTapped = "Crop Button Tapped"
        static let styleButtonTapped = "Style Button Tapped"
        static let backgroundButtonTapped = "Background Button Tapped"
        static let aspectRatioChanged = "Aspect Ratio Changed"
        static let editorOpened = "Editor Opened"
        static let photoImportCancelled = "Photo Import Cancelled"
        static let photoImportFailed = "Photo Import Failed"
        static let photoImportSuccess = "Photo Import Success"
        static let exportStarted = "Export Started"
        static let exportCompleted = "Export Completed"
        static let exportLimitReached = "Export Limit Reached"
        static let paywallShown = "Paywall Shown"
        static let paywallDismissed = "Paywall Dismissed"
        static let paywallUpgradeClicked = "Paywall Upgrade Clicked"
    }
    
    // MARK: - Analytics Properties
    struct AnalyticsProperties {
        static let imageWidth = "image_width"
        static let imageHeight = "image_height"
        static let hasAlpha = "has_alpha"
        static let error = "error"
        static let exportCount = "export_count"
        static let isSubscribed = "is_subscribed"
        static let exportLimitReason = "export_limit_reason"
    }
    
    // MARK: - Debug Messages
    struct Debug {
        static let analyticsSetup = "📱 ~ AnalyticsManager ~ funcsetup ~ apiKey:"
        static let superPropertiesSet = "📱 ~ AnalyticsManager ~ Super properties set:"
        static let analyticsEvent = "📱 ~"
        static let appLaunchedWithUUID = "App launched with anonymous UUID:"
        static let errorLoadingImage = "Error loading image:"
    }
}
