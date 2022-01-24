//
//  OptionsViewModel.swift
//  StoreHelper
//
//  Created by Russell Archer on 31/07/2021.
//

import SwiftUI
import StoreKit

public struct OptionsViewModel {
    @ObservedObject var storeHelper: StoreHelper
    
    #if DEBUG
    /// Resets (deletes) all consumable product purchases from the keychain. Debug-only example.
    public func resetConsumables() {
        guard storeHelper.hasConsumableProducts,
              let products = storeHelper.consumableProducts,
              let removedProducts = KeychainHelper.resetKeychainConsumables(for: products.map { $0.id }) else { return }
        
        Task.init {
            for product in removedProducts { await storeHelper.updatePurchasedIdentifiers(product, insert: false) }
        }
    }
    #endif
    
    /// Restores previous user purchases. With StoreKit2 this is normally not necessary and should only be
    /// done in response to explicit user action. Will result in the user having to authenticate with the
    /// App Store.
    public func restorePurchases() {
        Task.init { try? await AppStore.sync() }
    }
}
