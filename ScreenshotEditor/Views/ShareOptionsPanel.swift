//
//  ShareOptionsPanel.swift
//  ScreenshotEditor
//
//  Created by Alastair McNeill on 19/08/2025.
//

import SwiftUI

struct ShareOptionsPanel: View {
    @Binding var isPresented: Bool
    let onFacebook: () -> Void
    let onInstagram: () -> Void
    let onMoreOptions: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // Handle indicator
            PanelHandleView()
            
            // Content
            VStack(spacing: 32) {
                // Title and done button
                PanelHeaderView(title: AppStrings.UI.shareOptions) {
                    withAnimation(.easeInOut(duration: AppConstants.StylePanel.animationDuration)) {
                        isPresented = false
                    }
                }
                
                // Share options - all in one horizontal row
                HStack(spacing: 20) {
                    // Facebook
                    SocialMediaButton(
                        icon: "f.square.fill",
                        title: AppStrings.UI.facebook,
                        backgroundColor: Color(red: 0.255, green: 0.412, blue: 0.882),
                        action: onFacebook
                    )
                    
                    // Instagram
                    SocialMediaButton(
                        icon: "camera.fill",
                        title: AppStrings.UI.instagram,
                        backgroundColor: Color(red: 0.845, green: 0.318, blue: 0.588),
                        action: onInstagram
                    )
                    
                    // More options
                    SocialMediaButton(
                        icon: "ellipsis",
                        title: AppStrings.UI.moreOptions,
                        backgroundColor: Color(.systemGray4),
                        textColor: .primary,
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

/// Individual social media button with circular design
private struct SocialMediaButton: View {
    let icon: String
    let title: String
    let backgroundColor: Color
    var textColor: Color = .white
    let action: () -> Void
    
    var body: some View {
        VStack(spacing: 8) {
            Button(action: action) {
                Circle()
                    .fill(backgroundColor)
                    .frame(width: 64, height: 64)
                    .overlay(
                        Image(systemName: icon)
                            .font(.title2)
                            .fontWeight(.medium)
                            .foregroundColor(textColor == .primary ? .primary : .white)
                    )
                    .shadow(color: backgroundColor.opacity(0.3), radius: 8, x: 0, y: 4)
            }
            .buttonStyle(PlainButtonStyle())
            
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
        }
    }
}

#Preview {
    ShareOptionsPanel(
        isPresented: .constant(true),
        onFacebook: {},
        onInstagram: {},
        onMoreOptions: {}
    )
}
