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
        StandardBottomSheet(isPresented: $isPresented) {
            // Style controls
            StyleControlsView(
                editingViewModel: editingViewModel,
                sliderViewModel: sliderViewModel
            )
        }
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
