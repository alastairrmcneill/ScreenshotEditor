//
//  SubscriptionManager.swift
//  ScreenshotEditor
//
//  Created by Alastair McNeill on 13/08/2025.
//

import Foundation
import RevenueCat

/// Manager class for handling RevenueCat subscription operations
class SubscriptionManager: NSObject, ObservableObject {
    static let shared = SubscriptionManager()
    
    @Published var isSubscribed: Bool = false
    @Published var offerings: Offerings?
    @Published var weeklyProduct: Package?
    @Published var yearlyProduct: Package?
    @Published var hasPremiumAccess: Bool = false
    @Published var activeEntitlements: [String] = []
    
    private override init() {
        super.init()
        configureRevenueCat()
    }
    
    // MARK: - Configuration
    
    /// Configure RevenueCat SDK
    private func configureRevenueCat() {        
        // Log the API key (masked for security)
        let apiKey = AppConstants.RevenueCat.apiKey
        
        // Configure with API key
        Purchases.logLevel = .debug // Set to .info for production
        Purchases.configure(withAPIKey: AppConstants.RevenueCat.apiKey)
        
        // Sync user ID with Mixpanel/UUID
        performUserIdSync()
        
        // Set up delegate to listen for subscription changes
        Purchases.shared.delegate = self
        
        // Check current subscription status
        checkSubscriptionStatus()
    }
    
    // MARK: - User ID Sync
    
    /// Sync user ID between RevenueCat and Mixpanel/UUID
    private func performUserIdSync() {        
        // Get the anonymous UUID from our UUID manager
        let anonymousUUID = UUIDManager.shared.anonymousUUID
        
        // Get current RevenueCat user ID
        let currentRevenueCatUserId = Purchases.shared.appUserID
        print("👤 [SubscriptionManager] Current RevenueCat user ID: \(currentRevenueCatUserId)")
        
        // If they're different, login to RevenueCat with our UUID
        if currentRevenueCatUserId != anonymousUUID {
            print("🔄 [SubscriptionManager] User IDs don't match, syncing RevenueCat to anonymous UUID...")
            
            Purchases.shared.logIn(anonymousUUID) { [weak self] customerInfo, created, error in
                if let error = error {
                    print("❌ [SubscriptionManager] Error syncing user ID: \(error.localizedDescription)")
                    print("🔍 [SubscriptionManager] Error details: \(error)")
                    return
                }
                
                print("✅ [SubscriptionManager] Successfully synced user IDs")
                print("👤 [SubscriptionManager] RevenueCat user ID: \(Purchases.shared.appUserID)")
                print("🆕 [SubscriptionManager] Created new customer: \(created)")
                
                // Update subscription status after login
                DispatchQueue.main.async {
                    self?.updateSubscriptionStatus(from: customerInfo)
                }
            }
        }
    }
    
