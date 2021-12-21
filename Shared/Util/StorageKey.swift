//
//  StorageKey.swift
//  StoreHelper (iOS)
//
//  Created by Russell Archer on 20/12/2021.
//

import Foundation

public enum StorageKey {
    case appGroupBundleId   // The id for the container shared between the main app and widgets
    case contactUsUrl       // A URL where the user can contact the app developer
    
    public func value() -> String? {
        switch self {
            // If your app supports widgets (e.g. an App Group) that use IAP-based functionality, return the group id that allows
            // the main app and widgets to share data. For example "group.com.{developer}.{appname}". Returning nil means there's
            // no shared data
            case .appGroupBundleId: return nil
                
            // A contact URL. Will be used in the purchases hamburger menu
            case .contactUsUrl: return nil
        }
    }
}
