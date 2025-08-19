//
//  BackgroundControlsView.swift
//  ScreenshotEditor
//
//  Created by Alastair McNeill on 19/08/2025.
//

import SwiftUI

/// Reusable view containing all background controls
struct BackgroundControlsView: View {
    @ObservedObject var editingViewModel: ImageEditingViewModel
    
    var body: some View {
        VStack(spacing: 24) {
            // Aspect Ratio Section
            AspectRatioControlView(editingViewModel: editingViewModel)
            
            // Background Type Picker
            BackgroundTypePickerView(editingViewModel: editingViewModel)
            
            // Background Grid
            BackgroundGridView(editingViewModel: editingViewModel)
        }
    }
}

#Preview {
    BackgroundControlsView(editingViewModel: ImageEditingViewModel())
        .padding()
}
