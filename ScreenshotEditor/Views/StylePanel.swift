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
    
    private let maxCornerRadius: CGFloat = 200
    private let maxPadding: CGFloat = 48
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background overlay that dismisses on tap
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            isPresented = false
                        }
                    }
                
                VStack {
                    Spacer()
                    
                    // Bottom Sheet
                    VStack(spacing: 0) {
                        // Handle indicator
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color.secondary.opacity(0.6))
                            .frame(width: 36, height: 6)
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
                                    withAnimation(.easeInOut(duration: 0.3)) {
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
                                    
                                    Text("\(Int(editingViewModel.parameters.cornerRadius))pt")
                                        .font(.body)
                                        .foregroundColor(.secondary)
                                }
                                
                                Slider(
                                    value: Binding(
                                        get: { editingViewModel.parameters.cornerRadius },
                                        set: { newValue in
                                            editingViewModel.updateCornerRadius(newValue)
                                        }
                                    ),
                                    in: 0...maxCornerRadius,
                                    step: 1
                                )
                                .accentColor(.accentColor)
                            }
                            
                            // Padding Control
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text(AppStrings.UI.padding)
                                        .font(.headline)
                                    
                                    Spacer()
                                    
                                    Text("\(Int(editingViewModel.parameters.padding))pt")
                                        .font(.body)
                                        .foregroundColor(.secondary)
                                }
                                
                                Slider(
                                    value: Binding(
                                        get: { editingViewModel.parameters.padding },
                                        set: { newValue in
                                            editingViewModel.updatePadding(newValue)
                                        }
                                    ),
                                    in: 0...maxPadding,
                                    step: 1
                                )
                                .accentColor(.accentColor)
                            }
                            
                            // Shadow Control (placeholder for future implementation)
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text(AppStrings.UI.shadow)
                                        .font(.headline)
                                    
                                    Spacer()
                                    
                                    Toggle("", isOn: Binding(
                                        get: { editingViewModel.parameters.shadowEnabled },
                                        set: { newValue in
                                            editingViewModel.updateShadowEnabled(newValue)
                                        }
                                    ))
                                    .labelsHidden()
                                }
                                
                                if editingViewModel.parameters.shadowEnabled {
                                    // Shadow controls will be implemented in future stories
                                    Text("Shadow controls coming soon")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                        .padding(.top, 4)
                                }
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
    @State var isPresented = true
    @StateObject var viewModel = ImageEditingViewModel()
    
    return StylePanel(
        editingViewModel: viewModel,
        isPresented: $isPresented
    )
}
