//
//  StorageKey.swift
//  StoreHelper (iOS)
//
//  Created by Russell Archer on 20/12/2021.
//

import Foundation

public enum StorageKey {
    case appGroupBundleId  // The id for the container shared between the main app and widgets
    
    public func id() -> String? {
        switch self {
            // If your app supports widgets (e.g. an App Group) that use IAP-based functionality, return the group id that allows
            // the main app and widgets to share data. For example "group.com.{developer}.{appname}". Returning nil means there's
            // no shared data
            case .appGroupBundleId: return nil
        }
    }
}
