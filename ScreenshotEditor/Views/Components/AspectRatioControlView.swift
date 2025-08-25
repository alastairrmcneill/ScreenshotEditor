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
                .foregroundColor(.secondary)
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
                        AspectRatioIconView(
                            ratio: ratio,
                            isSelected: editingViewModel.parameters.aspectRatio == ratio
                        )
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(editingViewModel.parameters.aspectRatio == ratio ? 
                                     Color.customAccent : 
                                     Color(.systemGray6))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(editingViewModel.parameters.aspectRatio == ratio ? 
                                               Color.customAccent : 
                                               Color.clear, lineWidth: 2)
                                )
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
    }
}

/// Visual icon representation for each aspect ratio
struct AspectRatioIconView: View {
    let ratio: AspectRatio
    let isSelected: Bool
    
    var body: some View {
        VStack(spacing: 4) {
            // Icon representation
            Group {
                switch ratio {
                case .free:
                    // Free aspect ratio - represented by expanding/resize icon
                    ZStack {
                        RoundedRectangle(cornerRadius: 2)
                            .stroke(iconColor, lineWidth: 1.5)
                            .frame(width: 16, height: 12)
                        
                        // Corner resize handles
                        VStack {
                            HStack {
                                cornerHandle
                                Spacer()
                                cornerHandle
                            }
                            Spacer()
                            HStack {
                                cornerHandle
                                Spacer()
                                cornerHandle
                            }
                        }
                        .frame(width: 20, height: 16)
                    }
                    
                case .square:
                    // 1:1 Square ratio
                    RoundedRectangle(cornerRadius: 2)
                        .stroke(iconColor, lineWidth: 1.5)
                        .frame(width: 14, height: 14)
                    
                case .portrait:
                    // 9:16 Portrait ratio
                    RoundedRectangle(cornerRadius: 2)
                        .stroke(iconColor, lineWidth: 1.5)
                        .frame(width: 10, height: 16)
                    
                case .landscape:
                    // 16:9 Landscape ratio
                    RoundedRectangle(cornerRadius: 2)
                        .stroke(iconColor, lineWidth: 1.5)
                        .frame(width: 18, height: 10)
                }
            }
            
            // Ratio label
            Text(ratioLabel)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(iconColor)
        }
    }
    
    private var iconColor: Color {
        isSelected ? Color.primary : Color.secondary
    }
    
    private var ratioLabel: String {
        switch ratio {
        case .free:
            return "Free"
        case .square:
            return "1:1"
        case .portrait:
            return "9:16"
        case .landscape:
            return "16:9"
        }
    }
    
    private var cornerHandle: some View {
        RoundedRectangle(cornerRadius: 0.5)
            .fill(iconColor)
            .frame(width: 2, height: 2)
    }
}

#Preview {
    AspectRatioControlView(editingViewModel: ImageEditingViewModel())
        .padding()
}
