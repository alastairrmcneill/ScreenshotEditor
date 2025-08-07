//
//  ContentView.swift
//  ScreenshotEditor
//
//  Created by Alastair McNeill on 07/08/2025.
//

import SwiftUI

struct ContentView: View {
    @State private var currentUUID: String = ""
    @State private var isFirstLaunch: Bool = false
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "camera.viewfinder")
                .imageScale(.large)
                .foregroundStyle(.tint)
            
            Text("ScreenshotEditor")
                .font(.title)
                .fontWeight(.bold)
            
            VStack(spacing: 10) {
                Text("Anonymous UUID:")
                    .font(.headline)
                
                Text(currentUUID)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                if isFirstLaunch {
                    Text("✅ New UUID generated and stored")
                        .foregroundColor(.green)
                        .font(.caption)
                } else {
                    Text("✅ UUID retrieved from Keychain")
                        .foregroundColor(.blue)
                        .font(.caption)
                }
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)
            
            Button("Regenerate UUID") {
                currentUUID = UUIDManager.shared.regenerateUUID()
                isFirstLaunch = true
                
                // Track the UUID regeneration event
                AnalyticsManager.shared.track("UUID Regenerated")
            }
            .buttonStyle(.bordered)
            
            Button("Test Analytics Event") {
                AnalyticsManager.shared.track("Test Button Pressed", properties: [
                    "button_name": "test_analytics",
                    "current_uuid": currentUUID
                ])
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .onAppear {
            currentUUID = UUIDManager.shared.anonymousUUID
            isFirstLaunch = !UUIDManager.shared.hasExistingUUID
        }
    }
}

#Preview {
    ContentView()
}
