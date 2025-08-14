//
//  PaywallView.swift
//  ScreenshotEditor
//
//  Created by Alastair McNeill on 12/08/2025.
//

import SwiftUI
import RevenueCat

/// A consistent paywall view shown throughout the app
struct PaywallView: View {
    @Binding var isPresented: Bool
    let onUpgrade: () -> Void
    
    @StateObject private var subscriptionManager = SubscriptionManager.shared
    @State private var selectedPlan: PricingPlan = .weekly
    @State private var freeTrialEnabled: Bool = true
    @State private var cooldownTimeRemaining: Int = 3
    @State private var timer: Timer?
    @State private var isPurchasing: Bool = false
    @State private var showCloseButton: Bool = false
    @State private var progress: CGFloat = 0.0
    
    private let allowCloseAfter: CGFloat = 3.0 // time in seconds until close is allowed
    
    enum PricingPlan {
        case yearly
        case weekly
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header with Animated App Icon and Exit Button
                    HStack {
                        Spacer()
                        
                        AnimatedAppIconView()
                            .frame(width: 200, height: 200)
                        
                        Spacer()
                        
                        VStack {
                            if !showCloseButton {
                                Circle()
                                    .trim(from: 0.0, to: progress)
                                    .stroke(style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))
                                    .foregroundColor(.gray)
                                    .opacity(0.3 + 0.3 * self.progress)
                                    .rotationEffect(Angle(degrees: -90))
                                    .frame(width: 30, height: 30)
                            } else {
                                Button(action: {
                                    dismissPaywall()
                                }) {
                                    Image(systemName: "xmark")
                                        .font(.headline)
                                        .foregroundColor(.gray)
                                        .frame(width: 30, height: 30)
                                        .background(Color.gray.opacity(0.1))
                                        .clipShape(Circle())
                                }
                            }
                            Spacer()
                        }
                        .frame(width: 30)
                    }
                    .padding(.horizontal)
                    
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
                        if let yearlyProduct = subscriptionManager.yearlyProduct {
                            PricingPlanView(
                                title: AppStrings.UI.yearlyPlan,
                                originalPrice: calculateOriginalYearlyPrice(yearlyProduct),
                                currentPrice: "\(yearlyProduct.storeProduct.localizedPriceString) per year",
                                badge: calculateYearlySavings(yearlyProduct),
                                isSelected: selectedPlan == .yearly && !freeTrialEnabled
                            ) {
                                selectedPlan = .yearly
                                freeTrialEnabled = false
                            }
                        } else {
                            // Fallback to loading state while fetching
                            PricingPlanView(
                                title: AppStrings.UI.yearlyPlan,
                                originalPrice: nil,
                                currentPrice: "Loading pricing...",
                                badge: "Best Value",
                                isSelected: selectedPlan == .yearly && !freeTrialEnabled
                            ) {
                                selectedPlan = .yearly
                                freeTrialEnabled = false
                            }
                        }
                        
