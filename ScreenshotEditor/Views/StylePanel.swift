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
    @StateObject private var sliderViewModel = StyleSliderViewModel()
    
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
                        PanelHandleView()
                        
                        // Content
                        VStack(spacing: 24) {
                            // Title and done button
                            PanelHeaderView(title: AppStrings.UI.style) {
                                withAnimation(.easeInOut(duration: AppConstants.StylePanel.animationDuration)) {
                                    isPresented = false
                                }
                            }
                            
                            // Style controls
                            StyleControlsView(
                                editingViewModel: editingViewModel,
                                sliderViewModel: sliderViewModel
                            )
                        }
                        .padding(16)
                    }
                    .background(Color(.systemBackground))
                    .cornerRadius(16, corners: [.topLeft, .topRight])
                    .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: -5)
                }
            }
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