    /// Public method to sync user ID (can be called when user identity changes)
    public func syncUserIdWithAnalytics() {
        // Use a slight delay to avoid potential circular calls during initialization
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.performUserIdSync()
        }
    }
    
    /// Helper method to update subscription status from customer info
    private func updateSubscriptionStatus(from customerInfo: CustomerInfo?) {
        guard let customerInfo = customerInfo else { 
            return 
        }
        
        let wasSubscribed = self.isSubscribed
        self.isSubscribed = !customerInfo.activeSubscriptions.isEmpty
        
        // Update entitlements as well
        updateEntitlements(from: customerInfo)
        
        if wasSubscribed != self.isSubscribed {
            print("🔄 [SubscriptionManager] Subscription status changed after user sync: \(wasSubscribed ? "Active" : "Inactive") → \(self.isSubscribed ? "Active" : "Inactive")")
        } else {
            print("📊 [SubscriptionManager] Subscription status unchanged after sync: \(self.isSubscribed ? "Active" : "Inactive")")
        }
    }
    
    /// Call this method when user logs out (resets to anonymous)
    public func handleUserLogout() {        
        // Reset subscription status
        DispatchQueue.main.async { [weak self] in
            self?.isSubscribed = false
            self?.hasPremiumAccess = false
            self?.activeEntitlements = []
            self?.offerings = nil
            self?.weeklyProduct = nil
            self?.yearlyProduct = nil
        }
    }
    
    // MARK: - Debug Helpers
    
    /// Debug method to check user ID sync status
    public func checkUserIdSync() {
        let analyticsUserId = AnalyticsManager.shared.getUserId()
        let revenueCatUserId = Purchases.shared.appUserID
        let uuidManagerId = UUIDManager.shared.anonymousUUID

        let allMatch = analyticsUserId == revenueCatUserId && revenueCatUserId == uuidManagerId
        if allMatch {
            print("✅ All user IDs are synchronized!")
        } else {
            print("❌ User IDs are NOT synchronized:")
            if analyticsUserId != uuidManagerId {
                print("   - Analytics and UUID don't match")
            }
            if revenueCatUserId != uuidManagerId {
                print("   - RevenueCat and UUID don't match")
            }
            if analyticsUserId != revenueCatUserId {
                print("   - Analytics and RevenueCat don't match")
            }
        }
        print("================================================\n")
    }
    
    // MARK: - Subscription Status
    
    /// Check current subscription status and entitlements
    func checkSubscriptionStatus() {
        
        Purchases.shared.getCustomerInfo { [weak self] customerInfo, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("❌ [SubscriptionManager] Error fetching customer info: \(error.localizedDescription)")
                    print("🔍 [SubscriptionManager] Error details: \(error)")
                    return
                }
                
                guard let customerInfo = customerInfo else { 
                    print("⚠️ [SubscriptionManager] No customer info received")
                    return 
                }
                
                // Log detailed customer info
                print("👤 [SubscriptionManager] Customer ID: \(customerInfo.originalAppUserId)")
                print("📅 [SubscriptionManager] First seen: \(customerInfo.firstSeen)")
                print("📅 [SubscriptionManager] Latest expiration date: \(customerInfo.latestExpirationDate?.description ?? "None")")
                print("🎫 [SubscriptionManager] Active subscriptions: \(customerInfo.activeSubscriptions)")
                print("🎯 [SubscriptionManager] All purchased product IDs: \(customerInfo.allPurchasedProductIdentifiers)")
                print("🔄 [SubscriptionManager] Non-subscription transactions: \(customerInfo.nonSubscriptionTransactions.count)")
                
                // Update entitlements and premium access
                self?.updateEntitlements(from: customerInfo)
                
                // Check if user has any active subscription (legacy check)
                let wasSubscribed = self?.isSubscribed ?? false
                self?.isSubscribed = !customerInfo.activeSubscriptions.isEmpty
                let statusChanged = wasSubscribed != (self?.isSubscribed ?? false)
                
                if statusChanged {
                    print("🔄 [SubscriptionManager] Subscription status CHANGED: \(wasSubscribed ? "Active" : "Inactive") → \(self?.isSubscribed == true ? "Active" : "Inactive")")
                } else {
                    print("📊 [SubscriptionManager] Subscription status: \(self?.isSubscribed == true ? "Active" : "Inactive")")
                }
            }
        }
    }
    
    /// Update entitlements state from customer info
    private func updateEntitlements(from customerInfo: CustomerInfo) {
        print("\n🎫 [SubscriptionManager] === Current User Entitlements ===")
        
        var newActiveEntitlements: [String] = []
        var hasAnyActiveEntitlement = false
        
        // Log all entitlements (both active and inactive)
        if customerInfo.entitlements.all.isEmpty {
            print("📋 [SubscriptionManager] No entitlements configured for this user")
        } else {
            for (entitlementId, entitlement) in customerInfo.entitlements.all {
                let status = entitlement.isActive ? "✅ ACTIVE" : "❌ Inactive"
                print("� [SubscriptionManager] Entitlement '\(entitlementId)': \(status)")
                
                if entitlement.isActive {
                    newActiveEntitlements.append(entitlementId)
                    hasAnyActiveEntitlement = true
                    
                    print("   - Product ID: \(entitlement.productIdentifier)")
                    print("   - Will renew: \(entitlement.willRenew)")
                    print("   - Expires: \(entitlement.expirationDate?.description ?? "Never")")
                    
                    if let originalPurchaseDate = entitlement.originalPurchaseDate {
                        print("   - Original purchase: \(originalPurchaseDate)")
                    }
                    
                    if let latestPurchaseDate = entitlement.latestPurchaseDate {
                        print("   - Latest purchase: \(latestPurchaseDate)")
                    }
                }
            }
        }
        
        // Update state
        let previousPremiumAccess = self.hasPremiumAccess
        let previousActiveEntitlements = self.activeEntitlements
        
        self.activeEntitlements = newActiveEntitlements
        self.hasPremiumAccess = hasAnyActiveEntitlement
        
        // Log changes
        if previousPremiumAccess != self.hasPremiumAccess {
            print("🔄 [SubscriptionManager] Premium access CHANGED: \(previousPremiumAccess ? "Yes" : "No") → \(self.hasPremiumAccess ? "Yes" : "No")")
        } else {
            print("📊 [SubscriptionManager] Premium access: \(self.hasPremiumAccess ? "Yes" : "No")")
        }
        
        if previousActiveEntitlements != self.activeEntitlements {
            print("🔄 [SubscriptionManager] Active entitlements CHANGED:")
            print("   Previous: \(previousActiveEntitlements)")
            print("   Current: \(self.activeEntitlements)")
        } else {
            print("📊 [SubscriptionManager] Active entitlements unchanged: \(self.activeEntitlements)")
        }
        
        print("===============================================\n")
    }
    
    // MARK: - Fetch Offerings
    
    /// Fetch available offerings from RevenueCat
    func fetchOfferings() {
        print("🛒 [SubscriptionManager] Fetching RevenueCat offerings...")
        
        Purchases.shared.getOfferings { [weak self] offerings, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("❌ [SubscriptionManager] Error fetching offerings: \(error.localizedDescription)")
                    print("🔍 [SubscriptionManager] Error details: \(error)")
                    return
                }
                
                guard let offerings = offerings else {
                    print("⚠️ [SubscriptionManager] No offerings available from RevenueCat")
                    return
                }
                
                print("✅ [SubscriptionManager] Successfully fetched offerings")
                print("📦 [SubscriptionManager] Total offerings: \(offerings.all.count)")
                
                // Log all available offerings
                for (offeringId, offering) in offerings.all {
                    print("📋 [SubscriptionManager] Offering '\(offeringId)': \(offering.availablePackages.count) packages")
                    print("   - Description: \(offering.serverDescription)")
                    print("   - Metadata: \(offering.metadata)")
                }
                
                self?.offerings = offerings
                self?.processOfferings(offerings)
            }
        }
    }
    
    /// Process and extract specific products from offerings
    private func processOfferings(_ offerings: Offerings) {
        print("\n🔍 [SubscriptionManager] === RevenueCat Offerings Debug ===")
        
        // Get default offering
        guard let defaultOffering = offerings.current else {
            print("❌ [SubscriptionManager] No current offering found")
            print("📋 [SubscriptionManager] Available offering IDs: \(Array(offerings.all.keys))")
            return
        }
        
        print("📦 [SubscriptionManager] Current offering identifier: \(defaultOffering.identifier)")
        print("📊 [SubscriptionManager] Available packages count: \(defaultOffering.availablePackages.count)")
        print("📝 [SubscriptionManager] Offering description: \(defaultOffering.serverDescription)")
        
        // Log expected product IDs
        print("🎯 [SubscriptionManager] Looking for products:")
        print("   - Weekly: \(AppConstants.RevenueCat.weeklyProductId)")
        print("   - Yearly: \(AppConstants.RevenueCat.yearlyProductId)")
        
        // Reset products before assignment
        weeklyProduct = nil
        yearlyProduct = nil
        
        // Find weekly and yearly packages
        for (index, package) in defaultOffering.availablePackages.enumerated() {
            let product = package.storeProduct
            print("\n📦 [SubscriptionManager] Package #\(index + 1): \(package.identifier)")
            print("   🆔 Product ID: \(product.productIdentifier)")
            print("   💰 Localized Price: \(product.localizedPriceString)")
            print("   💵 Price: \(product.price)")
            print("   🌍 Currency Code: \(product.priceFormatter?.currencyCode ?? "Unknown")")
            print("   📅 Subscription Period: \(package.packageType)")
            print("   🎁 Has Intro Offer: \(product.introductoryDiscount != nil)")
            
            if let introDiscount = product.introductoryDiscount {
                print("   🎁 Intro Discount: \(introDiscount.localizedPriceString) for \(introDiscount.subscriptionPeriod)")
            }
            
            // Assign packages based on product identifiers
            if product.productIdentifier == AppConstants.RevenueCat.weeklyProductId {
                weeklyProduct = package
                print("   ✅ Assigned as weekly product (by Product ID)")
            } else if product.productIdentifier == AppConstants.RevenueCat.yearlyProductId {
                yearlyProduct = package
                print("   ✅ Assigned as yearly product (by Product ID)")
            } else {
                // Also check by package type as fallback
                switch package.packageType {
                case .weekly:
                    if weeklyProduct == nil {
                        weeklyProduct = package
                        print("   ✅ Assigned as weekly product (by Package Type)")
                    } else {
                        print("   ⚠️ Weekly product already assigned, skipping")
                    }
                case .annual:
                    if yearlyProduct == nil {
                        yearlyProduct = package
                        print("   ✅ Assigned as yearly product (by Package Type)")
                    } else {
                        print("   ⚠️ Yearly product already assigned, skipping")
                    }
                default:
                    print("   ❓ Unknown package type: \(package.packageType)")
                }
            }
        }
        
        print("\n📊 [SubscriptionManager] === Final Product Assignment ===")
        if let weekly = weeklyProduct {
            print("✅ Weekly product: \(weekly.storeProduct.localizedPriceString) (\(weekly.storeProduct.productIdentifier))")
        } else {
            print("❌ Weekly product: Not found")
        }
        
        if let yearly = yearlyProduct {
            print("✅ Yearly product: \(yearly.storeProduct.localizedPriceString) (\(yearly.storeProduct.productIdentifier))")
        } else {
            print("❌ Yearly product: Not found")
        }
        print("======================================================\n")
    }
    
    // MARK: - Purchase Flow
    
    /// Purchase a package
    func purchase(package: Package, completion: @escaping (Bool, Error?) -> Void) {
        print("💳 [SubscriptionManager] Attempting to purchase: \(package.identifier)")
        print("💰 [SubscriptionManager] Price: \(package.storeProduct.localizedPriceString)")
        print("🆔 [SubscriptionManager] Product ID: \(package.storeProduct.productIdentifier)")
        
        Purchases.shared.purchase(package: package) { [weak self] transaction, customerInfo, error, userCancelled in
            DispatchQueue.main.async {
                if userCancelled {
                    print("❌ [SubscriptionManager] Purchase cancelled by user")
                    completion(false, nil)
                    return
                }
                
                if let error = error {
                    print("❌ [SubscriptionManager] Purchase error: \(error.localizedDescription)")
                    print("🔍 [SubscriptionManager] Error details: \(error)")
                    completion(false, error)
                    return
                }
                
                guard let customerInfo = customerInfo else {
                    print("⚠️ [SubscriptionManager] No customer info received after purchase")
                    completion(false, nil)
                    return
                }
                
                // Log transaction details
                if let transaction = transaction {
                    print("✅ [SubscriptionManager] Transaction completed:")
                    print("   🆔 Transaction ID: \(transaction.transactionIdentifier)")
                    print("   📦 Product ID: \(transaction.productIdentifier)")
                    print("   📅 Purchase Date: \(transaction.purchaseDate)")
                }
                
                // Update subscription status and entitlements
                let previousStatus = self?.isSubscribed ?? false
                self?.isSubscribed = !customerInfo.activeSubscriptions.isEmpty
                
                // Update entitlements
                self?.updateEntitlements(from: customerInfo)
                
                print("🔄 [SubscriptionManager] Purchase successful!")
                print("📊 [SubscriptionManager] Subscription status: \(previousStatus ? "Active" : "Inactive") → \(self?.isSubscribed == true ? "Active" : "Inactive")")
                print("🎫 [SubscriptionManager] Active subscriptions: \(customerInfo.activeSubscriptions)")
                
                completion(true, nil)
            }
        }
    }
    
    /// Restore purchases
    func restorePurchases(completion: @escaping (Bool, Error?) -> Void) {
        print("🔄 [SubscriptionManager] Restoring purchases...")
        
        Purchases.shared.restorePurchases { [weak self] customerInfo, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("❌ [SubscriptionManager] Restore error: \(error.localizedDescription)")
                    print("🔍 [SubscriptionManager] Error details: \(error)")
                    completion(false, error)
                    return
                }
                
                guard let customerInfo = customerInfo else {
                    print("⚠️ [SubscriptionManager] No customer info received after restore")
                    completion(false, nil)
                    return
                }
                
                // Log restore details
                print("📊 [SubscriptionManager] Restore operation completed:")
                print("   🎫 Active subscriptions: \(customerInfo.activeSubscriptions)")
                print("   🛍️ All purchased products: \(customerInfo.allPurchasedProductIdentifiers)")
                print("   🔄 Non-subscription transactions: \(customerInfo.nonSubscriptionTransactions.count)")
                
                // Update subscription status and entitlements
                let previousStatus = self?.isSubscribed ?? false
                self?.isSubscribed = !customerInfo.activeSubscriptions.isEmpty
                
                // Update entitlements
                self?.updateEntitlements(from: customerInfo)
                
                let statusChanged = previousStatus != (self?.isSubscribed ?? false)
                if statusChanged {
                    print("🔄 [SubscriptionManager] Subscription status changed: \(previousStatus ? "Active" : "Inactive") → \(self?.isSubscribed == true ? "Active" : "Inactive")")
                } else {
                    print("📊 [SubscriptionManager] Subscription status unchanged: \(self?.isSubscribed == true ? "Active" : "Inactive")")
                }
                
                if customerInfo.activeSubscriptions.isEmpty && customerInfo.allPurchasedProductIdentifiers.isEmpty {
                    print("ℹ️ [SubscriptionManager] No previous purchases found to restore")
                } else if customerInfo.activeSubscriptions.isEmpty {
                    print("⚠️ [SubscriptionManager] Previous purchases found but no active subscriptions")
                }
                
                completion(true, nil)
            }
        }
    }
}

