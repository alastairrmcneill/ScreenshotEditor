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
                    .fill(Color.customAccent)
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
                .foregroundColor(.customAccent)
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
                
                // App Image
                Image("Onboarding_image_1")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 200, height: 250)
                    .padding(.bottom, 40)
                
                // Headline
                Text("Welcome to\nVanta!")
                    .font(.system(size: 32, weight: .bold))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .padding(.bottom, 16)
                
                // Subheadline
                Text("Make beautiful, professional-looking screenshots in seconds!")
                    .font(.system(size: 18, weight: .regular))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                
                Spacer()
                
                // Testimonial Carousel
                TestimonialCarouselView(testimonials: [
                    Testimonial(
                        userImage: Image(systemName: "person.crop.circle"),
                        name: "Jake B.",
                        quote: "These screenshots look so much better!",
                        starCount: 5
                    ),
                    Testimonial(
                        userImage: Image(systemName: "person.crop.circle"),
                        name: "Danielle A.",
                        quote: "Much happier posting these to LinkedIn!",
                        starCount: 5
                    ),
                    Testimonial(
                        userImage: Image(systemName: "person.crop.circle"),
                        name: "Ritchie N.",
                        quote: "Fast and easy. What more could you ask for?",
                        starCount: 5
                    ) 
                ])

                Spacer()

                // Continue Button
                Button(action: action) {
                    Text("Get Started")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.brandGradient)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 10)
                
                // User count below button
                HStack(spacing: 6) {
                    Text("Join thousands of users creating beautiful screenshots")
                        .font(.footnote)
                        .foregroundColor(.secondary)

                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.green)
                }
                .padding(.bottom, 16)
            }
        }
        .onAppear { 
            print("Onboarding: Step 0 (Welcome) appeared.")
            AnalyticsManager.shared.track(AppStrings.Analytics.onboardingWelcomeViewed)
        }
    }
}

// MARK: - Testimonial View
private struct TestimonialView: View {
    let userImage: Image
    let name: String
    let quote: String
    let starCount: Int
    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            Image(systemName: "laurel.leading")
                .resizable()
                .scaledToFit()
                .frame(width: 40, height: 70)
                .foregroundStyle(Color.brandGradient)
            VStack(spacing: 6) {
                Text(name)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Text(quote)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 0)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                HStack(spacing: 2) {
                    ForEach(0..<starCount, id: \ .self) { _ in
                        Image(systemName: "star.fill")
                            .font(.caption)
                            .foregroundColor(.yellow)
                    }
                }
            }
            Image(systemName: "laurel.trailing")
                .resizable()
                .scaledToFit()
                .frame(width: 40, height: 70)
                .foregroundStyle(Color.brandGradient)
        }
        .padding(.horizontal, 40)
    }
}

// MARK: - Testimonial Carousel View
private struct Testimonial: Identifiable {
    let id = UUID()
    let userImage: Image
    let name: String
    let quote: String
    let starCount: Int
}

private struct TestimonialCarouselView: View {
    let testimonials: [Testimonial]
    @State private var currentIndex = 0
    let timer = Timer.publish(every: 3, on: .main, in: .common).autoconnect()
    
    var body: some View {
        TabView(selection: $currentIndex) {
            ForEach(Array(testimonials.enumerated()), id: \ .element.id) { index, testimonial in
                TestimonialView(
                    userImage: testimonial.userImage,
                    name: testimonial.name,
                    quote: testimonial.quote,
                    starCount: testimonial.starCount
                )
                .tag(index)
            }
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        .frame(height: 120)
        .onReceive(timer) { _ in
            withAnimation {
                currentIndex = (currentIndex + 1) % testimonials.count
            }
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
                    .foregroundStyle(Color.brandGradient)
                    .padding(.bottom, 32)
                
                // Headline
                Text("Beauty is in your hands!")
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
                        title: "Cropping",
                        description: "Keep only the good bits"
                    )
                    
                    FeatureHighlight(
                        icon: "paintbrush.fill",
                        title: "Custom Backgrounds",
                        description: "Beautiful colours and gradients"
                    )
                    
                    FeatureHighlight(
                        icon: "rectangle.3.group.fill",
                        title: "Style Presets",
                        description: "Apply professional styling"
                    )
                    
                    FeatureHighlight(
                        icon: "square.and.arrow.up",
                        title: "Easy Sharing",
                        description: "Export and share anywhere"
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
                        .background(Color.brandGradient)
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
                    .foregroundStyle(Color.brandGradient)
                    .padding(.bottom, 32)
                
                // Headline
                Text("Access Your Photos")
                    .font(.system(size: 32, weight: .bold))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .padding(.bottom, 16)
                
                // Subheadline
                Text("To make beautiful screenshots, we need access to your photos.")
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
                        .background(Color.brandGradient)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
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
