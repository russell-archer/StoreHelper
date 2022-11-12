//
//  SubscriptionInfo.swift
//  StoreHelper
//
//  Created by Russell Archer on 07/08/2021.
//

import StoreKit

/// Information about the highest service level product in a subscription group a user is subscribed to.
@available(iOS 15.0, macOS 12.0, *)
public struct SubscriptionInfo: Hashable {
    public init(product: Product? = nil,
                subscriptionGroup: String? = nil,
                latestVerifiedTransaction: Transaction? = nil,
                verifiedSubscriptionRenewalInfo: Product.SubscriptionInfo.RenewalInfo? = nil,
                subscriptionStatus: Product.SubscriptionInfo.Status? = nil) {
        
        self.product = product
        self.subscriptionGroup = subscriptionGroup
        self.latestVerifiedTransaction = latestVerifiedTransaction
        self.verifiedSubscriptionRenewalInfo = verifiedSubscriptionRenewalInfo
        self.subscriptionStatus = subscriptionStatus
    }
    
    /// The product.
    public var product: Product?
    
    /// The name of the subscription group `product` belongs to.
    public var subscriptionGroup: String?
    
    /// The most recent StoreKit-verified purchase transaction for the subscription. nil if verification failed.
    public var latestVerifiedTransaction: Transaction?
    
    /// The StoreKit-verified transaction for a subscription renewal, or nil if verification failed.
    public var verifiedSubscriptionRenewalInfo:  Product.SubscriptionInfo.RenewalInfo?
    
    /// Info on the subscription.
    public var subscriptionStatus: Product.SubscriptionInfo.Status?
}
