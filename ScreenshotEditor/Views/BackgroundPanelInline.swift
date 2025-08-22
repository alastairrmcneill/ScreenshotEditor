//
//  BackgroundPanelInline.swift
//  ScreenshotEditor
//
//  Created by Alastair McNeill on 19/08/2025.
//

import SwiftUI

struct BackgroundPanelInline: View {
    @ObservedObject var editingViewModel: ImageEditingViewModel
    @Binding var isPresented: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            // Handle indicator
            PanelHandleView()
            
            // Content
            VStack(spacing: 24) {
                // Title and done button
                PanelHeaderView(title: AppStrings.UI.background) {
                    withAnimation(.easeInOut(duration: AppConstants.StylePanel.animationDuration)) {
                        isPresented = false
                    }
                }
                
                // Background controls
                BackgroundControlsView(editingViewModel: editingViewModel)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 34) // Extra padding for home indicator
        }
        .background(Color(.systemGray5))
        .panelDragGesture(isPresented: $isPresented)
    }
}
    #Preview {
    BackgroundPanelInline(
        editingViewModel: ImageEditingViewModel(),
        isPresented: .constant(true)
    )
}
