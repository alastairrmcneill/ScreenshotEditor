//
//  ScreenshotEditorApp.swift
//  ScreenshotEditor
//
//  Created by Alastair McNeill on 07/08/2025.
//

import SwiftUI
import Photos

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
            ContentView()
                .onAppear {
                    // Request photos permission on app launch
                    PHPhotoLibrary.requestAuthorization(for: .addOnly) { status in
                        DispatchQueue.main.async {
                            switch status {
                            case .authorized:
                                print("Photos access granted")
                            case .limited:
                                print("Limited photos access granted")
                            case .denied, .restricted:
                                print("Photos access denied")
                            case .notDetermined:
                                print("Photos access not determined")
                            @unknown default:
                                print("Unknown photos access status")
                            }
                        }
                    }
                }
        }
    }
}
