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
        static let importPictureHere = "Import a picture here"
        static let back = "Back"
        static let share = "Share"
        static let saveToPhotos = "Save to Photos"
        static let saveToDevice = "Save to Device"
        static let save = "Save"
        static let facebook = "Facebook"
        static let instagram = "Instagram"
        static let moreOptions = "More"
        static let shareOptions = "Share Options"
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
        static let cornerRadius = "Rounding"
        static let padding = "Spacing"
        static let shadow = "Shadow"
        static let solid = "Solid"
        static let gradient = "Gradient"
        static let aspectRatio = "Export Size"
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
        
        // New Paywall
        static let unlimitedAccess = "Unlimited Access"
        static let unlimitedExportsFeature = "Unlimited Exports"
        static let noWatermarkFeature = "No Watermark"
        static let noAnnoyingAdsFeature = "No annoying paywall ads"
        static let premiumEditingFeature = "Premium editing tools"
        static let highQualityExportsFeature = "High-quality exports"
        static let yearlyPlan = "Yearly Plan"
        static let weeklyPlan = "Weekly Plan"
        static let threeDayTrial = "3-Day Trial"
        static let threeDayFreeTrial = "3-Day Free Trial"
        static let freeTrial = "Free Trial"
        static let thenWeekly = "then £4.99 per week"
        static let save90Percent = "SAVE 90%"
        static let bestValue = "Best Value"
        static let weekly = "Weekly"
        static let freeBadge = "FREE"
        static let freeTrialEnabled = "Free Trial Enabled"
        static let tryForFree = "Try for Free"
        static let continueButton = "Continue"
        static let restore = "Restore"
        static let terms = "Terms"
        static let privacy = "Privacy"
        static let loadingPricing = "Loading pricing..."
        static let purchaseError = "Purchase Error"
        static let ok = "OK"
        static let purchaseCancelled = "Purchase cancelled by user"
        static let upgradeTapped = "Upgrade tapped"
        static let processing = "Processing..."
        
        // Premium status
        static let premiumActive = "Premium Active"
        static let freePlan = "Free Plan"
        static let unlimitedExportsNowatermark = "Unlimited exports • No watermark"
        static let freeExportsWatermarked = "3 free exports • Watermarked"
        static let entitlements = "Entitlements:"
        
        // Save notifications
        static let imageSavedToPhotos = "Image saved to Photos successfully!"
        static let imageSaveFailedPermissions = "Failed to save image. Please check your permissions."
        static let imageSaveFailed = "Failed to save image to Photos."
    }
    
    // MARK: - Analytics Events
    struct Analytics {
        static let importPhotoButtonTapped = "Import Photo Button Tapped"
        static let editorBackButtonTapped = "Editor Back Button Tapped"
        static let editorShareButtonTapped = "Editor Share Button Tapped"
        static let editorSaveToPhotosButtonTapped = "Editor Save To Photos Button Tapped"
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
        static let reviewPromptShown = "Review Prompt Shown"
        
        // Onboarding events
        static let onboardingStarted = "onboarding_started"
        static let onboardingCompleted = "onboarding_completed"
        static let onboardingWelcomeViewed = "onboarding_welcome_viewed"
        static let onboardingFeaturesViewed = "onboarding_features_viewed"
        static let onboardingPhotoAccessViewed = "onboarding_photo_access_viewed"
        static let onboardingPhotoPermissionGranted = "onboarding_photo_permission_granted"
        static let onboardingPhotoPermissionDenied = "onboarding_photo_permission_denied"
        static let onboardingPaywallViewed = "onboarding_paywall_viewed"
        static let onboardingPaywallSubscribeTapped = "onboarding_paywall_subscribe_tapped"
        static let onboardingPaywallContinueFreeTapped = "onboarding_paywall_continue_free_tapped"
        
        // Share sheet tracking
        static let shareSheetOpened = "Share Sheet Opened"
        
        // Purchase events
        static let purchaseSuccessful = "purchase_successful"
        static let purchaseFailed = "purchase_failed"
        static let purchaseCancelled = "purchase_cancelled"
        static let restoreSuccessful = "restore_successful"
        static let restoreFailed = "restore_failed"
        
        // EPIC 12 - Subscription Funnel & Paywall Events
        static let paywallOptionSelected = "paywall_option_selected"
        static let paywallCtaTapped = "paywall_cta_tapped"
        static let checkoutStarted = "checkout_started"
        static let purchaseAttempted = "purchase_attempted"
        static let paywallOutcome = "paywall_outcome"
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
        
        // Export parameters
        static let cornerRadius = "corner_radius"
        static let padding = "padding"
        static let shadowOpacity = "shadow_opacity"
        static let shadowBlur = "shadow_blur"
        static let backgroundType = "background_type"
        static let aspectRatio = "aspect_ratio"
        
        // Background type values
        static let solid = "solid"
        static let gradient = "gradient"
        
        // Additional analytics properties
        static let price = "price"
        
        // EPIC 12 - Subscription Funnel & Paywall Properties
        static let paywallSessionId = "paywall_session_id"
        static let placement = "placement"
        static let entryPoint = "entry_point"
        static let ctaLabel = "cta_label"
        static let productId = "product_id"
        static let billingPeriod = "billing_period"
        static let currency = "currency"
        static let introOfferApplied = "intro_offer_applied"
        static let trialDays = "trial_days"
        static let isTrialStart = "is_trial_start"
        static let outcome = "outcome"
        static let selectedProductId = "selected_product_id"
        
        // Placement enum values
        static let onboardingGate = "onboarding_gate"
        static let featureLock = "feature_lock"
        static let upsellModal = "upsell_modal"
        static let tabPremium = "tab_premium"
        static let exitIntent = "exit_intent"
        static let paywalledContent = "paywalled_content"
        
        // CTA Label enum values
        static let startTrial = "start_trial"
        static let continueLabel = "continue"
        static let subscribe = "subscribe"
        static let buyNow = "buy_now"
        
        // Outcome enum values
        static let purchased = "purchased"
        static let dismissed = "dismissed"
        static let backgrounded = "backgrounded"
        static let terminated = "terminated"
        static let navigatedElsewhere = "navigated_elsewhere"
        static let analyticsError = "error"
    }
    
    // MARK: - System Images
    struct SystemImages {
        static let xmark = "xmark"
        static let crown = "crown"
        static let crownFill = "crown.fill"
        static let checkmarkCircleFill = "checkmark.circle.fill"
        static let circle = "circle"
    }
    
    // MARK: - Asset Images
    struct AssetImages {
        static let appIconImage = "AppIconImage"
    }
    
    // MARK: - Accessibility Labels
    struct Accessibility {
        static let backgroundTypePicker = "Background Type"
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
