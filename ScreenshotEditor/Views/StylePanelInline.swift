//
//  StylePanelInline.swift
//  ScreenshotEditor
//
//  Created by Alastair McNeill on 19/08/2025.
//

import SwiftUI

struct StylePanelInline: View {
    @ObservedObject var editingViewModel: ImageEditingViewModel
    @Binding var isPresented: Bool
    @StateObject private var sliderViewModel = StyleSliderViewModel()
    
    var body: some View {
        VStack(spacing: 0) {
            // Handle indicator
            PanelHandleView()
            
            // Content
            VStack(spacing: 24) {
                // Title and done button
                PanelHeaderView(title: AppStrings.UI.style) {
                    withAnimation(.easeInOut(duration: AppConstants.StylePanel.animationDuration)) {
                        isPresented = false
                    }
                }
                
                // Style controls
                StyleControlsView(
                    editingViewModel: editingViewModel,
                    sliderViewModel: sliderViewModel
                )
            }
            .padding(16)
        }
        .background(Color(.systemBackground))
        .panelDragGesture(isPresented: $isPresented)
    }
}

// MARK: - Preview
#Preview {
    @Previewable @State var isPresented = true
    @Previewable @StateObject var viewModel = ImageEditingViewModel()
    
    return StylePanelInline(
        editingViewModel: viewModel,
        isPresented: $isPresented
    )
}
