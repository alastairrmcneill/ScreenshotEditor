//
//  AppRootView.swift
//  ScreenshotEditor
//
//  Created by Alastair McNeill on 13/08/2025.
//

import SwiftUI

/// Root view that decides whether to show onboarding or main content
struct AppRootView: View {
    @State private var hasCompletedOnboarding = UserDefaultsManager.shared.hasCompletedOnboarding
    
    var body: some View {
        Group {
//            if hasCompletedOnboarding {
//                ContentView()
//            } else {
                OnboardingFlowView {
                    // Called when onboarding is completed
                    withAnimation(.easeInOut(duration: 0.5)) {
                        hasCompletedOnboarding = true
                    }
//                }
            }
        }
    }
}

#Preview {
    AppRootView()
}
