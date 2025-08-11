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
        
        setupSuperProperties()
    }
    
    private func setupSuperProperties() {
        let superProperties: Properties = [
            "anonymous_uuid": UUIDManager.shared.anonymousUUID,
            "debug": isDebugMode,
        ]
        
        Mixpanel.mainInstance().registerSuperProperties(superProperties)
        print("\(AppStrings.Debug.superPropertiesSet) \(superProperties)")
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

