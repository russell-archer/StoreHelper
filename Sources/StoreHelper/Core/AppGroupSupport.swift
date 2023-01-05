//
//  AppGroupSupport.swift
//  StoreHelper
//
//  Created by Russell Archer on 20/12/2021.
//
//  Notes on intermittent UserDefaults error. From time to time you may see the following error:
//
//      [User Defaults] Couldn't read values in CFPrefsPlistSource<0x600003da5000>
//      (Domain: group.com.{developer}.{app}, User: kCFPreferencesAnyUser, ByHost: Yes, Container: (null), Contents Need Refresh: Yes):
//      Using kCFPreferencesAnyUser with a container is only allowed for System Containers, detaching from cfprefsd
//
//  It implies that attempts to read/write from the shared AppGroup UserDefaults suite have failed, when they actually haven't.
//  According to the Apple engineer who works/worked on this it is a spurious warning message and can be ignored.
//  See: https://twitter.com/Catfish_Man/status/784460565972332544

import SwiftUI

@available(iOS 15.0, macOS 12.0, *)
public struct AppGroupSupport {
    private static var widgetConfigurationOverrides: [String : AnyObject]?
    
    public static func syncPurchase(productId: String, purchased: Bool) {
        // Update UserDefaults in the container shared between ourselves and other members of the group.com.{developer}.{appname} AppGroup.
        // Currently this is done so that widgets can tell what IAPs have been purchased. Note that widgets can't use StoreHelper directly
        // because the they don't purchase anything and are not considered to be part of the app that did the purchasing as far as
        // StoreKit is concerned.
        if widgetConfigurationOverrides == nil { widgetConfigurationOverrides = readConfigurationOverride() }
        guard let id = Configuration.appGroupBundleId.stringValue(overrides: widgetConfigurationOverrides) else { return }
        if let defaults = UserDefaults(suiteName: id) { defaults.set(purchased, forKey: productId)}
    }
    
    public static func isPurchased(productId: String) -> Bool {
        if widgetConfigurationOverrides == nil { widgetConfigurationOverrides = readConfigurationOverride() }
        guard let id = Configuration.appGroupBundleId.stringValue(overrides: widgetConfigurationOverrides) else { return false }
        var purchased = false
        if let defaults = UserDefaults(suiteName: id) { purchased = defaults.bool(forKey: productId)}
        return purchased
    }
    
    /// Read the property list provided by the host app that overrides StoreHelper default values.
    /// - Returns: Returns a dictionary of key-value pairs, or nil if the configuration plist file cannot be found.
    private static func readConfigurationOverride() -> [String : AnyObject]? { PropertyFile.read(filename: StoreConstants.Configuration) }
}
