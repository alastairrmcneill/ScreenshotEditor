//
//  ContentView.swift
//  ScreenshotEditor
//
//  Created by Alastair McNeill on 07/08/2025.
//

import SwiftUI
import PhotosUI

struct ContentView: View {
    @StateObject private var editingViewModel = ImageEditingViewModel()
    @StateObject private var subscriptionManager = SubscriptionManager.shared
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var backButtonPhotoItem: PhotosPickerItem?
    @State private var showingBackPhotosPicker = false
    @State private var showingShareSheet = false
    @State private var showingCropView = false
    @State private var showingStylePanel = false
    @State private var showingBackgroundPanel = false
    @State private var showingAspectRatioPanel = false
    @State private var imageToShare: UIImage?
    @State private var isGeneratingShareImage = false
    @State private var showingPaywall = false
    @State private var showingPostOnboardingPaywall = false
    @State private var hasReturnedFromBack = false
    
    var body: some View {
        ZStack {
            // Main Content
            ZStack {
                // Background
                Color(.systemBackground)
                    .ignoresSafeArea()
                
                if editingViewModel.originalImage == nil {
                    EmptyStateView(
                        selectedPhotoItem: $selectedPhotoItem,
                        hasReturnedFromBack: $hasReturnedFromBack
                    )
                } else {
                    // Editor Canvas
                    VStack(spacing: AppConstants.Layout.zeroSpacing) {
                        // Navigation Bar Area
                        ZStack {
                            // Centered title
                            Text("Vanta")
                                .font(.title2)
                                .fontWeight(.medium)
                            
                            // Left and right buttons
                            HStack {
                                Button(action: {
                                    editingViewModel.resetParameters()
                                    editingViewModel.setOriginalImage(nil)
                                    hasReturnedFromBack = true
                                    showingBackPhotosPicker = true
                                    AnalyticsManager.shared.track(AppStrings.Analytics.editorBackButtonTapped)
                                }) {
                                    Image(systemName: "arrow.left")
                                        .font(.title2)
                                        .fontWeight(.medium)
                                }
                                .foregroundColor(.customAccent)
                                
                                Spacer()
                                
                                HStack(spacing: 16) {
                                    // Share button
                                    Button(action: {
                                        Task {
                                            await shareImage()
                                        }
                                    }) {
                                        Image(systemName: "square.and.arrow.up")
                                            .font(.title2)
                                            .fontWeight(.medium)
                                    }
                                    .foregroundColor(.customAccent)
                                    
                                    // Crown button (paywall) with gradient overlay
                                    if !subscriptionManager.hasPremiumAccess {
                                        Button(action: {
                                            showingPaywall = true
                                        }) {
                                            Image(systemName: "crown.fill")
                                                .font(.title2)
                                                .fontWeight(.medium)
                                                .foregroundStyle(
                                                    LinearGradient(
                                                        colors: BackgroundGradient.golden.colors.map { Color(cgColor: $0) },
                                                        startPoint: .topLeading,
                                                        endPoint: .bottomTrailing
                                                    )
                                                )
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, AppConstants.Layout.largePadding)
                        .padding(.vertical, AppConstants.Layout.standardPadding)
                        .background(Color(.systemBackground))
                        
                        // Main Canvas Area - dynamically sized based on panel state
                        ZStack {
                            Color(.systemGray6)
                            
                            // Image Canvas with live rendering
                            if let renderedImage = editingViewModel.renderedImage {
                                ImageRenderer.createImageView(
                                    image: renderedImage,
                                    showWatermark: !subscriptionManager.hasPremiumAccess
                                )
                                .aspectRatio(contentMode: .fit)
                                .padding(AppConstants.Layout.standardPadding)
                            } else if let originalImage = editingViewModel.originalImage {
                                // Fallback while rendering
                                ImageRenderer.createImageView(
                                    image: originalImage,
                                    showWatermark: !subscriptionManager.hasPremiumAccess
                                )
                                .aspectRatio(contentMode: .fit)
                                .padding(AppConstants.Layout.standardPadding)
                                .opacity(AppConstants.Layout.fallbackImageOpacity)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            // Dismiss any open panels when tapping on canvas
                            if showingStylePanel || showingBackgroundPanel || showingAspectRatioPanel {
                                withAnimation(.easeInOut(duration: AppConstants.StylePanel.animationDuration)) {
                                    showingStylePanel = false
                                    showingBackgroundPanel = false
                                    showingAspectRatioPanel = false
                                }
                            }
                        }
                        
                        // Bottom Controls Area and Panels
                        VStack(spacing: 0) {
                            // Show main controls only when no panel is active
                            if !showingStylePanel && !showingBackgroundPanel && !showingAspectRatioPanel {
                                VStack {
                                    HStack(spacing: 20) {
                                        EditorControlButton(systemImage: "crop", text: "Crop") {
                                            showingCropView = true
                                            AnalyticsManager.shared.track(AppStrings.Analytics.cropButtonTapped)
                                        }
                                        
                                        EditorControlButton(systemImage: "square.on.square", text: "Style") {
                                            withAnimation(.easeInOut(duration: AppConstants.StylePanel.animationDuration)) {
                                                showingStylePanel = true
                                            }
                                            AnalyticsManager.shared.track(AppStrings.Analytics.styleButtonTapped)
                                        }
                                        
                                        EditorControlButton(systemImage: "paintpalette", text: "Colours") {
                                            withAnimation(.easeInOut(duration: AppConstants.StylePanel.animationDuration)) {
                                                showingBackgroundPanel = true
                                            }
                                            AnalyticsManager.shared.track(AppStrings.Analytics.backgroundButtonTapped)
                                        }

                                        EditorControlButton(systemImage: "aspectratio", text: "Ratio") {
                                            withAnimation(.easeInOut(duration: AppConstants.StylePanel.animationDuration)) {
                                                showingAspectRatioPanel = true
                                            }
                                            AnalyticsManager.shared.track(AppStrings.Analytics.aspectRatioChanged, properties: [
                                                "source": "button"
                                            ])
                                        }
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.horizontal, AppConstants.Layout.controlsHorizontalPadding)
                                    .padding(.vertical, AppConstants.Layout.standardPadding)
                                }
                                .background(Color(.systemGray6))
                                .transition(.move(edge: .bottom).combined(with: .opacity))
                            }
                            
                            // Style Panel (inline)
                            if showingStylePanel {
                                StylePanelInline(
                                    editingViewModel: editingViewModel,
                                    isPresented: $showingStylePanel
                                )
                                .transition(.move(edge: .bottom).combined(with: .opacity))
                            }
                            
                            // Background Panel (inline)
                            if showingBackgroundPanel {
                                BackgroundPanelInline(
                                    editingViewModel: editingViewModel,
                                    isPresented: $showingBackgroundPanel
                                )
                                .transition(.move(edge: .bottom).combined(with: .opacity))
                            }
                            
                            // Aspect Ratio Panel (inline)
                            if showingAspectRatioPanel {
                                AspectRatioPanelInline(
                                    editingViewModel: editingViewModel,
                                    isPresented: $showingAspectRatioPanel
                                )
                                .transition(.move(edge: .bottom).combined(with: .opacity))
                            }
                        }
                    }
                    .onAppear {
                        if let originalImage = editingViewModel.originalImage {
                            AnalyticsManager.shared.track(AppStrings.Analytics.editorOpened, properties: [
                                AppStrings.AnalyticsProperties.imageWidth: Double(originalImage.size.width),
                                AppStrings.AnalyticsProperties.imageHeight: Double(originalImage.size.height)
                            ])
                        }
                    }
                }
            }
        }
        .photosPicker(isPresented: $showingBackPhotosPicker, selection: $backButtonPhotoItem, matching: .screenshots, photoLibrary: .shared())
        .onChange(of: selectedPhotoItem) { _, newItem in
            Task {
                await loadSelectedImage(from: newItem)
            }
        }
        .onChange(of: backButtonPhotoItem) { _, newItem in
            Task {
                await loadSelectedImage(from: newItem)
                // Reset the back button photo item after processing
                backButtonPhotoItem = nil
                // If user selected an image, clear the hasReturnedFromBack flag
                if newItem != nil {
                    hasReturnedFromBack = false
                }
            }
        }
        .sheet(isPresented: $showingPaywall) {
            PaywallView(
                isPresented: $showingPaywall,
                placement: AppStrings.AnalyticsProperties.featureLock,
                entryPoint: "export_limit_reached"
            ) {
                // For now, just toggle subscription status for testing
                // In a real app, this would trigger StoreKit purchase flow
                UserDefaultsManager.shared.setSubscribed(true)
                showingPaywall = false
            }
        }
        .sheet(isPresented: $showingShareSheet) {
            if let imageToShare = imageToShare {
                ShareSheet.forImageSaving(image: imageToShare) { activityType, completed in
                    if completed {
                        // Show success snackbar for save to photos
                        if activityType == .saveToCameraRoll {
                            SnackbarManager.shared.showSuccess(AppStrings.UI.imageSavedToPhotos)
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showingPostOnboardingPaywall) {
            PaywallView(
                isPresented: $showingPostOnboardingPaywall,
                placement: AppStrings.AnalyticsProperties.onboardingGate,
                entryPoint: "post_onboarding"
            ) {
                // Handle subscription success
                UserDefaultsManager.shared.setSubscribed(true)
                showingPostOnboardingPaywall = false
            }
        }
        .onAppear {
            // Show post-onboarding paywall on first launch after onboarding completion
            if UserDefaultsManager.shared.hasCompletedOnboarding && 
               !UserDefaultsManager.shared.hasShownPostOnboardingPaywall &&
               !subscriptionManager.hasPremiumAccess {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    UserDefaultsManager.shared.markPostOnboardingPaywallShown()
                    showingPostOnboardingPaywall = true
                }
            }
        }
        .fullScreenCover(isPresented: $showingCropView) {
            if let originalImage = editingViewModel.originalImage {
                CropView(
                    originalImage: originalImage,
                    initialCropRect: editingViewModel.parameters.cropRect,
                    onCropComplete: { cropRect in
                        editingViewModel.updateCropRect(cropRect)
                    }
                )
            }
        }
        .withSnackbar()
    }
    
    /// Loads the selected image asynchronously using the modern PhotosPicker API
    /// - Parameter item: The selected PhotosPickerItem
    @MainActor
    private func loadSelectedImage(from item: PhotosPickerItem?) async {
        guard let item = item else {
            // If user cancelled and we're in the back button flow, keep the hasReturnedFromBack flag
            AnalyticsManager.shared.track(AppStrings.Analytics.photoImportCancelled)
            return
        }
        
        // Track that user tapped the import button
        AnalyticsManager.shared.track(AppStrings.Analytics.importPhotoButtonTapped)
        
        do {
            if let data = try await item.loadTransferable(type: Data.self),
               let image = UIImage(data: data) {
                editingViewModel.setOriginalImage(image)
                AnalyticsManager.shared.track(AppStrings.Analytics.photoImportSuccess, properties: [
                    AppStrings.AnalyticsProperties.imageWidth: Double(image.size.width),
                    AppStrings.AnalyticsProperties.imageHeight: Double(image.size.height),
                    AppStrings.AnalyticsProperties.hasAlpha: image.cgImage?.alphaInfo != CGImageAlphaInfo.none ? true : false
                ])
            }
        } catch {
            print("\(AppStrings.Debug.errorLoadingImage) \(error)")
            AnalyticsManager.shared.track(AppStrings.Analytics.photoImportFailed, properties: [
                AppStrings.AnalyticsProperties.error: error.localizedDescription
            ])
        }
    }
    
    /// Generates final image and presents share sheet
    @MainActor
    private func shareImage() async {
        // Track export attempt
        AnalyticsManager.shared.track(AppStrings.Analytics.exportStarted, properties: [
            AppStrings.AnalyticsProperties.exportCount: UserDefaultsManager.shared.freeExportCount,
            AppStrings.AnalyticsProperties.isSubscribed: subscriptionManager.hasPremiumAccess
        ])
        
        // Check export limit for free users
        if !subscriptionManager.hasPremiumAccess && UserDefaultsManager.shared.hasReachedFreeExportLimit {
            // Show paywall for free users who have reached the limit
            AnalyticsManager.shared.track(AppStrings.Analytics.exportLimitReached, properties: [
                AppStrings.AnalyticsProperties.exportCount: UserDefaultsManager.shared.freeExportCount,
                AppStrings.AnalyticsProperties.exportLimitReason: "free_limit_reached"
            ])
            showingPaywall = true
            return
        }
        
        // Start loading state
        isGeneratingShareImage = true
        
        // Generate image on background thread
        let finalImage = await Task.detached { [editingViewModel] in
            return editingViewModel.generateFinalImage()
        }.value
        
        // Update UI on main thread
        if let finalImage = finalImage {
            imageToShare = finalImage
            
            // Increment export count for free users after successful generation
            if !subscriptionManager.hasPremiumAccess {
                UserDefaultsManager.shared.incrementFreeExportCount()
            }
            
            AnalyticsManager.shared.track(AppStrings.Analytics.exportCompleted, properties: [
                AppStrings.AnalyticsProperties.exportCount: UserDefaultsManager.shared.freeExportCount,
                AppStrings.AnalyticsProperties.isSubscribed: subscriptionManager.hasPremiumAccess,
                AppStrings.AnalyticsProperties.cornerRadius: Double(editingViewModel.parameters.cornerRadius),
                AppStrings.AnalyticsProperties.padding: Double(editingViewModel.parameters.padding),
                AppStrings.AnalyticsProperties.shadowOpacity: Double(editingViewModel.parameters.shadowOpacity),
                AppStrings.AnalyticsProperties.shadowBlur: Double(editingViewModel.parameters.shadowBlur),
                AppStrings.AnalyticsProperties.backgroundType: editingViewModel.parameters.backgroundType == .solid ? AppStrings.AnalyticsProperties.solid : AppStrings.AnalyticsProperties.gradient,
                AppStrings.AnalyticsProperties.aspectRatio: editingViewModel.parameters.aspectRatio.rawValue
            ])
            AnalyticsManager.shared.track(AppStrings.Analytics.editorShareButtonTapped)
            
            // Request review after first successful export
            ReviewManager.shared.requestExportReview()
            
            // End loading state and show share sheet
            isGeneratingShareImage = false
            
            // Track share sheet opening with current editing state
            AnalyticsManager.shared.track(AppStrings.Analytics.shareSheetOpened, properties: [
                AppStrings.AnalyticsProperties.cornerRadius: Double(editingViewModel.parameters.cornerRadius),
                AppStrings.AnalyticsProperties.padding: Double(editingViewModel.parameters.padding),
                AppStrings.AnalyticsProperties.shadowOpacity: Double(editingViewModel.parameters.shadowOpacity),
                AppStrings.AnalyticsProperties.shadowBlur: Double(editingViewModel.parameters.shadowBlur),
                AppStrings.AnalyticsProperties.backgroundType: editingViewModel.parameters.backgroundType == .solid ? AppStrings.AnalyticsProperties.solid : AppStrings.AnalyticsProperties.gradient,
                AppStrings.AnalyticsProperties.aspectRatio: editingViewModel.parameters.aspectRatio.rawValue,
                AppStrings.AnalyticsProperties.isSubscribed: subscriptionManager.hasPremiumAccess
            ])
            
            showingShareSheet = true
        } else {
            // End loading state if generation failed
            isGeneratingShareImage = false
        }
    }
    
    /// Generates image and opens Facebook Stories or feed
    @MainActor
    private func generateImageAndOpenFacebook() async {
        guard let finalImage = await generateImageForSharing() else { return }
        
        // Try to open Facebook Stories first, fall back to main Facebook app
        let facebookStoriesURL = "facebook-stories://share"
        let facebookURL = "fb://"
        
        if let url = URL(string: facebookStoriesURL), UIApplication.shared.canOpenURL(url) {
            // Save image to pasteboard for Facebook Stories
            UIPasteboard.general.image = finalImage
            await UIApplication.shared.open(url)
        } else if let url = URL(string: facebookURL), UIApplication.shared.canOpenURL(url) {
            // Save image to pasteboard and open main Facebook app
            UIPasteboard.general.image = finalImage
            await UIApplication.shared.open(url)
        } else {
            // Facebook not installed, fall back to share sheet
            imageToShare = finalImage
            showingShareSheet = true
        }
    }
    
    /// Generates image and opens Instagram Stories
    @MainActor
    private func generateImageAndOpenInstagram() async {
        guard let finalImage = await generateImageForSharing() else { return }
        
        // Try to open Instagram Stories
        let instagramStoriesURL = "instagram-stories://share"
        let instagramURL = "instagram://"
        
        if let url = URL(string: instagramStoriesURL), UIApplication.shared.canOpenURL(url) {
            // Save image to pasteboard for Instagram Stories
            UIPasteboard.general.image = finalImage
            await UIApplication.shared.open(url)
        } else if let url = URL(string: instagramURL), UIApplication.shared.canOpenURL(url) {
            // Save image to pasteboard and open main Instagram app
            UIPasteboard.general.image = finalImage
            await UIApplication.shared.open(url)
        } else {
            // Instagram not installed, fall back to share sheet
            imageToShare = finalImage
            showingShareSheet = true
        }
    }
    
    /// Helper method to generate image for sharing with proper analytics and limits
    @MainActor
    private func generateImageForSharing() async -> UIImage? {
        // Check export limit for free users
        if !subscriptionManager.hasPremiumAccess && UserDefaultsManager.shared.hasReachedFreeExportLimit {
            showingPaywall = true
            return nil
        }
        
        // Generate image on background thread
        let finalImage = await Task.detached { [editingViewModel] in
            return editingViewModel.generateFinalImage()
        }.value
        
        if let finalImage = finalImage {
            // Increment export count for free users after successful generation
            if !subscriptionManager.hasPremiumAccess {
                UserDefaultsManager.shared.incrementFreeExportCount()
            }
            
            // Track export analytics
            AnalyticsManager.shared.track(AppStrings.Analytics.exportCompleted, properties: [
                AppStrings.AnalyticsProperties.exportCount: UserDefaultsManager.shared.freeExportCount,
                AppStrings.AnalyticsProperties.isSubscribed: subscriptionManager.hasPremiumAccess,
                AppStrings.AnalyticsProperties.cornerRadius: Double(editingViewModel.parameters.cornerRadius),
                AppStrings.AnalyticsProperties.padding: Double(editingViewModel.parameters.padding),
                AppStrings.AnalyticsProperties.shadowOpacity: Double(editingViewModel.parameters.shadowOpacity),
                AppStrings.AnalyticsProperties.shadowBlur: Double(editingViewModel.parameters.shadowBlur),
                AppStrings.AnalyticsProperties.backgroundType: editingViewModel.parameters.backgroundType == .solid ? AppStrings.AnalyticsProperties.solid : AppStrings.AnalyticsProperties.gradient,
                AppStrings.AnalyticsProperties.aspectRatio: editingViewModel.parameters.aspectRatio.rawValue
            ])
            
            // Request review after successful export
            ReviewManager.shared.requestExportReview()
        }
        
        return finalImage
    }
}

#Preview {
    ContentView()
}
