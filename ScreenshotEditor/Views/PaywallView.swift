//
//  PaywallView.swift
//  ScreenshotEditor
//
//  Created by Alastair McNeill on 12/08/2025.
//

import SwiftUI

/// A consistent paywall view shown throughout the app
struct PaywallView: View {
    @Binding var isPresented: Bool
    let onUpgrade: () -> Void
    
    @State private var selectedPlan: PricingPlan = .weekly
    @State private var freeTrialEnabled: Bool = true
    @State private var cooldownTimeRemaining: Int = 3
    @State private var timer: Timer?
    
    enum PricingPlan {
        case yearly
        case weekly
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Hero Image
                    VStack {
                        // Hero image from assets
                        Image("PaywallHero")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 200)
                            .clipped()
                        
                        // Decorative bubbles effect
                        ZStack {
                            ForEach(0..<8, id: \.self) { _ in
                                Circle()
                                    .fill(Color.blue.opacity(0.2))
                                    .frame(width: CGFloat.random(in: 8...16))
                                    .offset(
                                        x: CGFloat.random(in: -100...100),
                                        y: CGFloat.random(in: -50...50)
                                    )
                            }
                        }
                        .frame(height: 100)
                    }
                    
                    // Headline
                    Text(AppStrings.UI.unlimitedAccess)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                    
                    // Feature List
                    VStack(alignment: .leading, spacing: 16) {
                        FeatureRow(icon: "fish.fill", text: AppStrings.UI.identifyUnlimitedFish, color: .blue)
                        FeatureRow(icon: "fishing.rod", text: AppStrings.UI.unlockExpertTips, color: .blue)
                        FeatureRow(icon: "location.fill", text: AppStrings.UI.locationInsights, color: .blue)
                        FeatureRow(icon: "fork.knife", text: AppStrings.UI.cookingTips, color: .blue)
                    }
                    .padding(.horizontal)
                    
                    // Pricing Plans
                    VStack(spacing: 12) {
                        // Yearly Plan
                        PricingPlanView(
                            title: AppStrings.UI.yearlyPlan,
                            originalPrice: "£259.48",
                            currentPrice: "£24.99 per year",
                            badge: AppStrings.UI.save90Percent,
                            isSelected: selectedPlan == .yearly && !freeTrialEnabled,
                            showRadio: !freeTrialEnabled
                        ) {
                            selectedPlan = .yearly
                            freeTrialEnabled = false
                        }
                        
                        // Weekly Plan
                        PricingPlanView(
                            title: AppStrings.UI.threeDayTrial,
                            subtitle: AppStrings.UI.thenWeekly,
                            badge: AppStrings.UI.freeBadge,
                            badgeColor: .green,
                            isSelected: selectedPlan == .weekly || freeTrialEnabled,
                            showRadio: true,
                            isTrialPlan: true
                        ) {
                            selectedPlan = .weekly
                            freeTrialEnabled = true
                        }
                    }
                    .padding(.horizontal)
                    
                    // Free Trial Toggle
                    HStack {
                        Text(AppStrings.UI.freeTrialEnabled)
                            .font(.headline)
                        Spacer()
                        Toggle("", isOn: $freeTrialEnabled)
                            .toggleStyle(SwitchToggleStyle())
                    }
                    .padding(.horizontal)
                    .onChange(of: freeTrialEnabled) { enabled in
                        if enabled {
                            selectedPlan = .weekly
                        } else {
                            selectedPlan = .yearly
                        }
                    }
                    
                    // Purchase Button
                    Button(action: {
                        AnalyticsManager.shared.track(AppStrings.Analytics.paywallUpgradeClicked)
                        onUpgrade()
                    }) {
                        HStack {
                            Text(freeTrialEnabled ? AppStrings.UI.tryForFree : AppStrings.UI.continueButton)
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            Image(systemName: "chevron.right")
                                .font(.headline)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.blue)
                        .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    
                    // Bottom Links
                    HStack(spacing: 40) {
                        Button(AppStrings.UI.restore) {
                            // TODO: Implement restore purchases
                        }
                        .foregroundColor(.gray)
                        
                        Button(AppStrings.UI.termsAndPrivacy) {
                            // TODO: Show terms and privacy
                        }
                        .foregroundColor(.gray)
                    }
                    .font(.footnote)
                    .padding(.bottom, 20)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        if cooldownTimeRemaining > 0 {
                            startCooldownTimer()
                        } else {
                            dismissPaywall()
                        }
                    }) {
                        if cooldownTimeRemaining > 0 {
                            Text("\(cooldownTimeRemaining)")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(width: 30, height: 30)
                                .background(Color.gray)
                                .clipShape(Circle())
                        } else {
                            Image(systemName: "xmark")
                                .font(.headline)
                                .foregroundColor(.gray)
                        }
                    }
                    .disabled(cooldownTimeRemaining > 0)
                }
            }
        }
        .onAppear {
            AnalyticsManager.shared.track(AppStrings.Analytics.paywallShown, properties: [
                AppStrings.AnalyticsProperties.exportCount: UserDefaultsManager.shared.freeExportCount,
                AppStrings.AnalyticsProperties.exportLimitReason: "free_limit_reached"
            ])
            startCooldownTimer()
        }
        .onDisappear {
            timer?.invalidate()
        }
    }
    
    private func startCooldownTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if cooldownTimeRemaining > 0 {
                cooldownTimeRemaining -= 1
            } else {
                timer?.invalidate()
            }
        }
    }
    
    private func dismissPaywall() {
        AnalyticsManager.shared.track(AppStrings.Analytics.paywallDismissed)
        isPresented = false
    }
}

// MARK: - Supporting Views

private struct FeatureRow: View {
    let icon: String
    let text: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
                .frame(width: 24)
            
            Text(text)
                .font(.body)
                .foregroundColor(.primary)
            
            Spacer()
        }
    }
}

private struct PricingPlanView: View {
    let title: String
    var subtitle: String? = nil
    var originalPrice: String? = nil
    var currentPrice: String? = nil
    let badge: String
    var badgeColor: Color = .red
    let isSelected: Bool
    let showRadio: Bool
    var isTrialPlan: Bool = false
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    if let originalPrice = originalPrice {
                        Text(originalPrice)
                            .font(.caption)
                            .foregroundColor(.gray)
                            .strikethrough()
                    }
                    
                    if let currentPrice = currentPrice {
                        Text(currentPrice)
                            .font(.subheadline)
                            .foregroundColor(.primary)
                    }
                    
                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(.subheadline)
                            .foregroundColor(.primary)
                    }
                }
                
                Spacer()
                
                HStack(spacing: 12) {
                    // Badge
                    Text(badge)
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(badgeColor)
                        .cornerRadius(6)
                    
                    // Radio button
                    if showRadio {
                        Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                            .font(.title2)
                            .foregroundColor(isSelected ? .blue : .gray)
                    }
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity) // Ensure button expands to full width
            .contentShape(Rectangle()) // Make entire area tappable
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.blue : Color.gray.opacity(0.3), lineWidth: isSelected ? 2 : 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    PaywallView(isPresented: .constant(true)) {
        print("Upgrade tapped")
    }
}
