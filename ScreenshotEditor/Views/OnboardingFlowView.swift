//
//  OnboardingFlowView.swift
//  ScreenshotEditor
//
//  Created by Alastair McNeill on 13/08/2025.
//

import SwiftUI
import Photos

// MARK: - Onboarding Step Enum
private enum OnboardingStep: Int, CaseIterable {
    case welcome = 0
    case features
    case photoAccess
}

struct OnboardingFlowView: View {
    /// A closure to call when the onboarding process is completed.
    var onComplete: () -> Void
    
    @State private var currentStep: OnboardingStep = .welcome
    @State private var isFinishing: Bool = false
    @State private var photoAccessStatus: PHAuthorizationStatus = .notDetermined
    
    private var progress: Double {
        if isFinishing { return 1.0 }
        switch currentStep {
        case .welcome: return 0.0
        case .features: return 0.5
        case .photoAccess: return 1.0
        }
    }
    
    private var shouldShowProgressBar: Bool {
        currentStep == .features || currentStep == .photoAccess
    }
    
    var body: some View {
        VStack(spacing: 0) {
            if shouldShowProgressBar {
                LinearProgressBar(progress: progress)
                    .frame(height: 6)
                    .padding(.top, 8)
                    .padding(.horizontal)
                    .accessibilityLabel("Onboarding progress")
            }
            
            // The view content
            ZStack {
                switch currentStep {
                case .welcome:
                    WelcomeStep(action: { advance() })
                        .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
                case .features:
                    FeaturesStep(action: { advance() })
                        .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
                case .photoAccess:
                    PhotoAccessStep(action: { 
                        // Complete onboarding after photo access step
                        finishOnboarding()
                    })
                        .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
                }
            }
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .onAppear {
            print("Onboarding: OnboardingFlowView appeared.")
            AnalyticsManager.shared.track(AppStrings.Analytics.onboardingStarted)
        }
    }
    
    private func advance() {
        withAnimation(.easeInOut(duration: 0.3)) {
            if let nextStep = OnboardingStep(rawValue: currentStep.rawValue + 1) {
                currentStep = nextStep
            } else {
                onComplete()
            }
        }
    }
    
    private func finishOnboarding() {
        withAnimation {
            isFinishing = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            // Mark onboarding as completed
            UserDefaultsManager.shared.completeOnboarding()
            AnalyticsManager.shared.track(AppStrings.Analytics.onboardingCompleted)
            onComplete()
        }
    }
}

// MARK: - Linear Progress Bar
private struct LinearProgressBar: View {
    var progress: Double // 0.0 to 1.0
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.gray.opacity(0.2))
                Capsule()
                    .fill(Color.accentColor)
                    .frame(width: geometry.size.width * CGFloat(progress))
                    .animation(.easeInOut(duration: 0.3), value: progress)
            }
        }
    }
}

// MARK: - Feature Highlight View
private struct FeatureHighlight: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 28))
                .foregroundColor(.accentColor)
                .frame(width: 40, height: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Text(description)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
            }
            
            Spacer()
        }
        .padding(.horizontal, 24)
    }
}

// MARK: - Welcome Step
private struct WelcomeStep: View {
    var action: () -> Void
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        ZStack(alignment: .top) {
            // Gradient background
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(.systemGroupedBackground),
                    Color(.systemBackground)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                Spacer(minLength: 60)
                
                // App Icon
                Image(systemName: "camera.viewfinder")
                    .font(.system(size: 100))
                    .foregroundColor(.accentColor)
                    .padding(.bottom, 40)
                    .accessibilityLabel("ScreenshotEditor App Icon")
                
                // Headline
                Text("Welcome to\nScreenshotEditor!")
                    .font(.system(size: 32, weight: .bold))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .padding(.bottom, 16)
                
                // Subheadline
                Text("Transform your screenshots into beautiful, professional-looking images with custom backgrounds and styles.")
                    .font(.system(size: 18, weight: .regular))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                    .padding(.bottom, 64)
                
                Spacer()
                
                // Continue Button
                Button(action: action) {
                    Text("Get Started")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 8)
                
                // User count below button
                HStack(spacing: 6) {
                    Text("Join thousands of users creating beautiful screenshots")
                        .font(.footnote)
                        .foregroundColor(.secondary)

                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.green)
                }
                .padding(.bottom, 40)
            }
        }
        .onAppear { 
            print("Onboarding: Step 0 (Welcome) appeared.")
            AnalyticsManager.shared.track(AppStrings.Analytics.onboardingWelcomeViewed)
        }
    }
}

