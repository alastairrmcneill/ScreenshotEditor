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
    
    // Drag gesture state
    @State private var dragOffset: CGFloat = 0
    @State private var isDragging = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Handle indicator
            RoundedRectangle(cornerRadius: AppConstants.StylePanel.handleIndicatorCornerRadius)
                .fill(Color.secondary.opacity(AppConstants.StylePanel.handleIndicatorOpacity))
                .frame(width: AppConstants.StylePanel.handleIndicatorWidth, height: AppConstants.StylePanel.handleIndicatorHeight)
                .padding(.top, 12)
                .padding(.bottom, 8)
            
            // Content
            VStack(spacing: 24) {
                // Title
                HStack {
                    Text(AppStrings.UI.background)
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Spacer()
                    
                    Button(AppStrings.UI.done) {
                        withAnimation(.easeInOut(duration: AppConstants.StylePanel.animationDuration)) {
                            isPresented = false
                        }
                    }
                    .foregroundColor(.accentColor)
                }
                
                // Aspect Ratio Section
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
                                            .fill(editingViewModel.parameters.aspectRatio == ratio ? Color.accentColor : Color(.systemGray5))
                                    )
                            }
                        }
                    }
                }
                
                // Segmented Control
                Picker(AppStrings.Accessibility.backgroundTypePicker, selection: Binding(
                    get: { editingViewModel.parameters.backgroundType },
                    set: { newType in
                        editingViewModel.updateBackgroundType(newType)
                    }
                )) {
                    Text(AppStrings.UI.solid).tag(BackgroundType.solid)
                    Text(AppStrings.UI.gradient).tag(BackgroundType.gradient)
                }
                .pickerStyle(SegmentedPickerStyle())
                
                // Content Grid
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
                                            .stroke(Color.accentColor, lineWidth: editingViewModel.parameters.selectedSolidColor == color ? 3 : 0)
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
                                            .stroke(Color.accentColor, lineWidth: editingViewModel.parameters.selectedGradient == gradient ? 3 : 0)
                                    )
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 34) // Extra padding for home indicator
        }
        .background(Color(.systemBackground))
        .offset(y: dragOffset)
        .gesture(
            DragGesture()
                .onChanged { gesture in
                    // Only allow downward dragging
                    let translation = gesture.translation
                    if translation.height > 0 {
                        dragOffset = translation.height
                        isDragging = true
                    }
                }
                .onEnded { gesture in
                    isDragging = false
                    
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

#Preview {
    BackgroundPanelInline(
        editingViewModel: ImageEditingViewModel(),
        isPresented: .constant(true)
    )
}
