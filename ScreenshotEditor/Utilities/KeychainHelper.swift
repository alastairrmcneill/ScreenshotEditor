//
//  KeychainHelper.swift
//  ScreenshotEditor
//
//  Created by Alastair McNeill on 07/08/2025.
//

import Foundation
import Security

/// A helper class for storing and retrieving values from the Keychain
class KeychainHelper {
    
    static let shared = KeychainHelper()
    
    private init() {}
    
    /// Store a string value in the Keychain
    /// - Parameters:
    ///   - value: The string value to store
    ///   - key: The key to associate with the value
    /// - Returns: True if the operation was successful, false otherwise
    @discardableResult
    func store(_ value: String, forKey key: String) -> Bool {
        guard let data = value.data(using: .utf8) else {
            return false
        }
        
        return store(data, forKey: key)
    }
    
    /// Store data in the Keychain
    /// - Parameters:
    ///   - data: The data to store
    ///   - key: The key to associate with the data
    /// - Returns: True if the operation was successful, false otherwise
    @discardableResult
    func store(_ data: Data, forKey key: String) -> Bool {
        // First, delete any existing item with the same key
        delete(key)
        
        // Create the query dictionary
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]
        
        // Add the item to the Keychain
        let status = SecItemAdd(query as CFDictionary, nil)
        
        return status == errSecSuccess
    }
    
    /// Retrieve a string value from the Keychain
    /// - Parameter key: The key associated with the value
    /// - Returns: The string value if found, nil otherwise
    func retrieve(_ key: String) -> String? {
        guard let data = retrieveData(key) else {
            return nil
        }
        
        return String(data: data, encoding: .utf8)
    }
    
    /// Retrieve data from the Keychain
    /// - Parameter key: The key associated with the data
    /// - Returns: The data if found, nil otherwise
    func retrieveData(_ key: String) -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess else {
            return nil
        }
        
        return result as? Data
    }
    
    /// Delete a value from the Keychain
    /// - Parameter key: The key associated with the value to delete
    /// - Returns: True if the operation was successful, false otherwise
    @discardableResult
    func delete(_ key: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        
        return status == errSecSuccess || status == errSecItemNotFound
    }
    
    /// Check if a key exists in the Keychain
    /// - Parameter key: The key to check
    /// - Returns: True if the key exists, false otherwise
    func exists(_ key: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
        
        let status = SecItemCopyMatching(query as CFDictionary, nil)
        
        return status == errSecSuccess
    }
}
