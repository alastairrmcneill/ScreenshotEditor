//
//  BackgroundGridView.swift
//  ScreenshotEditor
//
//  Created by Alastair McNeill on 19/08/2025.
//

import SwiftUI

/// Reusable background grid view that displays either solid colors or gradients
struct BackgroundGridView: View {
    @ObservedObject var editingViewModel: ImageEditingViewModel
    
    var body: some View {
        if editingViewModel.parameters.backgroundType == .solid {
            // Solid Colors Grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 16) {
                ForEach(BackgroundColor.allCases, id: \.self) { color in
                    Button(action: {
                        editingViewModel.updateSolidColor(color)
                    }) {
                        Circle()
                            .fill(Color(cgColor: color.color))
                            .frame(width: 50, height: 50)
                            .overlay(
                                Circle()
                                    .stroke(Color.customAccent, lineWidth: editingViewModel.parameters.selectedSolidColor == color ? 3 : 0)
                            )
                            .overlay(
                                // Special handling for white color to show a border
                                Circle()
                                    .stroke(Color.gray.opacity(0.3), lineWidth: color == .white ? 1 : 0)
                            )
                    }
                }
            }
        } else {
            // Gradient Grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 16) {
                ForEach(BackgroundGradient.allCases, id: \.self) { gradient in
                    Button(action: {
                        editingViewModel.updateGradient(gradient)
                    }) {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: gradient.colors.map { Color(cgColor: $0) },
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 50, height: 50)
                            .overlay(
                                Circle()
                                    .stroke(Color.customAccent, lineWidth: editingViewModel.parameters.selectedGradient == gradient ? 3 : 0)
                            )
                    }
                }
            }
        }
    }
}

#Preview {
    BackgroundGridView(editingViewModel: ImageEditingViewModel())
        .padding()
}
