//
//  SubscriptionHelper.swift
//  StoreHelper
//
//  Created by Russell Archer on 27/07/2021.
//

import StoreKit
import OrderedCollections
import SwiftUI

/// Helper class for subscriptions.
///
/// The methods in this class require that auto-renewing subscription product ids adopt the naming
/// convention: "com.{author}.subscription.{subscription-group-name}.{product-name}".
/// For example, "com.rarcher.subscription.vip.bronze".
///
/// Also, service level relies on the ordering of product ids within a subscription group in the
/// Products.plist file. A product appearing higher (towards the top of the group) will have a higher
/// service level than one appearing lower down. If a group has three subscription products then the
/// highest service level product will have a service level of 2, while the third product will have
/// a service level of 0.
@available(iOS 15.0, macOS 12.0, *)
public struct SubscriptionHelper {
    
    weak public var storeHelper: StoreHelper?
    
    private static let productIdSubscriptionName = "subscription"
    private static let productIdSeparator = "."
    
    public init(storeHelper: StoreHelper) {
        self.storeHelper = storeHelper
    }
    
    /// Determines the group name(s) present in the set of subscription product ids defined in Products.plist.
    /// - Returns: Returns the group name(s) present in the `OrderedSet` of subscription product ids held by `StoreHelper`.
    public func groups() -> OrderedSet<String>? {
        
        guard let store = storeHelper else { return nil }
        var subscriptionGroups = OrderedSet<String>()
        
        if let spids = store.subscriptionProductIds {
            spids.forEach { productId in
                if let group = SubscriptionHelper.groupName(from: productId) {
                    subscriptionGroups.append(group)
                }
            }
        }
        
        return subscriptionGroups.count > 0 ? subscriptionGroups : nil
    }
    
    /// Returns the set of product ids that belong to a named subscription group in order of value.
    /// - Parameter group: The group name.
    /// - Returns: Returns the set of product ids that belong to a named subscription group in order of value.
    public func subscriptions(in group: String) -> OrderedSet<ProductId>? {
        
        guard let store = storeHelper else { return nil }
        var matchedProductIds = OrderedSet<ProductId>()
        
        if let spids = store.subscriptionProductIds {
            spids.forEach { productId in
                if let matchedGroup = SubscriptionHelper.groupName(from: productId), matchedGroup.lowercased() == group.lowercased() {
                    matchedProductIds.append(productId)
                }
            }
        }
        
        return matchedProductIds.count > 0 ? matchedProductIds : nil
    }
    
    /// Extracts the name of the subscription group present in the `ProductId`.
    /// - Parameter productId: The `ProductId` from which to extract a subscription group name.
    /// - Returns: Returns the lowercased name of the subscription group present in the `ProductId`, or nil if the group name cannot be determined.
    public static func groupName(from productId: ProductId) -> String? {
        
        let components = productId.components(separatedBy: SubscriptionHelper.productIdSeparator)
        for i in 0...components.count-1 {
            if components[i].lowercased() == SubscriptionHelper.productIdSubscriptionName {
                if i+1 < components.count { return components[i+1].lowercased() }
            }
        }
        
        return nil
    }
    
