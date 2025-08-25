//
//  AspectRatioPanelInline.swift
//  ScreenshotEditor
//
//  Created by Alastair McNeill on 25/08/2025.
//

import SwiftUI

struct AspectRatioPanelInline: View {
    @ObservedObject var editingViewModel: ImageEditingViewModel
    @Binding var isPresented: Bool
    
    var body: some View {
        StandardBottomSheet(isPresented: $isPresented) {
            // Aspect ratio controls
            AspectRatioControlView(editingViewModel: editingViewModel)
        }
    }
}

#Preview {
    AspectRatioPanelInline(
        editingViewModel: ImageEditingViewModel(),
        isPresented: .constant(true)
    )
}
