//
//  StyleSliderControl.swift
//  ScreenshotEditor
//
//  Created by Alastair McNeill on 19/08/2025.
//

import SwiftUI

/// Reusable slider control for style parameters
struct StyleSliderControl: View {
    let title: String
    let value: CGFloat
    let range: ClosedRange<CGFloat>
    let isDragging: Bool
    let onValueChange: (CGFloat) -> Void
    let onEditingChanged: (Bool) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundColor(.secondary)
            
            Slider(
                value: Binding(
                    get: { value },
                    set: onValueChange
                ),
                in: range,
                step: 1,
                onEditingChanged: onEditingChanged
            )
            .accentColor(.customAccent)
        }
    }
}

#Preview {
    StyleSliderControl(
        title: "Corner Radius",
        value: 50,
        range: 0...100,
        isDragging: false,
        onValueChange: { _ in },
        onEditingChanged: { _ in }
    )
    .padding()
}
