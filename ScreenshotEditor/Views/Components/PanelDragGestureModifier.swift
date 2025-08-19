//
//  PanelDragGestureModifier.swift
//  ScreenshotEditor
//
//  Created by Alastair McNeill on 19/08/2025.
//

import SwiftUI

/// ViewModifier that adds drag-to-dismiss functionality to panels
struct PanelDragGestureModifier: ViewModifier {
    @Binding var isPresented: Bool
    @State private var dragOffset: CGFloat = 0
    
    func body(content: Content) -> some View {
        content
            .offset(y: dragOffset)
            .gesture(
                DragGesture()
                    .onChanged { gesture in
                        // Only allow downward dragging
                        let translation = gesture.translation
                        if translation.height > 0 {
                            dragOffset = translation.height
                        }
                    }
                    .onEnded { gesture in
                        // If dragged down more than 100 points, dismiss the panel
                        if dragOffset > 100 {
                            withAnimation(.easeInOut(duration: AppConstants.StylePanel.animationDuration)) {
                                isPresented = false
                            }
                        } else {
                            // Snap back to original position
                            withAnimation(.spring(response: 0.3)) {
                                dragOffset = 0
                            }
                        }
                    }
            )
            .onChange(of: isPresented) { newValue in
                if !newValue {
                    // Reset drag offset when panel is dismissed
                    dragOffset = 0
                }
            }
    }
}

extension View {
    /// Adds drag-to-dismiss functionality to a panel
    func panelDragGesture(isPresented: Binding<Bool>) -> some View {
        modifier(PanelDragGestureModifier(isPresented: isPresented))
    }
}
