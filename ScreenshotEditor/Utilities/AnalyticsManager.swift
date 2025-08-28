// ScreenshotEditor/Utilities/AnalyticsManager.swift
import Foundation
import Mixpanel

typealias Properties = [String: MixpanelType]

class AnalyticsManager {
    static let shared = AnalyticsManager()
    private init() {}
    
    private var isDebugMode: Bool {
        #if DEBUG
        return true
        #else
        return false
        #endif
    }

    func setup() {
        let apiKey = Bundle.main.object(forInfoDictionaryKey: "MixpanelApiKey") as? String
        print("\(AppStrings.Debug.analyticsSetup) \(apiKey ?? "")");
        Mixpanel.initialize(token: apiKey ?? "", trackAutomaticEvents: true)
        
        setupUserIdentity()
        setupSuperProperties()
    }
    
    /// Set up user identity using the same UUID as SubscriptionManager
    private func setupUserIdentity() {
        let anonymousUUID = UUIDManager.shared.anonymousUUID
        print("👤 [AnalyticsManager] Setting up user identity with UUID: \(anonymousUUID)")
        
        // Set the user ID in Mixpanel
        Mixpanel.mainInstance().identify(distinctId: anonymousUUID)
        print("✅ [AnalyticsManager] User identity set in Mixpanel")
    }
    
    private func setupSuperProperties() {
        let superProperties: Properties = [
            "anonymous_uuid": UUIDManager.shared.anonymousUUID,
            "debug": isDebugMode,
        ]
        
        Mixpanel.mainInstance().registerSuperProperties(superProperties)
        print("\(AppStrings.Debug.superPropertiesSet) \(superProperties)")
    }
    
    // MARK: - User Management
    
    /// Get the current user ID from Mixpanel
    func getUserId() -> String {
        return Mixpanel.mainInstance().distinctId
    }
    
    /// Set a new user ID and sync with SubscriptionManager
    func setUserId(_ userId: String) {
        print("👤 [AnalyticsManager] Setting user ID to: \(userId)")
        Mixpanel.mainInstance().identify(distinctId: userId)
        
        // Notify SubscriptionManager about user change (with delay to avoid circular calls)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            SubscriptionManager.shared.syncUserIdWithAnalytics()
        }
        print("✅ [AnalyticsManager] User ID updated and will sync with SubscriptionManager")
    }
    
    /// Reset user to anonymous and sync with SubscriptionManager
    func resetUser() {
        print("🔄 [AnalyticsManager] Resetting user to anonymous...")
        Mixpanel.mainInstance().reset()
        
        // Re-setup identity with new anonymous ID
        setupUserIdentity()
        
        // Notify SubscriptionManager about user logout (with delay to avoid circular calls)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            SubscriptionManager.shared.handleUserLogout()
        }
        print("✅ [AnalyticsManager] User reset and will sync with SubscriptionManager")
    }

    func track(_ event: String, properties: Properties? = nil) {
        var finalProperties = properties ?? [:]
        
        // Ensure UUID is always included (backup for super properties)
        finalProperties["anonymous_uuid"] = UUIDManager.shared.anonymousUUID
        finalProperties["debug"] = isDebugMode
        
        print("\(AppStrings.Debug.analyticsEvent) \(event): \(finalProperties)")
        Mixpanel.mainInstance().track(event: event, properties: finalProperties)
    }
}

