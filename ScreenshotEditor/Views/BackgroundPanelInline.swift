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
        StandardBottomSheet(isPresented: $isPresented) {
            // Background controls
            BackgroundControlsView(editingViewModel: editingViewModel)
        }
    }
}
    #Preview {
    BackgroundPanelInline(
        editingViewModel: ImageEditingViewModel(),
        isPresented: .constant(true)
    )
}
