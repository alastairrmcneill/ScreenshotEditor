//
//  BackgroundPanel.swift
//  ScreenshotEditor
//
//  Created by Alastair McNeill on 11/08/2025.
//

import SwiftUI

struct BackgroundPanel: View {
    @ObservedObject var editingViewModel: ImageEditingViewModel
    @Binding var isPresented: Bool
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background overlay that dismisses on tap
                Color.black.opacity(AppConstants.StylePanel.backgroundOpacity)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: AppConstants.StylePanel.animationDuration)) {
                            isPresented = false
                        }
                    }
                
                VStack {
                    Spacer()
                    
                    // Bottom Sheet
                    VStack(spacing: 0) {
                        // Handle indicator
                        PanelHandleView()
                        
                        // Content
                        VStack(spacing: 24) {
                            // Background controls
                            BackgroundControlsView(editingViewModel: editingViewModel)
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 34) // Extra padding for home indicator
                    }
                    .background(Color(.systemBackground))
                    .cornerRadius(16, corners: [.topLeft, .topRight])
                }
            }
        }
    }
}

#Preview {
    BackgroundPanel(
        editingViewModel: ImageEditingViewModel(),
        isPresented: .constant(true)
    )
}
