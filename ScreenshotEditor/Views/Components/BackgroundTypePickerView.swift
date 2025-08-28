//
//  BackgroundTypePickerView.swift
//  ScreenshotEditor
//
//  Created by Alastair McNeill on 19/08/2025.
//

import SwiftUI

/// Reusable background type picker component
struct BackgroundTypePickerView: View {
    @ObservedObject var editingViewModel: ImageEditingViewModel
    
    var body: some View {
        Picker(AppStrings.Accessibility.backgroundTypePicker, selection: Binding(
            get: { editingViewModel.parameters.backgroundType },
            set: { newType in
                editingViewModel.updateBackgroundType(newType)
            }
        )) {
            Text(AppStrings.UI.solid).tag(BackgroundType.solid)
            Text(AppStrings.UI.gradient).tag(BackgroundType.gradient)
        }
        .pickerStyle(SegmentedPickerStyle())
    }
}

#Preview {
    BackgroundTypePickerView(editingViewModel: ImageEditingViewModel())
        .padding()
}
