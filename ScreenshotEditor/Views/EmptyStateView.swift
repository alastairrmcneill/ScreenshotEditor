//
//  EmptyStateView.swift
//  ScreenshotEditor
//
//  Created by Alastair McNeill on 22/08/2025.
//

import SwiftUI
import PhotosUI

struct EmptyStateView: View {
    @Binding var selectedPhotoItem: PhotosPickerItem?
    @Binding var hasReturnedFromBack: Bool
    @State private var showingPaywall = false
    
    var body: some View {
        VStack(spacing: AppConstants.Layout.extraLargePadding) {
            // Custom Device Icon
            CustomDeviceIcon()
                .frame(width: AppConstants.Layout.emptyStateIconSize * 1.5, height: AppConstants.Layout.emptyStateIconSize * 2.2)
                .foregroundColor(.secondary)
                .padding(.bottom, 30)
            
            // Title and subtitle - show different text if user came from back button
            VStack(spacing: AppConstants.Layout.emptyStateTitleSpacing) {

                Text("Get started editing")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)

                Text("Import a image to crop, style and share beautiful new screenshots")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 30)

            // Import Button
            PhotosPicker(
                selection: $selectedPhotoItem,
                matching: .screenshots,
                photoLibrary: .shared()
            ) {
                Text(AppStrings.UI.importPhoto)
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, AppConstants.Layout.standardPadding)
                    .background(Color.buttonBackground)
                    .cornerRadius(AppConstants.Layout.largeCornerRadius)
            }
            .onChange(of: selectedPhotoItem) { _, _ in
                hasReturnedFromBack = false
            }
            .padding(.horizontal, AppConstants.Layout.buttonHorizontalPadding)

            // Go Premium Button
            Button(action: {
                showingPaywall = true
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "crown.fill")
                        .font(.headline)
                    Text("Go \(AppStrings.UI.premium)")
                        .font(.headline)
                }
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, AppConstants.Layout.standardPadding)
                .overlay(
                    RoundedRectangle(cornerRadius: AppConstants.Layout.largeCornerRadius)
                        .stroke(.primary, lineWidth: 1)
                )
            }
            .padding(.horizontal, AppConstants.Layout.buttonHorizontalPadding)

            
        }
        .sheet(isPresented: $showingPaywall) {
            PaywallView(
                isPresented: $showingPaywall,
                placement: AppStrings.AnalyticsProperties.featureLock,
                entryPoint: "empty_state_go_premium"
            ) {
                // Handle subscription success
                UserDefaultsManager.shared.setSubscribed(true)
                showingPaywall = false
            }
        }
    }
}

struct CustomDeviceIcon: View {
    var body: some View {
        ZStack {
            // Soft glow effect behind the device
            RoundedRectangle(cornerRadius: 22)
                .fill(Color.blue.opacity(0.15))
                .blur(radius: 25)
                .frame(width: 170, height: 250)
            
            // Secondary glow layer for more depth
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.blue.opacity(0.08))
                .blur(radius: 15)
                .frame(width: 140, height: 230)
            
            // Device outline (rounded rectangle representing phone/device)
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.editingButtonBackground)
                .stroke(Color.secondary, lineWidth: 3)
                .frame(width: 110, height: 170)
            
            // Dashed border screenshot placeholder inside
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.secondary, style: StrokeStyle(
                    lineWidth: 2.2,
                    lineCap: .round,
                    dash: [6, 6]
                ))
                .frame(width: 80, height: 80)
            
            // Small photo icon in the center
            Image(systemName: "photo")
                .font(.system(size: 40, weight: .light))
                .foregroundColor(.secondary.opacity(0.6))
        }
    }
}

#Preview {
    EmptyStateView(
        selectedPhotoItem: .constant(nil),
        hasReturnedFromBack: .constant(false)
    )
    .background(Color(.systemBackground))
}
