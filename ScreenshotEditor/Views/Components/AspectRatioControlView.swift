//
//  AspectRatioControlView.swift
//  ScreenshotEditor
//
//  Created by Alastair McNeill on 19/08/2025.
//

import SwiftUI

/// Reusable aspect ratio control component
struct AspectRatioControlView: View {
    @ObservedObject var editingViewModel: ImageEditingViewModel
    
    var body: some View {
        VStack(spacing: 16) {
            // Aspect Ratio Title
            HStack {
                Text(AppStrings.UI.aspectRatio)
                    .font(.headline)
                    .fontWeight(.medium)
                Spacer()
            }
            
            // Aspect Ratio Controls
            HStack(spacing: 12) {
                ForEach(AspectRatio.allCases, id: \.self) { ratio in
                    Button(action: {
                        editingViewModel.updateAspectRatio(ratio)
                        AnalyticsManager.shared.track(AppStrings.Analytics.aspectRatioChanged, properties: [
                            "aspect_ratio": ratio.rawValue
                        ])
                    }) {
                        Text(ratio.rawValue)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(editingViewModel.parameters.aspectRatio == ratio ? .white : .primary)
                            .frame(maxWidth: .infinity)
                            .frame(height: 36)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(editingViewModel.parameters.aspectRatio == ratio ? Color(.systemGray6): Color.buttonBackground)
                            )
                    }
                }
            }
        }
    }
}

#Preview {
    AspectRatioControlView(editingViewModel: ImageEditingViewModel())
        .padding()
}
