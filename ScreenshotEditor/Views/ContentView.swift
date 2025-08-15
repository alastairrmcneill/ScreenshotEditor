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
    @State private var showingShareSheet = false
    @State private var showingCropView = false
    @State private var showingStylePanel = false
    @State private var showingBackgroundPanel = false
    @State private var imageToShare: UIImage?
    @State private var isGeneratingShareImage = false
    @State private var showingPaywall = false
    @State private var showingPostOnboardingPaywall = false
    
    var body: some View {
        ZStack {
            // Main Content
            ZStack {
                // Background
                Color(.systemBackground)
                    .ignoresSafeArea()
                
                if editingViewModel.originalImage == nil {
                    // Empty State UI
                    VStack(spacing: AppConstants.Layout.extraLargePadding) {
                        // Icon
                        Image(systemName: "photo.badge.plus")
                            .font(.system(size: AppConstants.Layout.emptyStateIconSize))
                            .foregroundColor(.secondary)
                        
                        // Title and subtitle
                        VStack(spacing: AppConstants.Layout.emptyStateTitleSpacing) {
                            Text(AppStrings.UI.noImageSelected)
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                            
                            Text(AppStrings.UI.importPhotoToGetStarted)
                                .font(.body)
                                .foregroundColor(.secondary)
                        }
                        
                        // Premium Status Display
                        VStack(spacing: 8) {
                            HStack {
                                Image(systemName: subscriptionManager.hasPremiumAccess ? AppStrings.SystemImages.crownFill : AppStrings.SystemImages.crown)
                                    .foregroundColor(subscriptionManager.hasPremiumAccess ? .yellow : .secondary)
                                
                                Text(subscriptionManager.hasPremiumAccess ? AppStrings.UI.premiumActive : AppStrings.UI.freePlan)
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .foregroundColor(subscriptionManager.hasPremiumAccess ? .primary : .secondary)
                            }
                            
                            if !subscriptionManager.activeEntitlements.isEmpty {
                                Text("\(AppStrings.UI.entitlements) \(subscriptionManager.activeEntitlements.joined(separator: ", "))")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                            }
                            
                            if subscriptionManager.hasPremiumAccess {
                                Text(AppStrings.UI.unlimitedExportsNowatermark)
                                    .font(.caption2)
                                    .foregroundColor(.green)
                            } else {
                                Text(AppStrings.UI.freeExportsWatermarked)
                                    .font(.caption2)
                                    .foregroundColor(.orange)
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        .padding(.horizontal)
                        
                        // Import Button
                        PhotosPicker(
                            selection: $selectedPhotoItem,
                            matching: .screenshots,
                            photoLibrary: .shared()
                        ) {
                            Text(AppStrings.UI.importPhoto)
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, AppConstants.Layout.standardPadding)
                                .background(Color.accentColor)
                                .cornerRadius(AppConstants.Layout.largeCornerRadius)
                        }
                        .padding(.horizontal, AppConstants.Layout.buttonHorizontalPadding)
                    }
                } else {
                    // Editor Canvas
                    VStack(spacing: AppConstants.Layout.zeroSpacing) {
                        // Navigation Bar Area
                        HStack {
                            Button(AppStrings.UI.back) {
                                editingViewModel.setOriginalImage(nil)
                                AnalyticsManager.shared.track(AppStrings.Analytics.editorBackButtonTapped)
                            }
                            .foregroundColor(.accentColor)
                            
                            Spacer()
                            
                            VStack(spacing: AppConstants.Layout.navigationAreaSpacing) {
                                Text(AppStrings.UI.editPhoto)
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                
                                // Premium status indicator
                                HStack(spacing: 4) {
                                    Image(systemName: subscriptionManager.hasPremiumAccess ? AppStrings.SystemImages.crownFill : AppStrings.SystemImages.crown)
                                        .font(.caption2)
                                        .foregroundColor(subscriptionManager.hasPremiumAccess ? .yellow : .secondary)
                                    
                                    Text(subscriptionManager.hasPremiumAccess ? AppStrings.UI.premium : AppStrings.UI.free)
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                }
                                .onTapGesture {
                                    // Debug: Force refresh entitlements
                                    subscriptionManager.checkSubscriptionStatus()
                                }
                            }
                            
                            Spacer()
                            
                            Button(action: {
                                Task {
                                    await shareImage()
                                }
                            }) {
                                HStack {
                                    if isGeneratingShareImage {
                                        ProgressView()
                                            .scaleEffect(AppConstants.Layout.emptyStateProgressScale)
                                            .foregroundColor(.accentColor)
                                    } else {
                                        Text(AppStrings.UI.share)
                                            .foregroundColor(.accentColor)
                                    }
                                }
                            }
                            .disabled(isGeneratingShareImage)
                        }
                        .padding(.horizontal, AppConstants.Layout.largePadding)
                        .padding(.vertical, AppConstants.Layout.standardPadding)
                        .background(Color(.systemBackground))
                        
                        // Main Canvas Area
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
                        
                        // Bottom Controls Area (placeholder for future stories)
                        VStack {
                            Divider()
                            
                            HStack {
                                Button(AppStrings.UI.crop) {
                                    showingCropView = true
                                    AnalyticsManager.shared.track(AppStrings.Analytics.cropButtonTapped)
                                }
                                .foregroundColor(.accentColor)
                                
                                Spacer()
                                
                                Button(AppStrings.UI.style) {
                                    withAnimation(.easeInOut(duration: AppConstants.StylePanel.animationDuration)) {
                                        showingStylePanel = true
                                    }
                                    AnalyticsManager.shared.track(AppStrings.Analytics.styleButtonTapped)
                                }
                                .foregroundColor(.accentColor)
                                
                                Spacer()
                                
                                Button(AppStrings.UI.background) {
                                    withAnimation(.easeInOut(duration: AppConstants.StylePanel.animationDuration)) {
                                        showingBackgroundPanel = true
                                    }
                                    AnalyticsManager.shared.track(AppStrings.Analytics.backgroundButtonTapped)
                                }
                                .foregroundColor(.accentColor)
                            }
                            .padding(.horizontal, AppConstants.Layout.controlsHorizontalPadding)
                            .padding(.vertical, AppConstants.Layout.standardPadding)
                        }
                        .background(Color(.systemBackground))
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
            
            // Style Panel Overlay
            if showingStylePanel {
                StylePanel(
                    editingViewModel: editingViewModel,
                    isPresented: $showingStylePanel
                )
                .transition(.opacity)
            }
            
            // Background Panel Overlay
            if showingBackgroundPanel {
                BackgroundPanel(
                    editingViewModel: editingViewModel,
                    isPresented: $showingBackgroundPanel
                )
                .transition(.opacity)
            }
            
        }
        .onChange(of: selectedPhotoItem) { _, newItem in
            Task {
                await loadSelectedImage(from: newItem)
            }
        }
        .sheet(isPresented: $showingPaywall) {
            PaywallView(isPresented: $showingPaywall) {
                // For now, just toggle subscription status for testing
                // In a real app, this would trigger StoreKit purchase flow
                UserDefaultsManager.shared.setSubscribed(true)
                showingPaywall = false
            }
        }
        .sheet(isPresented: $showingShareSheet) {
            if let imageToShare = imageToShare {
                ShareSheet.forImageSaving(image: imageToShare)
            }
        }
        .sheet(isPresented: $showingPostOnboardingPaywall) {
            PaywallView(isPresented: $showingPostOnboardingPaywall) {
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
    }
    
    /// Loads the selected image asynchronously using the modern PhotosPicker API
    /// - Parameter item: The selected PhotosPickerItem
    @MainActor
    private func loadSelectedImage(from item: PhotosPickerItem?) async {
        guard let item = item else {
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
}

#Preview {
    ContentView()
}
