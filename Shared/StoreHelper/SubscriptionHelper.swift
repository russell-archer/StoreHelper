//
//  StoreHelper+Subscription.swift
//  StoreHelper+Subscription
//
//  Created by Russell Archer on 27/07/2021.
//
//  Subscription-related methods

import StoreKit
import OrderedCollections

/// StoreHelper helper class methods releated to subscriptions.
///
/// The methods in this class require that auto-renewing subscription product ids adopt
/// a naming convention with the format: "com.{author}.subscription.{subscription-name}.{product-name}".
/// For example, "com.rarcher.subscription.vip.bronze".
public struct SubscriptionHelper {
    
    private static let productIdSubscriptionName = "subscription"
    private static let productIdSeparator = "."
    
    /// Determines the group name(s) present in an `OrderedSet`.
    /// - Parameter productIds: `OrderedSet` of `ProductId`.
    /// - Returns: Returns the group name(s) present in an `OrderedSet` of `ProductId`.
    public static func groups(productIds: OrderedSet<ProductId>) -> OrderedSet<String>? {
        
        var subscriptionGroups = OrderedSet<String>()
        productIds.forEach { productId in
            if let group = SubscriptionHelper.groupName(from: productId) {
                subscriptionGroups.append(group)
            }
        }
        
        return subscriptionGroups.count > 0 ? subscriptionGroups : nil
    }
    
    /// Given a super-set of product ids, returns the set of product ids that belong to a named subscription group in order of value.
    /// - Parameter group: The group name.
    /// - Parameter productIds: An `OrderedSet` of `ProductId`
    /// - Returns: Returns the set of product ids that belong to a named subscription group in order of value.
    public static func products(in group: String, with productIds: OrderedSet<ProductId>) -> OrderedSet<ProductId>? {
        
        var matchedProductIds = OrderedSet<ProductId>()
        productIds.forEach { productId in
            if let matchedGroup = SubscriptionHelper.groupName(from: productId), matchedGroup.lowercased() == group.lowercased() {
                matchedProductIds.append(productId)
            }
        }
        
        return matchedProductIds.count > 0 ? matchedProductIds : nil
    }
    
    /// Extracts the name of the subscription group present in the `ProductId`.
    /// - Parameter productId: The `ProductId` from which to extract a subscription group name.
    /// - Returns: Returns the name of the subscription group present in the `ProductId`.
    public static func groupName(from productId: ProductId) -> String? {
        
        let components = productId.components(separatedBy: productIdSeparator)
        for i in 0...components.count-1 {
            if components[i].lowercased() == productIdSubscriptionName {
                if i+1 < components.count { return components[i+1] }
            }
        }
        
        return nil
    }
    
    /// Provides the relative value index for a `ProductId` in a subscription group.
    ///
    /// The value index is simply the placing of a `ProductId` in a subscription group in the Products.plist file.
    /// A product appearing higher (towards the top of the file) will have a higher value than one appearing subsequently.
    /// If a group has three subscription products then the highest value product will have an index value of 2, while
    /// the third product will have an index of 0.
    /// - Parameters:
    ///   - group: The subscription group name.
    ///   - productId: The `ProductId` who's value you require.
    ///   - productIds: A super- set of product ids which contains the required `ProductId`.
    /// - Returns: Returns the relative value index for a `ProductId` in a subscription group, or -1 if the `ProductId` cannot
    /// be found in the `OrderedSet<ProductId>`.
    public static func productValueIndex(in group: String, for productId: ProductId, with productIds: OrderedSet<ProductId>) -> Int {

        guard let products = SubscriptionHelper.products(in: group, with: productIds) else { return -1 }
        
        var index = products.count-1
        for i in 0...products.count-1 {
            if products[i] == productId { return index }
            index -= 1
        }
        
        return -1
    }
}