    /// Information on the highest service level auto-renewing subscription the user is subscribed to
    /// in the `subscriptionGroup`.
    /// - Parameter subscriptionGroup: The name of the subscription group
    /// - Returns: Information on the highest service level auto-renewing subscription the user is
    /// subscribed to in the `subscriptionGroup`.
    ///
    /// When getting information on the highest service level auto-renewing subscription the user is
    /// subscribed to we enumerate the `Product.subscription.status` array that is a property of each
    /// `Product` in the group. Each Product in a subscription group provides access to the same
    /// `Product.SubscriptionInfo.Status` array via its `product.subscription.status` property.
    ///
    /// Enumeration of the `SubscriptionInfo.Status` array is necessary because a user may have multiple
    /// active subscriptions to products in the same subscription group. For example, a user may have
    /// subscribed themselves to the "Gold" product, as well as receiving an automatic subscription
    /// to the "Silver" product through family sharing. In this case, we'd need to return information
    /// on the "Gold" product.
    ///
    /// The `Product.subscription.status` is an array of type `[Product.SubscriptionInfo.Status]` that
    /// contains status information for ALL subscription groups. This demo app only has one subscription
    /// group, so all products in the `Product.subscription.status` array are part of the same group.
    /// In an app with two or more subscription groups you need to distinguish between groups by using
    /// the `product.subscription.subscriptionGroupID` property. Alternatively, use groupName(from:)
    /// to find the subscription group associated with a product. This will allow you to distinguish
    /// products by group and subscription service level.
    @MainActor public func subscriptionInfo(for subscriptionGroup: String) async -> SubscriptionInfo? {
        
        // Get the product ids for all the products in the subscription group.
        // Take the first id and convert it to a Product so we can access the group-common subscription.status array.
        guard let storeHelper,
              let groupProductIds = subscriptions(in: subscriptionGroup),
              let groupProductId = groupProductIds.first,
              let product = storeHelper.product(from: groupProductId),
              let subscription = product.subscription,
              let statusCollection = try? await subscription.status else { return nil }
        
        var subscriptionInfo = SubscriptionInfo()
        var highestServiceLevel: Int = -1
        var highestValueProduct: Product?
        var highestValueTransaction: StoreKit.Transaction?
        var highestValueStatus: Product.SubscriptionInfo.Status?
        var highestRenewalInfo: Product.SubscriptionInfo.RenewalInfo?
        
        for status in statusCollection {
            
            // If the user's not subscribed to this product then keep looking
            guard status.state == .subscribed else { continue }
            
            // Check the transaction verification
            let statusTransactionResult = storeHelper.checkVerificationResult(result: status.transaction)
            guard statusTransactionResult.verified else { continue }
            
            // Check the renewal info verification
            let renewalInfoResult = storeHelper.checkVerificationResult(result: status.renewalInfo)
            guard renewalInfoResult.verified else { continue }  // Subscription not verified by StoreKit so ignore it
            
            // Make sure this product is from the same subscription group as the product we're searching for
            let currentGroup = SubscriptionHelper.groupName(from: renewalInfoResult.transaction.currentProductID)
            guard currentGroup == subscriptionGroup.lowercased() else { continue }
            
            // Get the Product for this subscription
            guard let candidateSubscription = storeHelper.product(from: renewalInfoResult.transaction.currentProductID) else { continue }
            
            // We've found a valid transaction for a product in the target subscription group.
            // Is it's service level the highest we've encountered so far?
            let currentServiceLevel = subscriptionServiceLevel(in: subscriptionGroup, for: renewalInfoResult.transaction.currentProductID)
            if currentServiceLevel > highestServiceLevel {
                highestServiceLevel = currentServiceLevel
                highestValueProduct = candidateSubscription
                highestValueTransaction = statusTransactionResult.transaction
                highestValueStatus = status
                highestRenewalInfo = renewalInfoResult.transaction
            }
        }
        
        guard let selectedProduct = highestValueProduct, let selectedStatus = highestValueStatus else { return nil }
        
        subscriptionInfo.product = selectedProduct
        subscriptionInfo.subscriptionGroup = subscriptionGroup
        subscriptionInfo.latestVerifiedTransaction = highestValueTransaction
        subscriptionInfo.verifiedSubscriptionRenewalInfo = highestRenewalInfo
        subscriptionInfo.subscriptionStatus = selectedStatus
        
        return subscriptionInfo
    }
    
    /// Gets all the subscription groups from the list of subscription products.
    /// For each group, gets the highest subscription level product.
    public func groupSubscriptionInfo() async -> OrderedSet<SubscriptionInfo>? {
        
        guard let store = storeHelper else { return nil }
        var subscriptionInfoSet = OrderedSet<SubscriptionInfo>()
        let subscriptionGroups = store.subscriptionHelper.groups()
        
        if let groups = subscriptionGroups {
            subscriptionInfoSet = OrderedSet<SubscriptionInfo>()
            for group in groups {
                if let hslp = await subscriptionInfo(for: group) { subscriptionInfoSet.append(hslp) }
            }
        }
        
        return subscriptionInfoSet
    }
    
    /// Gets `SubscriptionInfo` for a product.
    /// - Parameter product: The product.
    /// - Returns: Returns `SubscriptionInfo` for a product if it is the highest service level product
    /// in the group the user is subscribed to. If the user is not subscribed to the product, or it's
    /// not the highest service level product in the group then nil is returned.
    public func subscriptionInformation(for product: Product, in subscriptionInfo: OrderedSet<SubscriptionInfo>?) -> SubscriptionInfo? {
        if let si = subscriptionInfo {
            for subInfo in si {
                if let p = subInfo.product, p.id == product.id { return subInfo }
            }
        }
        
        return nil
    }
    
