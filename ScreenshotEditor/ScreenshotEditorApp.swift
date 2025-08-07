//
//  ScreenshotEditorApp.swift
//  ScreenshotEditor
//
//  Created by Alastair McNeill on 07/08/2025.
//

import SwiftUI

@main
struct ScreenshotEditorApp: App {
    
    init() {
        // Initialize anonymous UUID on app launch
        // This ensures the UUID is generated and stored on first launch
        let uuid = UUIDManager.shared.anonymousUUID
        print("App launched with anonymous UUID: \(uuid)")
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
