//
//  StyleControlsView.swift
//  ScreenshotEditor
//
//  Created by Alastair McNeill on 19/08/2025.
//

import SwiftUI

/// Reusable view containing all style controls (corner radius, padding, shadow)
struct StyleControlsView: View {
    @ObservedObject var editingViewModel: ImageEditingViewModel
    @ObservedObject var sliderViewModel: StyleSliderViewModel
    
    var body: some View {
        VStack(spacing: 24) {
            // Corner Radius Control
            StyleSliderControl(
                title: AppStrings.UI.cornerRadius,
                value: sliderViewModel.getCornerRadiusValue(from: editingViewModel),
                range: AppConstants.StylePanel.minCornerRadius...AppConstants.StylePanel.maxCornerRadius,
                isDragging: false, // Not used in current implementation
                onValueChange: { value in
                    sliderViewModel.updateCornerRadiusValue(value)
                },
                onEditingChanged: { editing in
                    if !editing {
                        sliderViewModel.finishCornerRadiusEditing(editingViewModel: editingViewModel)
                    }
                }
            )
            
            // Padding Control
            StyleSliderControl(
                title: AppStrings.UI.padding,
                value: sliderViewModel.getPaddingValue(from: editingViewModel),
                range: AppConstants.StylePanel.minPadding...AppConstants.StylePanel.maxPadding,
                isDragging: false, // Not used in current implementation
                onValueChange: { value in
                    sliderViewModel.updatePaddingValue(value)
                },
                onEditingChanged: { editing in
                    if !editing {
                        sliderViewModel.finishPaddingEditing(editingViewModel: editingViewModel)
                    }
                }
            )
            
            // Shadow Control
            StyleSliderControl(
                title: AppStrings.UI.shadow,
                value: sliderViewModel.getShadowValue(from: editingViewModel),
                range: AppConstants.StylePanel.minShadowBlur...AppConstants.StylePanel.maxShadowBlur,
                isDragging: false, // Not used in current implementation
                onValueChange: { value in
                    sliderViewModel.updateShadowValue(value)
                },
                onEditingChanged: { editing in
                    if !editing {
                        sliderViewModel.finishShadowEditing(editingViewModel: editingViewModel)
                    }
                }
            )
        }
        .onAppear {
            sliderViewModel.initializeValues(from: editingViewModel)
        }
    }
}

#Preview {
    @Previewable @StateObject var editingViewModel = ImageEditingViewModel()
    @Previewable @StateObject var sliderViewModel = StyleSliderViewModel()
    
    StyleControlsView(
        editingViewModel: editingViewModel,
        sliderViewModel: sliderViewModel
    )
    .padding()
}
