//
//  AppGroupSupport.swift
//
//  Created by Russell Archer on 20/12/2021.
//

import SwiftUI

struct AppGroupSupport {
    
    static func syncPurchase(productId: String, purchased: Bool) {
        // Update UserDefaults in the container shared between ourselves and other members of the group.com.{developer}.{appname} AppGroup.
        // Currently this is done so that widgets can tell what IAPs have been purchased. Note that widgets can't use StoreHelper directly
        // because the they don't purchase anything and are not considered to be part of the app that did the purchasing as far as
        // StoreKit is concerned.
        guard let id = StorageKey.appGroupBundleId.value() else { return }
        if let defaults = UserDefaults(suiteName: id) { defaults.set(purchased, forKey: productId)}
    }
    
    static func isPurchased(productId: String) -> Bool {
        guard let id = StorageKey.appGroupBundleId.value() else { return false }
        var purchased = false
        if let defaults = UserDefaults(suiteName: id) { purchased = defaults.bool(forKey: productId)}
        return purchased
    }
}
