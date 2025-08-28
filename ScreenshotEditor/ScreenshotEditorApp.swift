//
//  ScreenshotEditorApp.swift
//  ScreenshotEditor
//
//  Created by Alastair McNeill on 07/08/2025.
//

import SwiftUI

@main
struct ScreenshotEditorApp: App {
    @Environment(\.scenePhase) private var scenePhase
    
    init() {
        // Initialize anonymous UUID on app launch
        // This ensures the UUID is generated and stored on first launch
        let uuid = UUIDManager.shared.anonymousUUID
        print("\(AppStrings.Debug.appLaunchedWithUUID) \(uuid)")
        
        // Initialize analytics first
        // This will set up Mixpanel with the appropriate environment and user identity
        AnalyticsManager.shared.setup()
        
        // Initialize subscription manager (which will configure RevenueCat and sync user IDs)
        let subscriptionManager = SubscriptionManager.shared
        
        // Check user ID sync and then fetch offerings and check entitlements after a brief delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            subscriptionManager.checkUserIdSync()
            subscriptionManager.fetchOfferings()
        }
    }
    
    var body: some Scene {
        WindowGroup {
            AppRootView()
        }
    }
}
