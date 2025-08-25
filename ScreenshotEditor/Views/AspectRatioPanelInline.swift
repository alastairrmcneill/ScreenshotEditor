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
        VStack(spacing: 0) {
            // Handle indicator
            PanelHandleView()
            
            // Content
            VStack(spacing: 24) {
                // Aspect ratio controls
                AspectRatioControlView(editingViewModel: editingViewModel)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 34) // Extra padding for home indicator
        }
        .background(Color(.systemGray5))
        .panelDragGesture(isPresented: $isPresented)
    }
}

#Preview {
    AspectRatioPanelInline(
        editingViewModel: ImageEditingViewModel(),
        isPresented: .constant(true)
    )
}
