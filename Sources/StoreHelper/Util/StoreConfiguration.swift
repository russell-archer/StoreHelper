//
//  StoreConfiguration.swift
//  StoreHelper
//
//  Created by Russell Archer on 16/06/2021.
//

import Foundation
import OrderedCollections

/// Provides static methods for reading the contents of the product definition property list (e.g. `Products.plist`).
/// The structure of the product definition property list may take one of two alternative formats, as described below.
///
/// Format 1.
/// All in-app purchase products (consumable, non-consumable and subscription) are listed together under the top-level
/// "Products" key. When using this format all subscriptions must use the
/// `com.{author}.subscription.{subscription-group-name}.{product-name}` naming convention, so that subscription group
/// names can be determined. Other products do not need to adhere to a naming convention.
///
/// Format 2.
/// Consumable and non-consumable products are listed together under the top-level "Products" key.
/// Subscriptions are listed under the top-level "Subscriptions" key.
///
/// Example 1. Products listed together. Subscriptions must use the required naming convention:
///
/// ```
/// <?xml version="1.0" encoding="UTF-8"?>
/// <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
/// <plist version="1.0">
/// <dict>
///     <key>Products</key>
///     <array>
///         <string>com.rarcher.nonconsumable.flowers.large</string>
///         <string>com.rarcher.nonconsumable.flowers.small</string>
///         <string>com.rarcher.consumable.plant.installation</string>
///         <string>com.rarcher.subscription.vip.gold</string>
///         <string>com.rarcher.subscription.vip.silver</string>
///         <string>com.rarcher.subscription.vip.bronze</string>
///     </array>
/// </dict>
/// </plist>
/// ```
///
/// Example 2. All consumables and non-consumables listed together. Subscriptions listed separately,
/// with two subscription groups named "vip" and "standard" defined:
///
/// ```
/// <?xml version="1.0" encoding="UTF-8"?>
/// <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
/// <plist version="1.0">
/// <dict>
///     <key>Products</key>
///     <array>
///         <string>com.rarcher.nonconsumable.flowers.large</string>
///         <string>com.rarcher.nonconsumable.flowers.small</string>
///         <string>com.rarcher.consumable.plant.installation</string>
///     </array>
///     <key>Subscriptions</key>
///     <array>
///         <dict>
///             <key>Group</key>
///             <string>vip</string>
///             <key>Products</key>
///             <array>
///                 <string>com.rarcher.gold</string>
///                 <string>com.rarcher.silver</string>
///                 <string>com.rarcher.bronze</string>
///             </array>
///         </dict>
///         <dict>
///             <key>Group</key>
///             <string>standard</string>
///             <key>Products</key>
///             <array>
///                 <string>com.rarcher.sub1</string>
///                 <string>com.rarcher.sub2</string>
///                 <string>com.rarcher.sub3</string>
///             </array>
///         </dict>
///     </array>
/// </dict>
/// </plist>
/// ```
@available(iOS 15.0, macOS 12.0, *)
public struct StoreConfiguration {
    
    public init() {}
    
    /// Read the contents of the product definition property list (e.g. `Products.plist`).
    /// - Returns: Returns a set of ProductId if the list was read, nil otherwise.
    public static func readConfigFile(filename: String? = nil) -> OrderedSet<ProductId>? {
        guard let result = PropertyFile.read(filename: filename == nil ? StoreConstants.StoreConfiguration : filename!) else {
            StoreLog.event(.configurationNotFound)
            StoreLog.event(.configurationFailure)
            return nil
        }
        
        guard result.count > 0 else {
            StoreLog.event(.configurationEmpty)
            StoreLog.event(.configurationFailure)
            return nil
        }
        
        // Read the "Products" list. This can contain consumable, non-consumable and subscription products
        guard let values = result[StoreConstants.ProductsConfiguration] as? [String] else {
            StoreLog.event(.configurationEmpty)
            StoreLog.event(.configurationFailure)
            return nil
        }
        
        var productIds = OrderedSet<ProductId>(values.compactMap { $0 })

        // Do we have an optional "Subscriptions" list?
        if let subscriptions = result[StoreConstants.SubscriptionsConfiguration] as? [[String : AnyObject]] {
            for subscriptionGroup in subscriptions {
                if subscriptionGroup[StoreConstants.SubscriptionGroupConfiguration] is String {
                    if let subscriptionsInGroup = subscriptionGroup[StoreConstants.ProductsConfiguration] as? [String] {
                        for subscription in subscriptionsInGroup {
                            productIds.append(subscription)
                        }
                    }
                }
            }
        }
        
        StoreLog.event(.configurationSuccess)

        return productIds
    }
    
    /// Read the contents of the product definition property list (e.g. `Products.plist`) and returns the
    /// contents of the optional `Subscriptions` section.
    /// - Returns: Returns an array of `SubscriptionGroupInfo` that represent a subscription group and the
    /// products within it. Returns nil if the product definition property list cannot be found or it doesn't
    /// contain an optional `Subscriptions` section.
    public static func readConfiguredSubscriptionGroups(filename: String? = nil) -> [SubscriptionGroupInfo]? {
        let file = filename == nil ? StoreConstants.StoreConfiguration : filename!
        guard let result = PropertyFile.read(filename: file), result.count > 0 else { return nil }
        guard let subscriptions = result[StoreConstants.SubscriptionsConfiguration] as? [[String : AnyObject]] else { return nil }
        
        var foundSubscriptionGroups = [SubscriptionGroupInfo]()
        
        for subscriptionGroup in subscriptions {
            if let group = subscriptionGroup[StoreConstants.SubscriptionGroupConfiguration] as? String {
                if let subscriptionsInGroup = subscriptionGroup[StoreConstants.ProductsConfiguration] as? [String] {
                    var foundSubscriptionGroup = SubscriptionGroupInfo(group: group)
                    for subscription in subscriptionsInGroup { foundSubscriptionGroup.productIds.append(subscription) }
                    if group.count > 0, foundSubscriptionGroup.productIds.count > 0 { foundSubscriptionGroups.append(foundSubscriptionGroup) }
                }
            }
        }
        
        // TODO: Cache this:
        
        return foundSubscriptionGroups.count > 0 ? foundSubscriptionGroups : nil
    }
}
