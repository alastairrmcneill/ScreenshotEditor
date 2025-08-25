//
//  StandardBottomSheet.swift
//  ScreenshotEditor
//
//  Created by Alastair McNeill on 25/08/2025.
//

import SwiftUI

/// Standardized bottom sheet component with consistent styling and features
struct StandardBottomSheet<Content: View>: View {
    @Binding var isPresented: Bool
    let content: () -> Content
    
    init(isPresented: Binding<Bool>, @ViewBuilder content: @escaping () -> Content) {
        self._isPresented = isPresented
        self.content = content
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Handle indicator
            PanelHandleView()
            
            // Content with consistent padding
            VStack(spacing: 24) {
                content()
            }
            .padding(.horizontal, AppConstants.Layout.extraLargePadding)
            .padding(.bottom, AppConstants.Layout.hugePadding + 2) // Extra padding for home indicator (34)
        }
        .background(Color(.systemBackground))
        .cornerRadius(AppConstants.Layout.largeCornerRadius, corners: [.topLeft, .topRight])
        .panelDragGesture(isPresented: $isPresented)
    }
}

/// Standardized modal bottom sheet with background overlay
struct StandardModalBottomSheet<Content: View>: View {
    @Binding var isPresented: Bool
    let content: () -> Content
    
    init(isPresented: Binding<Bool>, @ViewBuilder content: @escaping () -> Content) {
        self._isPresented = isPresented
        self.content = content
    }
    
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
                        
                        // Content with consistent padding
                        VStack(spacing: 24) {
                            content()
                        }
                        .padding(.horizontal, AppConstants.Layout.extraLargePadding)
                        .padding(.bottom, AppConstants.Layout.hugePadding + 2) // Extra padding for home indicator (34)
                    }
                    .background(Color(.systemBackground))
                    .cornerRadius(AppConstants.Layout.largeCornerRadius, corners: [.topLeft, .topRight])
                    .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: -5)
                }
            }
        }
    }
}

// MARK: - Corner Radius Extension
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
    
    return StandardBottomSheet(isPresented: $isPresented) {
        VStack(spacing: 16) {
            Text("Sample Content")
                .font(.headline)
            
            Button("Sample Button") {
                // Sample action
            }
            .buttonStyle(.borderedProminent)
        }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color(.systemGray6))
}
