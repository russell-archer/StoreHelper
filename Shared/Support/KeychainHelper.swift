//
//  KeychainHelper.swift
//  StoreHelper
//
//  Created by Russell Archer on 01/07/2021.
//

import Foundation
import Security

/// StoreHelper exceptions
public enum KeychainException: Error, Equatable {
    case purchaseNotAdded
    case purchaseNotRemoved
    case keychainError
    
    public func shortDescription() -> String {
        
        switch self {
            case .purchaseNotAdded:   return "Unable to add purchase to keychain."
            case .purchaseNotRemoved: return "Unable to remove purchase from keychain."
            case .keychainError:      return "Unknown keychain error."
        }
    }
}

public struct KeychainHelper {
    
    public func add(_ productId: ProductId) throws {
        
        if has(productId) {
            print("Keychain already contains \(productId) so not adding")
            return
        }
        
        // Create a query for what we want to add to the keychain
        let query = [kSecClass as String  : kSecClassGenericPassword,
                     kSecAttrAccount as String : productId,
                     kSecValueData as String : productId.data(using: .utf8)!] as CFDictionary
        
        // Add the item to the keychain
        let status = SecItemAdd(query, nil)
        guard status == errSecSuccess else { throw KeychainException.purchaseNotAdded }
    }
    
    public func remove(_ productId: ProductId) throws {
        
        if !has(productId) {
            print("Keychain does not contain \(productId) so can't delete it")
            return
        }
        
        // Create a query for what we want to remove from the keychain
        let query = [kSecClass as String : kSecClassGenericPassword,
                     kSecAttrAccount as String : productId,
                     kSecValueData as String : productId.data(using: .utf8)!,
                     kSecMatchLimit as String: kSecMatchLimitOne] as CFDictionary
        
        // Add the item to the keychain
        let status = SecItemDelete(query)
        guard status == errSecSuccess else { throw KeychainException.purchaseNotAdded }
    }
    
    public func has(_ productId: ProductId) -> Bool {
        
        // Create a query of what we want to search for. Note we don't restrict the search (kSecMatchLimitAll)
        let query = [kSecClass as String : kSecClassGenericPassword,
                     kSecAttrAccount as String : productId,
                     kSecValueData as String : productId.data(using: .utf8)!,
                     kSecMatchLimit as String: kSecMatchLimitOne] as CFDictionary
        
        // Search for the item in the keychain
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        if status == errSecItemNotFound { return false }
        
        return true
    }
    
    public func all(productIds: Set<ProductId>) -> Set<ProductId>? {
        
        // Create a query of what we want to search for. Note we don't restrict the search (kSecMatchLimitAll)
        let query = [kSecClass as String : kSecClassGenericPassword,
                     kSecMatchLimit as String: kSecMatchLimitAll,
                     kSecReturnAttributes as String: true,
                     kSecReturnData as String: true] as CFDictionary
        
        // Search for all the items created by this app in the keychain
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query, &item)
        guard status != errSecItemNotFound, status == errSecSuccess else { return nil }
        
        // The item var be an array of dictionaries
        guard let entries = item as? [[String : Any]] else { return nil }
        
        print("All purchased product ids in keychain:")
        var foundProductIds = Set<ProductId>()
        for entry in entries {
            if let key = entry[kSecAttrAccount as String] as? String {
                // Is this keychain entry an actual ProductId?
                if productIds.contains(key) {
                    print("  Found \(key)")
                    foundProductIds.insert(key)
                }
            }
        }
        
        return foundProductIds.count > 0 ? foundProductIds : nil
    }
}
