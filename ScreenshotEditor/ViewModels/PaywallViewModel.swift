//
//  PaywallViewModel.swift
//  ScreenshotEditor
//
//  Created by Alastair McNeill on 15/08/2025.
//

import Foundation
import RevenueCat
import SwiftUI

/// ViewModel for managing paywall state and purchase interactions
class PaywallViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var selectedPlan: PricingPlan = .weekly
    @Published var freeTrialEnabled: Bool = true
    @Published var cooldownTimeRemaining: Int = 3
    @Published var isPurchasing: Bool = false
    @Published var showCloseButton: Bool = false
    @Published var progress: CGFloat = 0.0
    @Published var showErrorAlert: Bool = false
    @Published var errorMessage: String = ""
    
    // MARK: - Private Properties
    private let subscriptionManager = SubscriptionManager.shared
    private var timer: Timer?
    private let allowCloseAfter: CGFloat = 3.0 // time in seconds until close is allowed
    
    // EPIC 12 - Paywall Analytics Properties
    private var paywallSessionId: String = UUID().uuidString
    private var placement: String = AppStrings.AnalyticsProperties.featureLock
    private var entryPoint: String = "unknown"
    private var selectedProductId: String?
    
    // MARK: - Types
    enum PricingPlan {
        case yearly
        case weekly
    }
    
    // MARK: - Computed Properties
    var yearlyProduct: Package? {
        subscriptionManager.yearlyProduct
    }
    
    var weeklyProduct: Package? {
        subscriptionManager.weeklyProduct
    }
    
    // MARK: - Initialization
    init() {
        // ViewModel is ready for use immediately
    }
    
    // MARK: - Configuration Methods
    
    /// Configure paywall analytics context
    func configurePaywall(placement: String, entryPoint: String) {
        self.paywallSessionId = UUID().uuidString
        self.placement = placement
        self.entryPoint = entryPoint
    }
    
    // MARK: - Public Methods
    
    /// Called when paywall appears
    func onAppear() {
        trackPaywallShown()
        subscriptionManager.fetchOfferings()
        
        // Update free trial state when weekly product loads
        if let weeklyProduct = weeklyProduct,
           weeklyProduct.storeProduct.introductoryDiscount != nil {
            freeTrialEnabled = true
            selectedPlan = .weekly
        }
    }
    
    /// Called when user selects a pricing plan
    func selectPlan(_ plan: PricingPlan) {
        selectedPlan = plan
        
        // Track option selection
        let productId = plan == .weekly ? weeklyProduct?.identifier : yearlyProduct?.identifier
        selectedProductId = productId
        
        AnalyticsManager.shared.track(AppStrings.Analytics.paywallOptionSelected, properties: [
            AppStrings.AnalyticsProperties.paywallSessionId: paywallSessionId,
            AppStrings.AnalyticsProperties.productId: productId ?? "unknown",
            AppStrings.AnalyticsProperties.placement: placement
        ])
    }
    
    /// Called when paywall is dismissed
    func dismissPaywall() {
        AnalyticsManager.shared.track(AppStrings.Analytics.paywallDismissed, properties: [
            AppStrings.AnalyticsProperties.paywallSessionId: paywallSessionId
        ])
        
        // Track paywall outcome
        trackPaywallOutcome(outcome: AppStrings.AnalyticsProperties.dismissed)
    }
    
    /// Handles upgrade button tap
    func handleUpgrade(onUpgrade: @escaping () -> Void) {
        let ctaLabel = shouldShowTryForFree() ? AppStrings.AnalyticsProperties.startTrial : AppStrings.AnalyticsProperties.continueLabel
        
        // Track CTA tap
        AnalyticsManager.shared.track(AppStrings.Analytics.paywallCtaTapped, properties: [
            AppStrings.AnalyticsProperties.paywallSessionId: paywallSessionId,
            AppStrings.AnalyticsProperties.ctaLabel: ctaLabel,
            AppStrings.AnalyticsProperties.productId: selectedProductId ?? "unknown"
        ])
        
        AnalyticsManager.shared.track(AppStrings.Analytics.paywallUpgradeClicked)
        
        let selectedPackage: Package?
        if freeTrialEnabled || selectedPlan == .weekly {
            selectedPackage = weeklyProduct
        } else {
            selectedPackage = yearlyProduct
        }
        
        guard let package = selectedPackage else {
            showError(AppStrings.UI.loadingPricing)
            return
        }
        
        // Track checkout started
        trackCheckoutStarted(package: package)
        
        purchasePackage(package) { [weak self] success in
            if success {
                self?.trackPaywallOutcome(outcome: AppStrings.AnalyticsProperties.purchased)
                onUpgrade()
            }
        }
    }
    
    /// Handles restore purchases
    func handleRestorePurchases(onSuccess: @escaping () -> Void) {
        subscriptionManager.restorePurchases { [weak self] success, error in
            DispatchQueue.main.async {
                if success {
                    AnalyticsManager.shared.track(AppStrings.Analytics.restoreSuccessful)
                    
                    if self?.subscriptionManager.isSubscribed == true {
                        onSuccess()
                    }
                } else if let error = error {
                    AnalyticsManager.shared.track(AppStrings.Analytics.restoreFailed, properties: [
                        AppStrings.AnalyticsProperties.error: error.localizedDescription
                    ])
                    self?.showError(error.localizedDescription)
                }
            }
        }
    }
    
    /// Formats trial period text from discount
    func formatTrialPeriod(_ discount: StoreProductDiscount) -> String? {
        guard discount.type == .introductory else { return nil }
        
        let unit = discount.subscriptionPeriod.unit
        let value = discount.subscriptionPeriod.value
        
        switch unit {
        case .day:
            if value == 3 {
                return AppStrings.UI.threeDayTrial
            } else {
                return "\(value)-Day Free Trial"
            }
        case .week:
            return "\(value)-Week Free Trial"
        case .month:
            return "\(value)-Month Free Trial"
        case .year:
            return "\(value)-Year Free Trial"
        @unknown default:
            return AppStrings.UI.freeTrial
        }
    }
    
    /// Determines if "Try for Free" should be shown
    func shouldShowTryForFree() -> Bool {
        // Show "Try for Free" if:
        // 1. Weekly product has an introductory offer, AND
        // 2. Free trial is enabled
        guard let weeklyProduct = weeklyProduct else { return false }
        return weeklyProduct.storeProduct.introductoryDiscount != nil && freeTrialEnabled
    }
    
    /// Gets the appropriate button text for the current state
    func getButtonText() -> String {
        if shouldShowTryForFree() {
            return AppStrings.UI.tryForFree
        } else {
            return AppStrings.UI.continueButton
        }
    }
    
    // MARK: - Private Methods
    
    private func trackPaywallShown() {
        AnalyticsManager.shared.track(AppStrings.Analytics.paywallShown, properties: [
            AppStrings.AnalyticsProperties.paywallSessionId: paywallSessionId,
            AppStrings.AnalyticsProperties.placement: placement,
            AppStrings.AnalyticsProperties.entryPoint: entryPoint,
            AppStrings.AnalyticsProperties.exportCount: UserDefaultsManager.shared.freeExportCount,
            AppStrings.AnalyticsProperties.isSubscribed: subscriptionManager.hasPremiumAccess
        ])
    }
    
    private func trackCheckoutStarted(package: Package) {
        let introDiscount = package.storeProduct.introductoryDiscount
        let hasIntroOffer = introDiscount != nil
        let trialDays = introDiscount?.subscriptionPeriod.unit == .day ? introDiscount?.subscriptionPeriod.value ?? 0 : 0
        
        AnalyticsManager.shared.track(AppStrings.Analytics.checkoutStarted, properties: [
            AppStrings.AnalyticsProperties.paywallSessionId: paywallSessionId,
            AppStrings.AnalyticsProperties.productId: package.identifier,
            AppStrings.AnalyticsProperties.billingPeriod: getBillingPeriod(package: package),
            AppStrings.AnalyticsProperties.price: package.storeProduct.localizedPriceString,
            AppStrings.AnalyticsProperties.currency: getCurrencyCode(from: package.storeProduct.localizedPriceString),
            AppStrings.AnalyticsProperties.introOfferApplied: hasIntroOffer,
            AppStrings.AnalyticsProperties.trialDays: trialDays
        ])
    }
    
    private func trackPaywallOutcome(outcome: String) {
        AnalyticsManager.shared.track(AppStrings.Analytics.paywallOutcome, properties: [
            AppStrings.AnalyticsProperties.paywallSessionId: paywallSessionId,
            AppStrings.AnalyticsProperties.outcome: outcome,
            AppStrings.AnalyticsProperties.selectedProductId: selectedProductId
        ])
    }
    
    private func getBillingPeriod(package: Package) -> String {
        let period = package.storeProduct.subscriptionPeriod
        switch period?.unit {
        case .day:
            return "\(period?.value ?? 1)_day"
        case .week:
            return "\(period?.value ?? 1)_week"
        case .month:
            return "\(period?.value ?? 1)_month"
        case .year:
            return "\(period?.value ?? 1)_year"
        default:
            return "unknown"
        }
    }
    
    private func getCurrencyCode(from localizedPriceString: String) -> String {
        // Try to extract currency from the localized price string
        // This is a simple implementation that looks for common currency symbols/codes
        if localizedPriceString.contains("$") {
            return "USD"
        } else if localizedPriceString.contains("€") {
            return "EUR"
        } else if localizedPriceString.contains("£") {
            return "GBP"
        } else if localizedPriceString.contains("¥") {
            return "JPY"
        } else {
            // Default to USD if we can't determine the currency
            return "USD"
        }
    }
    
    private func purchasePackage(_ package: Package, completion: @escaping (Bool) -> Void) {
        isPurchasing = true
        
        // Track purchase attempt
        AnalyticsManager.shared.track(AppStrings.Analytics.purchaseAttempted, properties: [
            AppStrings.AnalyticsProperties.paywallSessionId: paywallSessionId,
            AppStrings.AnalyticsProperties.productId: package.identifier,
            AppStrings.AnalyticsProperties.price: package.storeProduct.localizedPriceString
        ])
        
        subscriptionManager.purchase(package: package) { [weak self] success, error in
            DispatchQueue.main.async {
                self?.isPurchasing = false
                
                if success {
                    let introDiscount = package.storeProduct.introductoryDiscount
                    let hasIntroOffer = introDiscount != nil
                    let isTrialStart = hasIntroOffer && introDiscount?.type == .introductory
                    let trialDays = introDiscount?.subscriptionPeriod.unit == .day ? introDiscount?.subscriptionPeriod.value ?? 0 : 0
                    
                    AnalyticsManager.shared.track(AppStrings.Analytics.purchaseSuccessful, properties: [
                        AppStrings.AnalyticsProperties.paywallSessionId: self?.paywallSessionId ?? "",
                        AppStrings.AnalyticsProperties.productId: package.identifier,
                        AppStrings.AnalyticsProperties.price: package.storeProduct.localizedPriceString,
                        AppStrings.AnalyticsProperties.isTrialStart: isTrialStart,
                        AppStrings.AnalyticsProperties.trialDays: trialDays,
                        AppStrings.AnalyticsProperties.introOfferApplied: hasIntroOffer
                    ])
                    completion(true)
                } else if let error = error {
                    AnalyticsManager.shared.track(AppStrings.Analytics.purchaseFailed, properties: [
                        AppStrings.AnalyticsProperties.paywallSessionId: self?.paywallSessionId ?? "",
                        AppStrings.AnalyticsProperties.productId: package.identifier,
                        AppStrings.AnalyticsProperties.error: error.localizedDescription,
                        AppStrings.AnalyticsProperties.price: package.storeProduct.localizedPriceString
                    ])
                    self?.showError(error.localizedDescription)
                    completion(false)
                } else {
                    print(AppStrings.UI.purchaseCancelled)
                    AnalyticsManager.shared.track(AppStrings.Analytics.purchaseCancelled, properties: [
                        AppStrings.AnalyticsProperties.paywallSessionId: self?.paywallSessionId ?? "",
                        AppStrings.AnalyticsProperties.productId: package.identifier,
                        AppStrings.AnalyticsProperties.price: package.storeProduct.localizedPriceString
                    ])
                    completion(false)
                }
            }
        }
    }
    
    private func showError(_ message: String) {
        errorMessage = message
        showErrorAlert = true
    }
}
