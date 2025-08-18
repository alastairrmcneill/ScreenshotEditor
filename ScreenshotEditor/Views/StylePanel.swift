//
//  StylePanel.swift
//  ScreenshotEditor
//
//  Created by Alastair McNeill on 08/08/2025.
//

import SwiftUI

struct StylePanel: View {
    @ObservedObject var editingViewModel: ImageEditingViewModel
    @Binding var isPresented: Bool
    
    // Local state for slider values during dragging
    @State private var tempCornerRadius: CGFloat = 50
    @State private var tempPadding: CGFloat = 140
    @State private var tempShadowBlur: CGFloat = 13
    @State private var isDraggingCornerRadius = false
    @State private var isDraggingPadding = false
    @State private var isDraggingShadowBlur = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background overlay that dismisses on tap
                Color.black.opacity(AppConstants.StylePanel.backgroundOpacity)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: AppConstants.StylePanel.animationDuration)) {
                            isPresented = false
                        }
                    }
                
                VStack {
                    Spacer()
                    
                    // Bottom Sheet
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
                    .cornerRadius(16, corners: [.topLeft, .topRight])
                    .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: -5)
                }
            }
        }
        .onAppear {
            // Initialize temp values with current parameters
            tempCornerRadius = editingViewModel.parameters.cornerRadius
            tempPadding = editingViewModel.parameters.padding
            tempShadowBlur = editingViewModel.parameters.shadowBlur
        }
    }
}

// MARK: - View Extension for Selective Corner Radius
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

// MARK: - Preview
#Preview {
    @Previewable @State var isPresented = true
    @Previewable @StateObject var viewModel = ImageEditingViewModel()
    
    return StylePanel(
        editingViewModel: viewModel,
        isPresented: $isPresented
    )
}