// MARK: - Features Step
private struct FeaturesStep: View {
    var action: () -> Void
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        ZStack {
            // Gradient background
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(.systemGroupedBackground),
                    Color(.systemBackground)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                Spacer(minLength: 60)
                
                // Features icon
                Image(systemName: "sparkles")
                    .font(.system(size: 80))
                    .foregroundColor(.accentColor)
                    .padding(.bottom, 32)
                
                // Headline
                Text("Powerful Features")
                    .font(.system(size: 32, weight: .bold))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .padding(.bottom, 16)
                
                // Subheadline
                Text("Everything you need to make your screenshots stand out")
                    .font(.system(size: 18, weight: .regular))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                    .padding(.bottom, 48)
                
                // Feature highlights
                VStack(spacing: 24) {
                    FeatureHighlight(
                        icon: "crop",
                        title: "Smart Cropping",
                        description: "Automatically detect and crop your screenshot content"
                    )
                    
                    FeatureHighlight(
                        icon: "paintbrush.fill",
                        title: "Custom Backgrounds",
                        description: "Choose from gradients, colors, and beautiful effects"
                    )
                    
                    FeatureHighlight(
                        icon: "rectangle.3.group.fill",
                        title: "Style Presets",
                        description: "Apply professional styles with a single tap"
                    )
                    
                    FeatureHighlight(
                        icon: "square.and.arrow.up",
                        title: "Easy Sharing",
                        description: "Export in high quality and share anywhere"
                    )
                }
                .padding(.bottom, 48)
                
                Spacer()
                
                // Continue Button
                Button(action: action) {
                    Text("Continue")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
        .onAppear { 
            print("Onboarding: Step 1 (Features) appeared.")
            AnalyticsManager.shared.track(AppStrings.Analytics.onboardingFeaturesViewed)
        }
    }
}

// MARK: - Photo Access Step
private struct PhotoAccessStep: View {
    var action: () -> Void
    @State private var showSettingsAlert = false
    @State private var authorizationStatus: PHAuthorizationStatus = PHPhotoLibrary.authorizationStatus(for: .readWrite)
    
    var body: some View {
        ZStack {
            // Gradient background
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(.systemGroupedBackground),
                    Color(.systemBackground)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                Spacer(minLength: 60)
                
                // Photo access icon
                Image(systemName: "photo.on.rectangle.angled")
                    .font(.system(size: 80))
                    .foregroundColor(.accentColor)
                    .padding(.bottom, 32)
                
                // Headline
                Text("Access Your Photos")
                    .font(.system(size: 32, weight: .bold))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .padding(.bottom, 16)
                
                // Subheadline
                Text("We need access to your photo library to import screenshots and save your edited images.")
                    .font(.system(size: 18, weight: .regular))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                    .padding(.bottom, 48)
                
                Spacer()
                
                // Grant Permission Button
                Button(action: handlePermissionTap) {
                    Text(buttonText)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 60)
            }
        }
        .onAppear { 
            print("Onboarding: Step 2 (Photo Access) appeared.")
            AnalyticsManager.shared.track(AppStrings.Analytics.onboardingPhotoAccessViewed)
            authorizationStatus = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        }
        .onChange(of: authorizationStatus) { oldValue, newValue in
            if newValue == .authorized || newValue == .limited {
                AnalyticsManager.shared.track(AppStrings.Analytics.onboardingPhotoPermissionGranted)
                action()
            }
        }
        .alert("Photo Access Denied", isPresented: $showSettingsAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
        } message: {
            Text("To use ScreenshotEditor, please go to Settings and grant photo library access.")
        }
    }
    
    private var buttonText: String {
        switch authorizationStatus {
        case .authorized, .limited:
            return "Continue"
        case .denied, .restricted:
            return "Open Settings"
        case .notDetermined:
            return "Grant Photo Access"
        @unknown default:
            return "Grant Photo Access"
        }
    }
    
    private func handlePermissionTap() {
        switch authorizationStatus {
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
                DispatchQueue.main.async {
                    authorizationStatus = status
                }
            }
        case .authorized, .limited:
            AnalyticsManager.shared.track(AppStrings.Analytics.onboardingPhotoPermissionGranted)
            action()
        case .denied, .restricted:
            AnalyticsManager.shared.track(AppStrings.Analytics.onboardingPhotoPermissionDenied)
            showSettingsAlert = true
        @unknown default:
            break
        }
    }
}

#Preview {
    OnboardingFlowView(onComplete: {})
}
