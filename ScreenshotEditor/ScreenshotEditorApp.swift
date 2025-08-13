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
        
        // Initialize analytics
        // This will set up Mixpanel with the appropriate environment
        AnalyticsManager.shared.setup()
    }
    
    var body: some Scene {
        WindowGroup {
            AppRootView()
        }
    }
}
