//
//  Configuration.swift
//  StoreHelper
//
//  Created by Russell Archer on 20/12/2021.
//

import Foundation

/// Allows the client using StoreHelper to plugin a configuration for static values required by StoreHelper.
/// Set `StoreHelper.configurationProvider` to override the default values provided by `Configuration`.
public protocol ConfigurationProvider {
    func value(configuration: Configuration) -> String?
}

/// Default config values used by StoreHelper. May be overriden. See `ConfigurationProvider`.
public enum Configuration {
    case appGroupBundleId        // The id for the container shared between the main app and widgets
    case contactUsUrl            // A URL where the user can contact the app developer.
    case requestRefund           // A URL which users on macOS can use to request a refund for an IAP.
    case restorePurchasesButton  // The text to display on the restore purchases button. If nil the button is not displayed.
    
    public func value() -> String? {
        switch self {
            // If your app supports widgets (e.g. an App Group) that use IAP-based functionality, return the group id that allows
            // the main app and widgets to share data. For example "group.com.{developer}.{appname}"
            case .appGroupBundleId:         return nil  // Returning nil means there's no shared data
            case .contactUsUrl:             return nil  // A contact URL. Used in the purchase management view
            case .requestRefund:            return "https://reportaproblem.apple.com/"  // A URL which users on macOS can use to request a refund for an IAP
            case .restorePurchasesButton:   return "Restore Purchases"
        }
    }
}

