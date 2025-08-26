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
    @StateObject private var viewModel = PaywallViewModel()
    @Environment(\.openURL) private var openURL
    
    @State private var cooldownTimeRemaining: Int = 3
    @State private var timer: Timer?
    @State private var showCloseButton: Bool = false
    @State private var progress: CGFloat = 0.0
    @State private var showErrorAlert: Bool = false
    @State private var errorMessage: String = ""
    
    private let allowCloseAfter: CGFloat = 3.0 // time in seconds until close is allowed
    
    // Analytics configuration
    let placement: String
    let entryPoint: String
    
    init(isPresented: Binding<Bool>, placement: String = AppStrings.AnalyticsProperties.featureLock, entryPoint: String = "unknown", onUpgrade: @escaping () -> Void) {
        self._isPresented = isPresented
        self.onUpgrade = onUpgrade
        self.placement = placement
        self.entryPoint = entryPoint
    }
    
    var body: some View {
        ZStack {
            Color.clear
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header with Animated App Icon, Title, and Exit Button - Fixed Height
                ZStack(alignment: .top) {
                    // Centered Animated App Icon and Title
                    VStack(spacing: 16) {
                        AnimatedAppIconView()
                            .frame(width: 150, height: 150)
                            .padding(.top, 20)
                        
                        // Headline directly under icon
                        Text(AppStrings.UI.unlimitedAccess)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                    }
                    
                    // Exit Button in Top-Right Corner
                    HStack {
                        Spacer()
                        
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
                                Image(systemName: AppStrings.SystemImages.xmark)
                                    .font(.headline)
                                    .foregroundColor(.gray)
                                    .frame(width: 30, height: 30)
                                    .background(Color.gray.opacity(0.1))
                                    .clipShape(Circle())
                            }
                        }
                    }
                    .padding(.top, 20)
                    .padding(.trailing, 20)
                }
                .frame(height: 240) // Fixed height for header section
                
                // Feature List
               VStack(alignment: .leading, spacing: 15) {
                   FeatureRow(icon: "photo.fill", text: AppStrings.UI.unlimitedExportsFeature)
                   FeatureRow(icon: "square.and.arrow.up.fill", text: AppStrings.UI.highQualityExportsFeature)
                   FeatureRow(icon: "checkmark.seal.fill", text: AppStrings.UI.noWatermarkFeature)
                   FeatureRow(icon: "eye.slash.fill", text: AppStrings.UI.noAnnoyingAdsFeature)
               }
               .padding(.horizontal, 32)
               .padding(.top, 32)
               .padding(.bottom, 16)

                // Flexible spacer to push bottom content down
                Spacer()
                
                // Bottom section - wrapped to keep content grouped at bottom
                VStack(spacing: 0) {
                    // Pricing Plans
                    VStack(spacing: 12) {
                    // Yearly Plan
                    if let yearlyProduct = subscriptionManager.yearlyProduct {
                        PricingPlanView(
                            title: AppStrings.UI.yearlyPlan,
                            subtitle: "\(yearlyProduct.storeProduct.localizedPriceString) per year",
                            originalPrice: calculateOriginalYearlyPrice(yearlyProduct),
                            badge: calculateYearlySavings(yearlyProduct),
                            badgeColor: Color.brandGradient,
                            isSelected: viewModel.selectedPlan == .yearly && !viewModel.freeTrialEnabled
                        ) {
                            viewModel.selectPlan(.yearly)
                            viewModel.freeTrialEnabled = false
                        }
                    } else {
                        // Fallback to loading state while fetching
                        PricingPlanView(
                            title: AppStrings.UI.yearlyPlan,
                            subtitle: AppStrings.UI.loadingPricing,
                            badge: AppStrings.UI.bestValue,
                            badgeColor: Color.brandGradient,
                            isSelected: viewModel.selectedPlan == .yearly && !viewModel.freeTrialEnabled
                        ) {
                            viewModel.selectPlan(.yearly)
                            viewModel.freeTrialEnabled = false
                        }
                    }
                    
                    // Weekly Plan with Free Trial
                    if let weeklyProduct = subscriptionManager.weeklyProduct {
                        let hasFreeTrial = weeklyProduct.storeProduct.introductoryDiscount != nil
                        let trialText = hasFreeTrial ? formatTrialPeriod(weeklyProduct.storeProduct.introductoryDiscount!) : nil
                        
                        PricingPlanView(
                            title: hasFreeTrial ? (trialText ?? AppStrings.UI.threeDayFreeTrial) : AppStrings.UI.weeklyPlan,
                            subtitle: hasFreeTrial ? "then \(weeklyProduct.storeProduct.localizedPriceString) weekly" : "\(weeklyProduct.storeProduct.localizedPriceString) weekly",
                            badge: hasFreeTrial ? AppStrings.UI.freeBadge : AppStrings.UI.weekly,
                            badgeColor: hasFreeTrial ? .green : .customAccent,
                            isSelected: viewModel.selectedPlan == .weekly || (viewModel.freeTrialEnabled && hasFreeTrial),
                            isTrialPlan: hasFreeTrial
                        ) {
                            viewModel.selectPlan(.weekly)
                            if hasFreeTrial {
                                viewModel.freeTrialEnabled = true
                            }
                        }
                    } else {
                        // Fallback to loading state while fetching
                        PricingPlanView(
                            title: AppStrings.UI.freeTrial,
                            subtitle: AppStrings.UI.loadingPricing,
                            badge: AppStrings.UI.freeBadge,
                            badgeColor: .green,
                            isSelected: viewModel.selectedPlan == .weekly || viewModel.freeTrialEnabled,
                            isTrialPlan: true
                        ) {
                            viewModel.selectPlan(.weekly)
                            viewModel.freeTrialEnabled = true
                        }
                    }
                }
                .padding(.horizontal)
                
                HStack {
                    Text(AppStrings.UI.freeTrialEnabled)
                        .font(.headline)
                    Spacer()
                    Toggle("", isOn: $viewModel.freeTrialEnabled)
                        .toggleStyle(
                            GradientSwitchToggleStyle(
                                onGradient: Color.brandGradient,
                                offColor: .gray.opacity(0.30),
                                knobColor: .white,
                                trackHeight: 31
                            )
                        )
                        .disabled(viewModel.isPurchasing) // optional, matches your button state
                }
                .padding(.horizontal)
                .padding(.top, 12)
                .onChange(of: viewModel.freeTrialEnabled) { enabled in
                    if enabled {
                        viewModel.selectPlan(.weekly)
                    } else {
                        viewModel.selectPlan(.yearly)
                    }
                }
                
                
                
                // Purchase Button
                Button(action: {
                    viewModel.handleUpgrade {
                        onUpgrade()
                    }
                }) {
                    HStack {
                        if viewModel.isPurchasing {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(0.8)
                            Text(AppStrings.UI.processing)
                                .font(.headline)
                                .fontWeight(.semibold)
                        } else {
                            Text(viewModel.getButtonText())
                                .font(.headline)
                                .fontWeight(.semibold)
                            Image(systemName: "chevron.right")
                                .font(.headline)
                        }
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background {
                        if viewModel.isPurchasing {
                            Color.gray
                        } else {
                            Color.brandGradient
                        }
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .animation(.easeInOut(duration: 0.2), value: viewModel.isPurchasing)
                }
                .disabled(viewModel.isPurchasing)
                .padding(.horizontal)
                .padding(.top, 16)

                
                // Bottom Links - Right at the bottom of safe area
                HStack(spacing: 40) {
                    Button(AppStrings.UI.restore) {
                        viewModel.handleRestorePurchases {
                            onUpgrade()
                        }
                    }
                    .foregroundColor(.gray)
                    .disabled(viewModel.isPurchasing)
                    
                    Button(AppStrings.UI.terms) {
                        if let url = URL(string: "https://vanta-app.carrd.co/#terms") {
                            openURL(url)
                        }
                    }
                    .foregroundColor(.gray)
                    
                    Button(AppStrings.UI.privacy) {
                        if let url = URL(string: "https://vanta-app.carrd.co/#privacy") {
                            openURL(url)
                        }
                    }
                    .foregroundColor(.gray)
                }
                .font(.footnote)
                .padding(.top, 12)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .onAppear {
            // Configure viewModel with analytics context
            viewModel.configurePaywall(placement: placement, entryPoint: entryPoint)
            viewModel.onAppear()
            
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
                viewModel.freeTrialEnabled = true
                viewModel.selectedPlan = .weekly
            }
        }
        .onDisappear {
            // Clean up if needed
        }
        .alert(AppStrings.UI.purchaseError, isPresented: $viewModel.showErrorAlert) {
            Button(AppStrings.UI.ok) {
                viewModel.showErrorAlert = false
            }
        } message: {
            Text(viewModel.errorMessage)
        }
    }
    
    private func dismissPaywall() {
        viewModel.dismissPaywall()
        isPresented = false
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
            return AppStrings.UI.freeTrial
        }
    }
    
}

