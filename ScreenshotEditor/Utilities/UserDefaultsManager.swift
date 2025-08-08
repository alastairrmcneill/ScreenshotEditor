//
//  UserDefaultsManager.swift
//  ScreenshotEditor
//
//  Created by Alastair McNeill on 08/08/2025.
//

import Foundation

/// A manager class for handling UserDefaults operations for app state flags
class UserDefaultsManager {
    
    static let shared = UserDefaultsManager()
    
    private let userDefaults = UserDefaults.standard
    
    // MARK: - Keys
    private enum Keys {
        static let onboardingCompleted = "com.screenshoteditor.onboarding_completed"
        static let freeExportCount = "com.screenshoteditor.free_export_count"
        static let isSubscribed = "com.screenshoteditor.is_subscribed"
    }
    
    private init() {}
    
    // MARK: - Onboarding
    
    /// Indicates whether the user has completed the onboarding flow
    var hasCompletedOnboarding: Bool {
        get {
            return userDefaults.bool(forKey: Keys.onboardingCompleted)
        }
        set {
            userDefaults.set(newValue, forKey: Keys.onboardingCompleted)
        }
    }
    
    /// Marks onboarding as completed
    func completeOnboarding() {
        hasCompletedOnboarding = true
    }
    
    /// Resets onboarding status (useful for testing)
    func resetOnboarding() {
        hasCompletedOnboarding = false
    }
    
    // MARK: - Export Count
    
    /// The number of exports performed by free users
    var freeExportCount: Int {
        get {
            return userDefaults.integer(forKey: Keys.freeExportCount)
        }
        set {
            userDefaults.set(newValue, forKey: Keys.freeExportCount)
        }
    }
    
    /// Increments the free export count by 1
    func incrementFreeExportCount() {
        freeExportCount += 1
    }
    
    /// Resets the free export count to 0 (useful when user subscribes)
    func resetFreeExportCount() {
        freeExportCount = 0
    }
    
    // MARK: - Subscription Status
    
    /// Indicates whether the user has an active subscription
    var isSubscribed: Bool {
        get {
            return userDefaults.bool(forKey: Keys.isSubscribed)
        }
        set {
            userDefaults.set(newValue, forKey: Keys.isSubscribed)
        }
    }
    
    /// Marks user as subscribed and resets export count
    func setSubscribed(_ subscribed: Bool) {
        isSubscribed = subscribed
        if subscribed {
            resetFreeExportCount()
        }
    }
    
    // MARK: - Utility Methods
    
    /// Resets all app state flags (useful for testing or factory reset)
    func resetAllFlags() {
        resetOnboarding()
        resetFreeExportCount()
        isSubscribed = false
    }
}

// MARK: - Constants

extension UserDefaultsManager {
    /// Maximum number of free exports allowed
    static let maxFreeExports = 3
    
    /// Checks if the user has reached the free export limit
    var hasReachedFreeExportLimit: Bool {
        return freeExportCount >= UserDefaultsManager.maxFreeExports
    }
    
    /// Returns the number of remaining free exports
    var remainingFreeExports: Int {
        return max(0, UserDefaultsManager.maxFreeExports - freeExportCount)
    }
}
