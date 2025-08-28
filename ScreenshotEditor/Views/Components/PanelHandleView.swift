//
//  PanelHandleView.swift
//  ScreenshotEditor
//
//  Created by Alastair McNeill on 19/08/2025.
//

import SwiftUI

/// Reusable handle indicator for panels
struct PanelHandleView: View {
    var body: some View {
        RoundedRectangle(cornerRadius: AppConstants.StylePanel.handleIndicatorCornerRadius)
            .fill(Color.secondary.opacity(AppConstants.StylePanel.handleIndicatorOpacity))
            .frame(
                width: AppConstants.StylePanel.handleIndicatorWidth, 
                height: AppConstants.StylePanel.handleIndicatorHeight
            )
            .padding(.top, 12)
            .padding(.bottom, 8)
    }
}

#Preview {
    PanelHandleView()
}
