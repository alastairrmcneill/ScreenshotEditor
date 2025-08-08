//
//  ContentView.swift
//  ScreenshotEditor
//
//  Created by Alastair McNeill on 07/08/2025.
//

import SwiftUI
import PhotosUI

struct ContentView: View {
    @State private var selectedImage: UIImage?
    @State private var showingImagePicker = false
    
    var body: some View {
        ZStack {
            // Background
            Color(.systemBackground)
                .ignoresSafeArea()
            
            if selectedImage == nil {
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
                            selectedImage = nil
                            AnalyticsManager.shared.track("Editor Back Button Tapped")
                        }
                        .foregroundColor(.accentColor)
                        
                        Spacer()
                        
                        Text("Edit Photo")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Spacer()
                        
                        Button("Share") {
                            // TODO: Implement share functionality in future stories
                            AnalyticsManager.shared.track("Editor Share Button Tapped")
                        }
                        .foregroundColor(.accentColor)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                    .background(Color(.systemBackground))
                    
                    // Main Canvas Area
                    ScrollView {
                        VStack {
                            Spacer(minLength: 40)
                            
                            // Image Canvas
                            if let image = selectedImage {
                                Image(uiImage: image)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(maxWidth: UIScreen.main.bounds.width - 40)
                                    .cornerRadius(12)
                                    .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                                    .padding(.horizontal, 20)
                            }
                            
                            Spacer(minLength: 40)
                        }
                    }
                    .background(Color(.systemGray6))
                    
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
                    AnalyticsManager.shared.track("Editor Opened", properties: [
                        "image_width": Double(selectedImage?.size.width ?? 0),
                        "image_height": Double(selectedImage?.size.height ?? 0)
                    ])
                }
            }
        }
        .sheet(isPresented: $showingImagePicker) {
            PhotoPickerView(selectedImage: $selectedImage)
        }
    }
}

#Preview {
    ContentView()
}