                        // Weekly Plan with Free Trial
                        if let weeklyProduct = subscriptionManager.weeklyProduct {
                            let hasFreeTrial = weeklyProduct.storeProduct.introductoryDiscount != nil
                            let trialText = hasFreeTrial ? formatTrialPeriod(weeklyProduct.storeProduct.introductoryDiscount!) : nil
                            
                            PricingPlanView(
                                title: hasFreeTrial ? (trialText ?? "3-Day Free Trial") : "Weekly Plan",
                                subtitle: hasFreeTrial ? "then \(weeklyProduct.storeProduct.localizedPriceString) weekly" : "\(weeklyProduct.storeProduct.localizedPriceString) weekly",
                                badge: hasFreeTrial ? "FREE" : "Weekly",
                                badgeColor: hasFreeTrial ? .green : .blue,
                                isSelected: selectedPlan == .weekly || (freeTrialEnabled && hasFreeTrial),
                                isTrialPlan: hasFreeTrial
                            ) {
                                selectedPlan = .weekly
                                if hasFreeTrial {
                                    freeTrialEnabled = true
                                }
                            }
                        } else {
                            // Fallback to loading state while fetching
                            PricingPlanView(
                                title: "Free Trial",
                                subtitle: "Loading pricing...",
                                badge: "FREE",
                                badgeColor: .green,
                                isSelected: selectedPlan == .weekly || freeTrialEnabled,
                                isTrialPlan: true
                            ) {
                                selectedPlan = .weekly
                                freeTrialEnabled = true
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    // Free Trial Toggle (only show if weekly product has free trial)
                    if let weeklyProduct = subscriptionManager.weeklyProduct,
                       weeklyProduct.storeProduct.introductoryDiscount != nil {
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
                    }
                    
                    // Purchase Button
                    Button(action: {
                        handlePurchaseButtonTap()
                    }) {
                        HStack {
                            if isPurchasing {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.8)
                                Text("Processing...")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                            } else {
                                Text(getPurchaseButtonText())
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                
                                Image(systemName: "chevron.right")
                                    .font(.headline)
                            }
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(isPurchasing ? Color.gray : Color.blue)
                        .cornerRadius(12)
                    }
                    .disabled(isPurchasing)
                    .padding(.horizontal)
                    
                    // Bottom Links
                    HStack(spacing: 40) {
                        Button(AppStrings.UI.restore) {
                            handleRestorePurchases()
                        }
                        .foregroundColor(.gray)
                        .disabled(isPurchasing)
                        
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
        }
        .onAppear {
            AnalyticsManager.shared.track(AppStrings.Analytics.paywallShown, properties: [
                AppStrings.AnalyticsProperties.exportCount: UserDefaultsManager.shared.freeExportCount,
                AppStrings.AnalyticsProperties.exportLimitReason: "free_limit_reached"
            ])
            
            // Fetch offerings when paywall appears
            subscriptionManager.fetchOfferings()
            
            // Start the progress animation
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.linear(duration: allowCloseAfter)) {
                    self.progress = 1.0
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + allowCloseAfter) {
                    withAnimation {
                        showCloseButton = true
                    }
                }
            }
        }
        .onReceive(subscriptionManager.$weeklyProduct) { weeklyProduct in
            // Update free trial state when weekly product loads
            if let weeklyProduct = weeklyProduct,
               weeklyProduct.storeProduct.introductoryDiscount != nil {
                freeTrialEnabled = true
                selectedPlan = .weekly
            }
        }
        .onDisappear {
            // Clean up if needed
        }
    }
    
    private func dismissPaywall() {
        AnalyticsManager.shared.track(AppStrings.Analytics.paywallDismissed)
        isPresented = false
    }
    
    // MARK: - Purchase Handling
    
    private func handlePurchaseButtonTap() {
        AnalyticsManager.shared.track(AppStrings.Analytics.paywallUpgradeClicked)
        
        guard !isPurchasing else { return }
        
        let selectedPackage: Package?
        if selectedPlan == .yearly {
            selectedPackage = subscriptionManager.yearlyProduct
        } else {
            selectedPackage = subscriptionManager.weeklyProduct
        }
        
        guard let package = selectedPackage else {
            print("No package available for selected plan")
            // Fallback to callback for now
            onUpgrade()
            return
        }
        
        isPurchasing = true
        
        subscriptionManager.purchase(package: package) { success, error in
            isPurchasing = false
            
            if success {
                print("Purchase successful!")
                onUpgrade()
                isPresented = false
            } else if let error = error {
                print("Purchase failed: \(error.localizedDescription)")
                // TODO: Show error alert to user
            }
        }
    }
    
    private func handleRestorePurchases() {
        guard !isPurchasing else { return }
        
        isPurchasing = true
        
        subscriptionManager.restorePurchases { success, error in
            isPurchasing = false
            
            if success {
                print("Restore successful!")
                if subscriptionManager.isSubscribed {
                    onUpgrade()
                    isPresented = false
                }
            } else if let error = error {
                print("Restore failed: \(error.localizedDescription)")
                // TODO: Show error alert to user
            }
        }
    }
    
    // MARK: - Price Calculation Helpers
    
    private func calculateOriginalYearlyPrice(_ yearlyProduct: Package) -> String? {
        guard let weeklyProduct = subscriptionManager.weeklyProduct else { return nil }
        
        // Calculate what yearly would cost if paying weekly (52 weeks)
        let weeklyPrice = weeklyProduct.storeProduct.price
        let yearlyAtWeeklyRate = weeklyPrice * Decimal(52)
        
        // Format using the yearly product's formatter for consistency
        let formatter = yearlyProduct.storeProduct.priceFormatter ?? NumberFormatter()
        return formatter.string(from: yearlyAtWeeklyRate as NSDecimalNumber)
    }
    
    private func calculateYearlySavings(_ yearlyProduct: Package) -> String {
        guard let weeklyProduct = subscriptionManager.weeklyProduct else { 
            return AppStrings.UI.save90Percent 
        }
        
        let weeklyPrice = Double(truncating: weeklyProduct.storeProduct.price as NSNumber)
        let yearlyPrice = Double(truncating: yearlyProduct.storeProduct.price as NSNumber)
        let yearlyAtWeeklyRate = weeklyPrice * 52
        
        let savings = ((yearlyAtWeeklyRate - yearlyPrice) / yearlyAtWeeklyRate) * 100
        let roundedSavings = Int(savings.rounded())
        
        return "Save \(roundedSavings)%"
    }
    
    /// Get the appropriate purchase button text based on selected plan and trial status
    private func getPurchaseButtonText() -> String {
        if selectedPlan == .weekly,
           let weeklyProduct = subscriptionManager.weeklyProduct,
           weeklyProduct.storeProduct.introductoryDiscount != nil,
           freeTrialEnabled {
            return AppStrings.UI.tryForFree
        } else {
            return AppStrings.UI.continueButton
        }
    }
    
    /// Format the trial period from IntroductoryDiscount
    private func formatTrialPeriod(_ introDiscount: StoreProductDiscount) -> String? {
        let period = introDiscount.subscriptionPeriod
        let numberOfUnits = period.value
        
        switch period.unit {
        case .day:
            return "\(numberOfUnits)-Day Free Trial"
        case .week:
            return "\(numberOfUnits)-Week Free Trial"
        case .month:
            return "\(numberOfUnits)-Month Free Trial"
        case .year:
            return "\(numberOfUnits)-Year Free Trial"
        @unknown default:
            return "Free Trial"
        }
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
                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                        .font(.title2)
                        .foregroundColor(isSelected ? .blue : .gray)
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

// MARK: - Animated App Icon View

private struct AnimatedAppIconView: View {
    @State private var isAnimating = false
    @State private var rotationAngle: Double = 0
    @State private var yOffset: CGFloat = 0
    @State private var scale: CGFloat = 1.0
    
    var body: some View {
        Image("AppIconImage")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 200, height: 200)
            .clipShape(RoundedRectangle(cornerRadius: 44.8)) // iOS app icon corner radius
            .scaleEffect(scale)
            .rotationEffect(.degrees(rotationAngle))
            .offset(y: yOffset)
            .onAppear {
                startAnimation()
            }
    }
    
    private func startAnimation() {
        // Create a repeating animation sequence
        withAnimation(.easeInOut(duration: 0.25)) {
            // Jump up (smaller movement)
            yOffset = -20
            scale = 1.05
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            withAnimation(.easeInOut(duration: 0.15)) {
                // Rotate left (smaller rotation)
                rotationAngle = -10
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                withAnimation(.easeInOut(duration: 0.3)) {
                    // Rotate right (smaller rotation)
                    rotationAngle = 10
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    withAnimation(.easeInOut(duration: 0.15)) {
                        // Rotate back to center
                        rotationAngle = 0
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                        withAnimation(.easeOut(duration: 0.25)) {
                            // Land back down
                            yOffset = 0
                            scale = 1.0
                        }
                        
                        // Pause and repeat (longer pause)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                            startAnimation()
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    PaywallView(isPresented: .constant(true)) {
        print("Upgrade tapped")
    }
}
