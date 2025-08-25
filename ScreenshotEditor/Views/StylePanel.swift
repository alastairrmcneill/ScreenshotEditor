//
//  StylePanel.swift
//  ScreenshotEditor
//
//  Created by Alastair McNeill on 08/08/2025.
//

import SwiftUI

struct StylePanel: View {
    @ObservedObject var editingViewModel: ImageEditingViewModel
    @Binding var isPresented: Bool
    @StateObject private var sliderViewModel = StyleSliderViewModel()
    
    var body: some View {
        StandardModalBottomSheet(isPresented: $isPresented) {
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
    
    return StylePanel(
        editingViewModel: viewModel,
        isPresented: $isPresented
    )
}