// MARK: - PurchasesDelegate

extension SubscriptionManager: PurchasesDelegate {
    func purchases(_ purchases: Purchases, receivedUpdated customerInfo: CustomerInfo) {
        print("📡 [SubscriptionManager] Received customer info update from RevenueCat")
        print("   🎫 Active subscriptions: \(customerInfo.activeSubscriptions)")
        print("   📅 Latest expiration: \(customerInfo.latestExpirationDate?.description ?? "None")")
        
        DispatchQueue.main.async { [weak self] in
            let previousStatus = self?.isSubscribed ?? false
            self?.isSubscribed = !customerInfo.activeSubscriptions.isEmpty
            
            // Update entitlements from the updated customer info
            self?.updateEntitlements(from: customerInfo)
            
            let statusChanged = previousStatus != (self?.isSubscribed ?? false)
            if statusChanged {
                print("🔄 [SubscriptionManager] Customer info update changed subscription status: \(previousStatus ? "Active" : "Inactive") → \(self?.isSubscribed == true ? "Active" : "Inactive")")
            } else {
                print("📊 [SubscriptionManager] Customer info update - subscription status unchanged: \(self?.isSubscribed == true ? "Active" : "Inactive")")
            }
        }
    }
    
    func purchases(_ purchases: Purchases, readyForPromotedProduct product: StoreProduct, purchase makeDeferredPurchase: @escaping StartPurchaseBlock) {
        print("🎁 [SubscriptionManager] Ready for promoted product: \(product.productIdentifier)")
        // You can implement promoted purchase logic here if needed
    }
}