    /// Provides the service level for a `ProductId` in a subscription group.
    ///
    /// Service level relies on the ordering of product ids within a subscription group in the Products.plist file.
    /// A product appearing higher (towards the top of the group) will have a higher service level than one appearing
    /// lower down. If a group has three subscription products then the highest service level product will have a
    /// service level of 2, while the third product will have a service level of 0.
    ///
    /// When stored in an `OrderedSet<ProductId>` the product id with the highest service level will be at element zero.
    /// - Parameters:
    ///   - group: The subscription group name.
    ///   - productId: The `ProductId` who's service level you require.
    /// - Returns: The service level for a `ProductId` in a subscription group, or -1 if `ProductId` cannot be found.
    public func subscriptionServiceLevel(in group: String, for productId: ProductId) -> Int {
        guard let products = subscriptions(in: group) else { return -1 }
        
        var serviceLevel = products.count-1
        for i in 0...products.count-1 {
            if products[i] == productId { return serviceLevel }
            serviceLevel -= 1
        }
        
        return -1
    }
    
    /// Determine if the user is currently subscribed to a lower-value (lower service level) subscription than the subscription provided.
    /// If so, the user may be eligible to an upgrade promotional offer. The search takes place in the same subscription group as the
    /// provided subscription.
    ///
    /// Service level relies on the ordering of product ids within a subscription group in the Products.plist file.
    /// A product appearing higher (towards the top of the group) will have a higher service level than one appearing
    /// lower down. If a group has three subscription products then the highest service level product will have a
    /// service level of 2, while the third product will have a service level of 0.
    ///
    /// When stored in an `OrderedSet<ProductId>` the product id with the highest service level will be at element zero.
    /// So, in this case we search for products above the provided product id in the `OrderedSet<ProductId>` which constitutes the
    /// collection of subscription product ids.
    /// - Parameter product: See if the user is subscribed to a lower-value subscription than this product
    /// - Returns: Returns true if the user is currently subscribed to a lower-value subscription than the subscription provided, false otherwise.
    public func hasLowerValueCurrentSubscription(than product: Product) async -> Bool {
        guard let group = SubscriptionHelper.groupName(from: product.id), let storeHelper else { return false }
        
        // Sanity check. Make sure the user's not subscribed to the provided subscription
        guard let subscribed = try? await storeHelper.isSubscribed(product: product), !subscribed else { return false }
        
        // Get all the product ids in the subscription group
        guard let products = subscriptions(in: group) else { return false }
        
        // Get the index of the provided product and make sure there service levels of lower value (higher in the collection)
        guard let indexOfProvidedProduct = products.firstIndex(of: product.id), (indexOfProvidedProduct+1) < (products.count-1) else { return false }

        // Check every lower service level product to see if the user's subscribed to it
        for i in (indexOfProvidedProduct+1)...(products.count-1) {
            if  let lowerValueProduct = storeHelper.product(from: products[i]),
                let isSubscribed = try? await storeHelper.isSubscribed(product: lowerValueProduct),
                isSubscribed { return true }
        }
        
        return false
    }
    
    /// Check all the user's transactions to see if they have ever had a subscription to the given product.
    /// - Parameter product: The product you want to search for.
    /// - Returns: Returns true if the user's transaction history has an expired subscription to the given product.
    public func isLapsedSubscriber(to product: Product) async -> Bool {
        let allTransactions = await allSubscriptionTransactions()
        
        for transaction in allTransactions {
            if transaction.productId == product.id, let expired = transaction.hasExpired, expired {
                return true
            }
        }
        
        return false
    }
    
    /// Check all the user's transactions to see if they have ever had a subscription to the given product.
    /// - Parameter productId: The unique id of the product you want to search for.
    /// - Returns: Returns true if the user's transaction history has an expired subscription to the given product.
    public func isLapsedSubscriber(to productId: ProductId) async -> Bool {
        guard let storeHelper, let pid = storeHelper.product(from: productId) else { return false }
        return await isLapsedSubscriber(to: pid)
    }
    
    /// Information on all transactions related to subscriptions in the user's transaction history, including the most recent.
    /// - Returns: Returns an ordered set of `SubscriptionTransactionInfo`, with the most recent transaction being the first element in the set.
    /// If there are no transactions related to subscriptions an empty set will be returned.
    public func allSubscriptionTransactions() async -> OrderedSet<SubscriptionTransactionInfo> {
        var transactions = OrderedSet<SubscriptionTransactionInfo>()
        guard let storeHelper else { return transactions }

        for await transaction in StoreKit.Transaction.all {
            let unwrapped = await storeHelper.checkVerificationResult(result: transaction)
            if let subscriptionTransactionInfo = await SubscriptionTransactionInfo(unwrappedTransaction: unwrapped) {
                transactions.append(subscriptionTransactionInfo)
            }
        }

        return transactions
    }
    
    public func createOfferSignature() -> String {
        return ""
    }
}
