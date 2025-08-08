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
    @State private var imageToShare: UIImage?
    @State private var isGeneratingShareImage = false
    
    var body: some View {
        ZStack {
            // Background
            Color(.systemBackground)
                .ignoresSafeArea()
            
            if editingViewModel.originalImage == nil {
                // Empty State UI
                VStack(spacing: 24) {
                    // Icon
                    Image(systemName: "photo.badge.plus")
                        .font(.system(size: 64))
                        .foregroundColor(.secondary)
                    
                    // Title and subtitle
                    VStack(spacing: 8) {
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
                            .padding(.vertical, 16)
                            .background(Color.accentColor)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal, 48)
                }
            } else {
                // Editor Canvas
                VStack(spacing: 0) {
                    // Navigation Bar Area
                    HStack {
                        Button(AppStrings.UI.back) {
                            editingViewModel.setOriginalImage(nil)
                            AnalyticsManager.shared.track(AppStrings.Analytics.editorBackButtonTapped)
                        }
                        .foregroundColor(.accentColor)
                        
                        Spacer()
                        
                        VStack(spacing: 2) {
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
                                        .scaleEffect(0.8)
                                        .foregroundColor(.accentColor)
                                } else {
                                    Text(AppStrings.UI.share)
                                        .foregroundColor(.accentColor)
                                }
                            }
                        }
                        .disabled(isGeneratingShareImage)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
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
                            .padding(20)
                            .cornerRadius(12)
                            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                        } else if let originalImage = editingViewModel.originalImage {
                            // Fallback while rendering
                            ImageRenderer.createImageView(
                                image: originalImage,
                                showWatermark: !UserDefaultsManager.shared.isSubscribed
                            )
                            .aspectRatio(contentMode: .fit)
                            .padding(20)
                            .cornerRadius(12)
                            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                            .opacity(0.5)
                        }
                    }
                    
                    // Bottom Controls Area (placeholder for future stories)
                    VStack {
                        Divider()
                        
                        HStack {
                            Button(AppStrings.UI.crop) {
                                // TODO: Implement crop functionality
                                AnalyticsManager.shared.track(AppStrings.Analytics.cropButtonTapped)
                            }
                            .foregroundColor(.accentColor)
                            
                            Spacer()
                            
                            Button(AppStrings.UI.style) {
                                // TODO: Implement style panel
                                // For now, let's add a demo corner radius change
                                let newRadius = editingViewModel.parameters.cornerRadius == 0 ? 12.0 : 0.0
                                editingViewModel.updateCornerRadius(newRadius)
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
                        .padding(.horizontal, 40)
                        .padding(.vertical, 16)
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
                    AppStrings.AnalyticsProperties.hasAlpha: image.cgImage?.alphaInfo != .none ? true : false
                ])
            }
        } catch {
            print("Error loading image: \(error)")
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
        let finalImage = await Task.detached {
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
