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
    @State private var showingImagePicker = false
    @State private var showingShareSheet = false
    @State private var imageToShare: UIImage?
    
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
                        Text("No Image Selected")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        Text("Import a photo to get started")
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    
                    // Import Button
                    Button(action: {
                        showingImagePicker = true
                        AnalyticsManager.shared.track("Import Photo Button Tapped")
                    }) {
                        Text("Import Photo")
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
                        Button("Back") {
                            editingViewModel.setOriginalImage(nil)
                            AnalyticsManager.shared.track("Editor Back Button Tapped")
                        }
                        .foregroundColor(.accentColor)
                        
                        Spacer()
                        
                        VStack(spacing: 2) {
                            Text("Edit Photo")
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            // Debug subscription status indicator
                            Text(UserDefaultsManager.shared.isSubscribed ? "Premium" : "Free")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                                .onTapGesture {
                                    // Toggle subscription for testing
                                    UserDefaultsManager.shared.setSubscribed(!UserDefaultsManager.shared.isSubscribed)
                                }
                        }
                        
                        Spacer()
                        
                        Button("Share") {
                            if let finalImage = editingViewModel.generateFinalImage() {
                                imageToShare = finalImage
                                showingShareSheet = true
                                AnalyticsManager.shared.track("Editor Share Button Tapped")
                            }
                        }
                        .foregroundColor(.accentColor)
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
                            Button("Crop") {
                                // TODO: Implement crop functionality
                                AnalyticsManager.shared.track("Crop Button Tapped")
                            }
                            .foregroundColor(.accentColor)
                            
                            Spacer()
                            
                            Button("Style") {
                                // TODO: Implement style panel
                                // For now, let's add a demo corner radius change
                                let newRadius = editingViewModel.parameters.cornerRadius == 0 ? 12.0 : 0.0
                                editingViewModel.updateCornerRadius(newRadius)
                                AnalyticsManager.shared.track("Style Button Tapped")
                            }
                            .foregroundColor(.accentColor)
                            
                            Spacer()
                            
                            Button("Background") {
                                // TODO: Implement background panel
                                AnalyticsManager.shared.track("Background Button Tapped")
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
                        AnalyticsManager.shared.track("Editor Opened", properties: [
                            "image_width": Double(originalImage.size.width),
                            "image_height": Double(originalImage.size.height)
                        ])
                    }
                }
            }
        }
        .sheet(isPresented: $showingImagePicker) {
            PhotoPickerView(selectedImage: Binding(
                get: { editingViewModel.originalImage },
                set: { newImage in
                    if let image = newImage {
                        editingViewModel.setOriginalImage(image)
                    }
                }
            ))
        }
        .sheet(isPresented: $showingShareSheet) {
            if let imageToShare = imageToShare {
                ShareSheet(items: [imageToShare])
            }
        }
    }
}

#Preview {
    ContentView()
}
