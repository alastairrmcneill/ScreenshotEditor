//
//  ContentView.swift
//  ScreenshotEditor
//
//  Created by Alastair McNeill on 07/08/2025.
//

import SwiftUI

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
                // TODO: Display selected image in editor canvas
                Text("Image selected - Editor UI coming in Story 2.3")
                    .foregroundColor(.secondary)
            }
        }
        .sheet(isPresented: $showingImagePicker) {
            // TODO: Implement PHPicker in Story 2.2
            Text("PHPicker implementation coming in Story 2.2")
                .presentationDetents([.medium])
        }
    }
}

#Preview {
    ContentView()
}
