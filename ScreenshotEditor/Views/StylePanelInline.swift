//
//  StylePanelInline.swift
//  ScreenshotEditor
//
//  Created by Alastair McNeill on 19/08/2025.
//

import SwiftUI

struct StylePanelInline: View {
    @ObservedObject var editingViewModel: ImageEditingViewModel
    @Binding var isPresented: Bool
    
    // Local state for slider values during dragging
    @State private var tempCornerRadius: CGFloat = 50
    @State private var tempPadding: CGFloat = 140
    @State private var tempShadowBlur: CGFloat = 13
    @State private var isDraggingCornerRadius = false
    @State private var isDraggingPadding = false
    @State private var isDraggingShadowBlur = false
    
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
                    Text(AppStrings.UI.style)
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
                
                // Corner Radius Control
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(AppStrings.UI.cornerRadius)
                            .font(.headline)
                        
                        Spacer()
                        
                        Text("\(Int(isDraggingCornerRadius ? tempCornerRadius : editingViewModel.parameters.cornerRadius))pt")
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    
                    Slider(
                        value: Binding(
                            get: { 
                                isDraggingCornerRadius ? tempCornerRadius : editingViewModel.parameters.cornerRadius 
                            },
                            set: { newValue in
                                tempCornerRadius = newValue
                                if !isDraggingCornerRadius {
                                    isDraggingCornerRadius = true
                                }
                            }
                        ),
                        in: AppConstants.StylePanel.minCornerRadius...AppConstants.StylePanel.maxCornerRadius,
                        step: 1,
                        onEditingChanged: { editing in
                            if !editing && isDraggingCornerRadius {
                                // User released the slider, apply the change
                                editingViewModel.updateCornerRadius(tempCornerRadius)
                                isDraggingCornerRadius = false
                            }
                        }
                    )
                    .accentColor(.accentColor)
                }
                
                // Padding Control
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(AppStrings.UI.padding)
                            .font(.headline)
                        
                        Spacer()
                        
                        Text("\(Int(isDraggingPadding ? tempPadding : editingViewModel.parameters.padding))pt")
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    
                    Slider(
                        value: Binding(
                            get: { 
                                isDraggingPadding ? tempPadding : editingViewModel.parameters.padding 
                            },
                            set: { newValue in
                                tempPadding = newValue
                                if !isDraggingPadding {
                                    isDraggingPadding = true
                                }
                            }
                        ),
                        in: AppConstants.StylePanel.minPadding...AppConstants.StylePanel.maxPadding,
                        step: 1,
                        onEditingChanged: { editing in
                            if !editing && isDraggingPadding {
                                // User released the slider, apply the change
                                editingViewModel.updatePadding(tempPadding)
                                isDraggingPadding = false
                            }
                        }
                    )
                    .accentColor(.accentColor)
                }
                
                // Shadow Control
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(AppStrings.UI.shadow)
                            .font(.headline)
                        
                        Spacer()
                        
                        Text("\(Int(isDraggingShadowBlur ? tempShadowBlur : editingViewModel.parameters.shadowBlur))pt")
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    
                    Slider(
                        value: Binding(
                            get: { 
                                isDraggingShadowBlur ? tempShadowBlur : editingViewModel.parameters.shadowBlur 
                            },
                            set: { newValue in
                                tempShadowBlur = newValue
                                if !isDraggingShadowBlur {
                                    isDraggingShadowBlur = true
                                }
                            }
                        ),
                        in: AppConstants.StylePanel.minShadowBlur...AppConstants.StylePanel.maxShadowBlur,
                        step: 1,
                        onEditingChanged: { editing in
                            if !editing && isDraggingShadowBlur {
                                // Set fixed values for offset and opacity
                                editingViewModel.updateShadowOffset(0) // Fixed at 0
                                editingViewModel.updateShadowOpacity(0.3) // Fixed at 30%
                                editingViewModel.updateShadowBlur(tempShadowBlur)
                                editingViewModel.updateShadowEnabled(tempShadowBlur > 0)
                                isDraggingShadowBlur = false
                            }
                        }
                    )
                    .accentColor(.accentColor)
                }
            }
            .padding(16)
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
        .onAppear {
            // Initialize temp values with current parameters
            tempCornerRadius = editingViewModel.parameters.cornerRadius
            tempPadding = editingViewModel.parameters.padding
            tempShadowBlur = editingViewModel.parameters.shadowBlur
        }
        .onChange(of: isPresented) { newValue in
            if !newValue {
                // Reset drag offset when panel is dismissed
                dragOffset = 0
            }
        }
    }
}

// MARK: - Preview
#Preview {
    @Previewable @State var isPresented = true
    @Previewable @StateObject var viewModel = ImageEditingViewModel()
    
    return StylePanelInline(
        editingViewModel: viewModel,
        isPresented: $isPresented
    )
}
