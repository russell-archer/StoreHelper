//
//  PurchaseInfo.swift
//  PurchaseInfo
//
//  Created by Russell Archer on 29/07/2021.
//

import StoreKit

/// Summarized information about a non-consumable or subscription purchase.
public struct PurchaseInfo {
    
    /// The product.
    var product: Product
    
    /// The StoreKit-verified transaction for a non-consumable, or nil if verification failed or the product's a subscription.
    var verifiedTransaction: Transaction?
    
    /// The StoreKit-verified transaction for a subscription, or nil if verification failed or the product's a non-consumable.
    var verifiedSubscriptionRenewalInfo:  Product.SubscriptionInfo.RenewalInfo?
    
    /// Info on the subscription, or nil if the product's not a subscription.
    var subscriptionStatus: Product.SubscriptionInfo.Status?
    
    /// The renewal state of the subscription (e.g. subscribed, revoked, expired), or nil if the product's not a subscription.
    var subscriptionState: Product.SubscriptionInfo.RenewalState?
    
    /// The name of the subscription group the product belongs to, or nil if the product's not a subscription.
    var subscriptionGroup: String?
}

