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
    
    /// Called when paywall is dismissed
    func dismissPaywall() {
        AnalyticsManager.shared.track(AppStrings.Analytics.paywallDismissed)
    }
    
    /// Handles upgrade button tap
    func handleUpgrade(onUpgrade: @escaping () -> Void) {
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
        
        purchasePackage(package) { [weak self] success in
            if success {
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
            AppStrings.AnalyticsProperties.exportCount: UserDefaultsManager.shared.freeExportCount,
            AppStrings.AnalyticsProperties.isSubscribed: subscriptionManager.hasPremiumAccess
        ])
    }
    
    private func purchasePackage(_ package: Package, completion: @escaping (Bool) -> Void) {
        isPurchasing = true
        
        subscriptionManager.purchase(package: package) { [weak self] success, error in
            DispatchQueue.main.async {
                self?.isPurchasing = false
                
                if success {
                    AnalyticsManager.shared.track(AppStrings.Analytics.purchaseSuccessful, properties: [
                        AppStrings.AnalyticsProperties.price: package.storeProduct.localizedPriceString
                    ])
                    completion(true)
                } else if let error = error {
                    AnalyticsManager.shared.track(AppStrings.Analytics.purchaseFailed, properties: [
                        AppStrings.AnalyticsProperties.error: error.localizedDescription,
                        AppStrings.AnalyticsProperties.price: package.storeProduct.localizedPriceString
                    ])
                    self?.showError(error.localizedDescription)
                    completion(false)
                } else {
                    print(AppStrings.UI.purchaseCancelled)
                    AnalyticsManager.shared.track(AppStrings.Analytics.purchaseCancelled, properties: [
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
