//
//  PaywallView.swift
//  ScreenshotEditor
//
//  Created by Alastair McNeill on 12/08/2025.
//

import SwiftUI

/// A simple paywall view that shows when users reach their free export limit
struct PaywallView: View {
    @Binding var isPresented: Bool
    let onUpgrade: () -> Void
    
    var body: some View {
        ZStack {
            // Background overlay
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    dismissPaywall()
                }
            
            // Paywall content
            VStack(spacing: AppConstants.Layout.largePadding) {
                // Header
                VStack(spacing: AppConstants.Layout.standardPadding) {
                    Image(systemName: "crown.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.yellow)
                    
                    Text(AppStrings.UI.exportLimitReached)
                        .font(.title2)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                    
                    Text(AppStrings.UI.exportLimitMessage)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                
                // Premium features
                VStack(alignment: .leading, spacing: AppConstants.Layout.standardPadding) {
                    Text(AppStrings.UI.premiumFeatures)
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text(AppStrings.UI.unlimitedExports)
                        .font(.body)
                    
                    Text(AppStrings.UI.noWatermark)
                        .font(.body)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(AppConstants.Layout.standardPadding)
                .background(Color(.systemGray6))
                .cornerRadius(AppConstants.Layout.cornerRadius)
                
                // Action buttons
                VStack(spacing: AppConstants.Layout.standardPadding) {
                    Button(action: {
                        AnalyticsManager.shared.track(AppStrings.Analytics.paywallUpgradeClicked)
                        onUpgrade()
                    }) {
                        Text(AppStrings.UI.getUnlimitedExports)
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, AppConstants.Layout.standardPadding)
                            .background(Color.accentColor)
                            .cornerRadius(AppConstants.Layout.cornerRadius)
                    }
                    
                    Button(AppStrings.UI.restorePurchases) {
                        // TODO: Implement restore purchases
                        // For now, just dismiss the paywall
                        dismissPaywall()
                    }
                    .font(.callout)
                    .foregroundColor(.accentColor)
                    
                    Button(AppStrings.UI.continueFree) {
                        dismissPaywall()
                    }
                    .font(.callout)
                    .foregroundColor(.secondary)
                }
            }
            .padding(AppConstants.Layout.largePadding)
            .background(Color(.systemBackground))
            .cornerRadius(AppConstants.Layout.largeCornerRadius)
            .padding(AppConstants.Layout.largePadding)
        }
        .onAppear {
            AnalyticsManager.shared.track(AppStrings.Analytics.paywallShown, properties: [
                AppStrings.AnalyticsProperties.exportCount: UserDefaultsManager.shared.freeExportCount,
                AppStrings.AnalyticsProperties.exportLimitReason: "free_limit_reached"
            ])
        }
    }
    
    private func dismissPaywall() {
        AnalyticsManager.shared.track(AppStrings.Analytics.paywallDismissed)
        isPresented = false
    }
}

#Preview {
    PaywallView(isPresented: .constant(true)) {
        print("Upgrade tapped")
    }
}
