//
//  StorageKey.swift
//  StoreHelper (iOS)
//
//  Created by Russell Archer on 20/12/2021.
//

import Foundation

public enum StorageKey {
    case appGroupBundleId   // Not stored. Constant value. The id for the container shared between the main app and widgets
    case contactUsUrl       // Not stored. Constant value. A URL where the user can contact the app developer.
    case requestRefund      // Not stored. Constant value. A URL which users on macOS can use to request a refund for an IAP.

    public func key() -> String {
        switch self {
            case .appGroupBundleId: return "appGroupBundleId"
            case .contactUsUrl:     return "contactUsUrl"
            case .requestRefund:    return "requestRefund"
        }
    }
    
    public func value() -> String? {
        switch self {
            // If your app supports widgets (e.g. an App Group) that use IAP-based functionality, return the group id that allows
            // the main app and widgets to share data. For example "group.com.{developer}.{appname}". Returning nil means there's
            // no shared data
            case .appGroupBundleId: return nil
                
            // A contact URL. Will be used in the purchase management view
            case .contactUsUrl: return "https://russell-archer.github.io"
                
            // A URL which users on macOS can use to request a refund for an IAP
            case .requestRefund: return "https://reportaproblem.apple.com/"
        }
    }
}

