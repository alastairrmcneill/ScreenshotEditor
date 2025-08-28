//
//  UUIDManager.swift
//  ScreenshotEditor
//
//  Created by Alastair McNeill on 07/08/2025.
//

import Foundation

/// A manager class for handling anonymous UUID generation and persistence
class UUIDManager {
    
    static let shared = UUIDManager()
    
    private let keychainKey = "com.screenshoteditor.anonymous_uuid"
    private var cachedUUID: String?
    
    private init() {}
    
    /// Gets the anonymous UUID for this app installation.
    /// Creates a new UUID on first launch and persists it in the Keychain.
    /// Returns the same UUID on subsequent launches.
    var anonymousUUID: String {
        // Return cached UUID if available
        if let cachedUUID = cachedUUID {
            return cachedUUID
        }
        
        // Try to retrieve existing UUID from Keychain
        if let existingUUID = KeychainHelper.shared.retrieve(keychainKey) {
            cachedUUID = existingUUID
            return existingUUID
        }
        
        // Generate new UUID and store in Keychain
        let newUUID = UUID().uuidString
        
        if KeychainHelper.shared.store(newUUID, forKey: keychainKey) {
            cachedUUID = newUUID
            return newUUID
        } else {
            // Fallback: if Keychain storage fails, return the UUID without caching
            // This ensures the app continues to work even if Keychain access is denied
            return newUUID
        }
    }
    
    /// Regenerates the anonymous UUID (useful for testing or privacy reset)
    /// - Returns: The new UUID
    @discardableResult
    func regenerateUUID() -> String {
        // Clear cached UUID
        cachedUUID = nil
        
        // Delete existing UUID from Keychain
        KeychainHelper.shared.delete(keychainKey)
        
        // Generate and return new UUID
        return anonymousUUID
    }
    
    /// Checks if a UUID already exists in the Keychain
    /// - Returns: True if UUID exists, false if this is the first launch
    var hasExistingUUID: Bool {
        return KeychainHelper.shared.exists(keychainKey)
    }
}
