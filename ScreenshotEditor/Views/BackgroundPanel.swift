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
        StandardModalBottomSheet(isPresented: $isPresented) {
            // Background controls
            BackgroundControlsView(editingViewModel: editingViewModel)
        }
    }
}

#Preview {
    BackgroundPanel(
        editingViewModel: ImageEditingViewModel(),
        isPresented: .constant(true)
    )
}
