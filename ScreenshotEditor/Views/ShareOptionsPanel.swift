//
//  ShareOptionsPanel.swift
//  ScreenshotEditor
//
//  Created by Alastair McNeill on 19/08/2025.
//

import SwiftUI

struct ShareOptionsPanel: View {
    @Binding var isPresented: Bool
    let onSaveToDevice: () -> Void
    let onFacebook: () -> Void
    let onInstagram: () -> Void
    let onMoreOptions: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // Handle indicator
            PanelHandleView()
            
            // Content
            VStack(spacing: 24) {
                // Title and done button
                PanelHeaderView(title: AppStrings.UI.shareOptions) {
                    withAnimation(.easeInOut(duration: AppConstants.StylePanel.animationDuration)) {
                        isPresented = false
                    }
                }
                
                // Share options
                VStack(spacing: 16) {
                    // Save to Device
                    ShareOptionButton(
                        icon: "square.and.arrow.down",
                        title: AppStrings.UI.saveToDevice,
                        backgroundColor: .accentColor,
                        foregroundColor: .white,
                        action: onSaveToDevice
                    )
                    
                    // Social media options
                    HStack(spacing: 16) {
                        // Facebook
                        ShareOptionButton(
                            icon: "f.circle.fill",
                            title: AppStrings.UI.facebook,
                            backgroundColor: Color(red: 0.255, green: 0.412, blue: 0.882),
                            foregroundColor: .white,
                            action: onFacebook
                        )
                        
                        // Instagram
                        ShareOptionButton(
                            icon: "camera.circle.fill",
                            title: AppStrings.UI.instagram,
                            backgroundColor: Color(red: 0.845, green: 0.318, blue: 0.588),
                            foregroundColor: .white,
                            action: onInstagram
                        )
                    }
                    
                    // More options
                    ShareOptionButton(
                        icon: "ellipsis.circle",
                        title: AppStrings.UI.moreOptions,
                        backgroundColor: Color(.systemGray5),
                        foregroundColor: .primary,
                        action: onMoreOptions
                    )
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 34) // Extra padding for home indicator
        }
        .background(Color(.systemBackground))
        .panelDragGesture(isPresented: $isPresented)
    }
}

/// Individual share option button
private struct ShareOptionButton: View {
    let icon: String
    let title: String
    let backgroundColor: Color
    let foregroundColor: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(foregroundColor)
                
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(foregroundColor)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(backgroundColor)
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    ShareOptionsPanel(
        isPresented: .constant(true),
        onSaveToDevice: {},
        onFacebook: {},
        onInstagram: {},
        onMoreOptions: {}
    )
}