// MARK: - Supporting Views

private struct FeatureRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Rectangle()
                .fill(Color.brandGradient)
                .frame(width: 20, height: 20)
                .mask(
                    Image(systemName: icon)
                        .resizable()
                        .scaledToFit()
                )
            
            Text(text)
                .font(.body)
                .foregroundColor(.primary)
            
            Spacer()
        }
    }
}

private struct PricingPlanView<S: ShapeStyle>: View {
    let title: String
    var subtitle: String? = nil
    var originalPrice: String? = nil
    let badge: String
    var badgeColor: S
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
                    
                    HStack {
                        if let originalPrice = originalPrice {
                            Text(originalPrice)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .strikethrough()
                        }
                        if let subtitle = subtitle {
                            Text(subtitle)
                                .font(.subheadline)
                                .foregroundColor(.primary)
                        }
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

                    // Radio Button
                    GradientSymbol(
                        systemName: isSelected
                            ? AppStrings.SystemImages.checkmarkCircleFill
                            : AppStrings.SystemImages.circle,
                        isSelected: isSelected,
                        size: 24
                    )
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
            .overlay {
                let shape = RoundedRectangle(cornerRadius: 12)
                ZStack {
                    shape
                        .stroke(Color.gray.opacity(0.3), lineWidth: isSelected ? 0 : 1)
                    shape
                        .stroke(Color.brandGradient, lineWidth: isSelected ? 3 : 0)
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct GradientSwitchToggleStyle: ToggleStyle {
    // Pass just the colors; we build the gradient inside.
    var onGradient: LinearGradient = Color.brandGradient
    var offColor: Color = .gray.opacity(0.30)
    var knobColor: Color = .white
    var trackHeight: CGFloat = 31   // ~ native UISwitch height

    func makeBody(configuration: ToggleStyle.Configuration) -> some View {
        SwitchBody(configuration: configuration,
                   onGradient: onGradient,
                   offColor: offColor,
                   knobColor: knobColor,
                   trackHeight: trackHeight)
    }

    private struct SwitchBody: View {
        @Environment(\.isEnabled) private var isEnabled

        let configuration: ToggleStyle.Configuration
        let onGradient: LinearGradient
        let offColor: Color
        let knobColor: Color
        let trackHeight: CGFloat

        var body: some View {
            let trackWidth = trackHeight * 1.65
            let knobSize = trackHeight - 6

            Button {
                withAnimation(.spring(response: 0.22, dampingFraction: 0.85)) {
                    configuration.isOn.toggle()
                }
            } label: {
                ZStack(alignment: configuration.isOn ? .trailing : .leading) {
                    // OFF track
                    Capsule()
                        .fill(offColor)

                    // ON (gradient) track
                    Capsule()
                        .fill(onGradient)
                        .opacity(configuration.isOn ? 1 : 0)

                    // Knob
                    Circle()
                        .fill(knobColor)
                        .frame(width: knobSize, height: knobSize)
                        .shadow(color: .black.opacity(0.12), radius: 1, x: 0, y: 1)
                        .padding(3)
                }
                .frame(width: trackWidth, height: trackHeight)
                .opacity(isEnabled ? 1 : 0.5)
            }
            .buttonStyle(.plain)
            .accessibilityAddTraits(.isButton)
        }
    }
}

private struct GradientSymbol: View {
    let systemName: String
    let isSelected: Bool
    var size: CGFloat = 24

    var body: some View {
        // Use foregroundStyle so it works on iOS 15+
        let base = Image(systemName: systemName)
            .resizable()
            .scaledToFit()

        Group {
            if isSelected {
                base.foregroundStyle(Color.brandGradient)
            } else {
                base.foregroundStyle(Color.gray.opacity(0.3))
            }
        }
        .frame(width: size, height: size)
    }
}

// MARK: - Animated App Icon View

private struct AnimatedAppIconView: View {
    @State private var isAnimating = false
    @State private var rotationAngle: Double = 0
    @State private var yOffset: CGFloat = 0
    @State private var scale: CGFloat = 1.0
    
    var body: some View {
        Image(AppStrings.AssetImages.appIconImage)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 130, height: 130)
            .clipShape(RoundedRectangle(cornerRadius: 35)) // iOS app icon corner radius
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
    PaywallView(
        isPresented: .constant(true),
        placement: AppStrings.AnalyticsProperties.featureLock,
        entryPoint: "preview"
    ) {
        print(AppStrings.UI.upgradeTapped)
    }
}
