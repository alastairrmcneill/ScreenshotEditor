//
//  ReviewManager.swift
//  ScreenshotEditor
//
//  Created by Alastair McNeill on 12/08/2025.
//

import Foundation
import StoreKit

/// Manager for handling in-app review prompts
class ReviewManager {
    static let shared = ReviewManager()
    
    private init() {}
    
    /// Checks if we should show the review prompt after export
    func shouldShowExportReview() -> Bool {
        return !UserDefaultsManager.shared.hasShownReviewPrompt
    }
    
    /// Requests a review after the user's first successful export
    func requestExportReview() {
        print("Requesting Export Review")
        print("shouldShowExportReview: \(shouldShowExportReview())")
        guard shouldShowExportReview() else { return }
        
        // Only show review prompt after first export
        // For free users, this means export count >= 1
        // For subscribed users, we still want to show it after their first export
        let hasHadFirstExport = UserDefaultsManager.shared.freeExportCount >= 1 || UserDefaultsManager.shared.isSubscribed
        
        guard hasHadFirstExport else {
            print("User hasn't had first export yet")
            return
        }
        
        // Add a small delay to let the export UI settle
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                SKStoreReviewController.requestReview(in: scene)
                UserDefaultsManager.shared.markReviewPromptShown()
                
                // Track the review prompt in analytics
                AnalyticsManager.shared.track(AppStrings.Analytics.reviewPromptShown)
            }
        }
    }
}
