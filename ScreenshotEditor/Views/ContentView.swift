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
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var showingShareSheet = false
    @State private var showingCropView = false
    @State private var showingStylePanel = false
    @State private var imageToShare: UIImage?
    @State private var isGeneratingShareImage = false
    
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
                                
                                // Debug subscription status indicator
                                Text(UserDefaultsManager.shared.isSubscribed ? AppStrings.UI.premium : AppStrings.UI.free)
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                                    .onTapGesture {
                                        // Toggle subscription for testing
                                        UserDefaultsManager.shared.setSubscribed(!UserDefaultsManager.shared.isSubscribed)
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
                                    showWatermark: !UserDefaultsManager.shared.isSubscribed
                                )
                                .aspectRatio(contentMode: .fit)
                                .padding(AppConstants.Layout.standardPadding)
                            } else if let originalImage = editingViewModel.originalImage {
                                // Fallback while rendering
                                ImageRenderer.createImageView(
                                    image: originalImage,
                                    showWatermark: !UserDefaultsManager.shared.isSubscribed
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
                                    // TODO: Implement background panel
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
        }
        .onChange(of: selectedPhotoItem) { _, newItem in
            Task {
                await loadSelectedImage(from: newItem)
            }
        }
        .sheet(isPresented: $showingShareSheet) {
            if let imageToShare = imageToShare {
                ShareSheet(items: [imageToShare])
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
        // Start loading state
        isGeneratingShareImage = true
        
        // Generate image on background thread
        let finalImage = await Task.detached { [editingViewModel] in
            return editingViewModel.generateFinalImage()
        }.value
        
        // Update UI on main thread
        if let finalImage = finalImage {
            imageToShare = finalImage
            AnalyticsManager.shared.track(AppStrings.Analytics.editorShareButtonTapped)
            
            // End loading state and show share sheet
            isGeneratingShareImage = false
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
