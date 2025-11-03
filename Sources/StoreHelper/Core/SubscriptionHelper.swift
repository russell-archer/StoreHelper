//
//  SubscriptionHelper.swift
//  StoreHelper
//
//  Created by Russell Archer on 27/07/2021.
//

import StoreKit
import OrderedCollections
import SwiftUI

/// The status of a StoreKit1 or StoreKit2 subscription
public enum TransactionStatus { case purchased, subscribed, notSubscribed, notVerified, superceeded, inGracePeriod, inBillingRetryPeriod, revoked, expired, unknown
    public func shortDescription() -> String {
        switch self {
            case .purchased:            return "Purchased"
            case .subscribed:           return "Subscribed"
            case .notSubscribed:        return "Not subscribed"
            case .notVerified:           return "Not verified"
            case .superceeded:          return "Superceeded"
            case .inGracePeriod:        return "In grace period"
            case .inBillingRetryPeriod: return "In billing retry period"
            case .revoked:              return "Revoked"
            case .expired:              return "Expired"
            case .unknown:              return "Unknwon"
        }
    }
}

/// Information on a transaction update (e.g. subscription renewal, cancellation, etc.)
public struct TransactionUpdate: Hashable {
    let productId: ProductId
    let date: Date
    let status: TransactionStatus
    let transactionId: String
}

/// Holds information on a subscription group and the associated subscription products.
public struct SubscriptionGroupInfo {
    
    public var group: String
    public var productIds: OrderedSet<ProductId>
    
    public init(group: String, productIds: OrderedSet<ProductId>? = nil) {
        self.group = group
        self.productIds = productIds ?? OrderedSet<ProductId>()
    }
}

/// Helper class for auto-renewing subscriptions defined in the product definition property list (e.g. `Products.plist`).
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
///
/// Also, service level relies on the ordering of product ids within a subscription group in the
/// Products.plist file. A product appearing higher (towards the top of the group) will have a higher
/// service level than one appearing lower down. If a group has three subscription products then the
/// highest service level product will have a service level of 2, while the third product will have
/// a service level of 0.
///
@available(iOS 15.0, macOS 12.0, *)
public struct SubscriptionHelper {
    weak private var storeHelper: StoreHelper!
    private var storeConfiguration = StoreConfiguration()
    private static let productIdSubscriptionName = "subscription"
    private static let productIdSeparator = "."
    
    public init(storeHelper: StoreHelper) { self.storeHelper = storeHelper }
    
    /// Determines the subscription group names defined in Products.plist.
    /// - Returns: Returns the subscription group names defined in Products.plist.
    public func groups() -> OrderedSet<String>? {
        // Are we going to use the subscription naming convention to identify groups, or use the "Subscriptions"
        // section of the product definition file "Products.plist"?
        if let subscriptionGroupInfo = storeConfiguration.readConfiguredSubscriptionGroups() {
            // Found a "Subscriptions" section in "Products.plist"
            return OrderedSet<String>(subscriptionGroupInfo.map { group in group.group })
        }
        
        // Use the naming convention to identify subscription groups
        var subscriptionGroups = OrderedSet<String>()
        if let spids = storeHelper.subscriptionProductIds {
            spids.forEach { productId in
                if let group = groupName(from: productId) {
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
        
        // Use the subscription naming convention to identify groups, or the "Subscriptions"
        // section of the product definition file "Products.plist"?
        if let subscriptionGroupInfo = storeConfiguration.readConfiguredSubscriptionGroups() {
            // Found a "Subscriptions" section in "Products.plist"
            let targetGroups = subscriptionGroupInfo.filter { subInfo in subInfo.group == group }
            if targetGroups.count > 0, let targetGroup = targetGroups.first { return targetGroup.productIds }
        }
        
        // Use the naming convention to identify subscription groups
        var matchedProductIds = OrderedSet<ProductId>()
        if let spids = store.subscriptionProductIds {
            spids.forEach { productId in
                if let matchedGroup = groupName(from: productId), matchedGroup.lowercased() == group.lowercased() {
                    matchedProductIds.append(productId)
                }
            }
        }
        
        return matchedProductIds.count > 0 ? matchedProductIds : nil
    }
    
    /// Determines the name of the subscription group for a given `ProductId`.
    /// - Parameter productId: The `ProductId` for which you require the subscription group name.
    /// - Returns: Returns the lowercased the name of the subscription group for a given `ProductId`, or nil if the group name cannot be determined.
    public func groupName(from productId: ProductId) -> String? {
        
        // Use the subscription naming convention to identify groups, or the "Subscriptions"
        // section of the product definition file "Products.plist"?
        if let subscriptionGroupInfo = storeConfiguration.readConfiguredSubscriptionGroups() {
            // Found a "Subscriptions" section in "Products.plist". Search all product ids in all groups for a match for `productId`
            for subInfo in subscriptionGroupInfo {
                for pid in subInfo.productIds {
                    if pid == productId { return subInfo.group }
                }
            }
            
            return nil  // No match found
        }
        
        // Use the naming convention to identify the subscription group
        let components = productId.components(separatedBy: SubscriptionHelper.productIdSeparator)
        for i in 0...components.count-1 {
            if components[i].lowercased() == SubscriptionHelper.productIdSubscriptionName {
                if i+1 < components.count { return components[i+1].lowercased() }
            }
        }
        
        return nil  // No match found
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
    @MainActor public func subscriptionInfo(for subscriptionGroup: String) async -> SubInfo? {
        
        // Get the product ids for all the products in the subscription group.
        // Take the first id and convert it to a Product so we can access the group-common subscription.status array.
        guard let storeHelper,
              let groupProductIds = subscriptions(in: subscriptionGroup),
              let groupProductId = groupProductIds.first,
              let product = storeHelper.product(from: groupProductId),
              let subscription = product.subscription,
              let statusCollection = try? await subscription.status else { return nil }
        
        var subscriptionInfo = SubInfo()
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
            let currentGroup = groupName(from: renewalInfoResult.transaction.currentProductID)
            guard currentGroup?.lowercased() == subscriptionGroup.lowercased() else { continue }
            
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
    /// - Returns: For each subscription group, returns the highest subscription level auto-renewing subscription the user is subscribed to.
    public func groupSubscriptionInfo() async -> OrderedSet<SubInfo>? {
        var subscriptionInfoSet = OrderedSet<SubInfo>()
        let subscriptionGroups = groups()
        
        if let groups = subscriptionGroups {
            subscriptionInfoSet = OrderedSet<SubInfo>()
            for group in groups {
                if let hslp = await subscriptionInfo(for: group) { subscriptionInfoSet.append(hslp) }
            }
        }
        
        return subscriptionInfoSet
    }
    
    /// Gets `SubInfo` for a product.
    /// - Parameter product: The product.
    /// - Returns: Returns `SubInfo` for a product if it is the highest service level product
    /// in the group the user is subscribed to. If the user is not subscribed to the product, or it's
    /// not the highest service level product in the group then nil is returned.
    public func subscriptionInformation(for product: Product, in subscriptionInfo: OrderedSet<SubInfo>?) -> SubInfo? {
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
        guard let group = groupName(from: product.id), let storeHelper else { return false }
        
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
            if let subscriptionTransactionInfo = await SubscriptionTransactionInfo(unwrappedTransaction: unwrapped, storeHelper: storeHelper) {
                transactions.append(subscriptionTransactionInfo)
            }
        }

        return transactions
    }
    
    public func createOfferSignature() -> String {
        return ""
    }
    
    /// Gets the most recent update for a subscription and returns the status for that update.
    /// - Parameter ProductId: The subscription's ProductId.
    /// - Returns: Gets the most recent update for a subscription and returns the status for that update,
    /// or nil if the subscription has no updates.
    public func mostRecentSubscriptionUpdate(for productId: ProductId) -> TransactionStatus? {
        guard let storeHelper else { return nil }
        guard storeHelper.transactionUpdateCache.count > 0 else { return nil }
        
        let relevantUpdates = storeHelper.transactionUpdateCache.filter { $0.productId == productId }
        guard relevantUpdates.count > 0 else { return nil }
        
        let sortedUpdates = relevantUpdates.sorted { $0.date < $1.date }
        guard let mostRecent = sortedUpdates.last else { return nil }

        return mostRecent.status
    }
    
    /// Return the highest service level auto-renewing subscription the user is subscribed to in the `subscriptionGroup`.
    /// - Parameter groupName: The name of the subscription group.
    /// - Returns: Returns the `Product` for the highest service level auto-renewing subscription the user is subscribed to in the `subscriptionGroup`, or nil if the user isn't subscribed to a product in the group.
    ///
    /// When getting information on the highest service level auto-renewing subscription the user is subscribed to we enumerate the `Product.subscription.status` array that is a property of each `Product` in the group.
    /// This array is empty if the user has never subscribed to a product in this subscription group. If the user is subscribed to a product the `statusCollection.count` should be at least 1.
    /// Each `Product` in a subscription group provides access to the same `Product.SubscriptionInfo.Status` array via its `product.subscription.status` property.
    ///
    /// Enumeration of the `SubscriptionInfo.Status` array is necessary because a user may have multiple active subscriptions to products in the same subscription group. For example, a user may have
    /// subscribed themselves to the "Gold" product, as well as receiving an automatic subscription to the "Silver" product through family sharing. In this case, we'd need to return information on the "Gold" product.
    ///
    /// Also, note that even if the `Product.SubscriptionInfo.Status` collection does NOT contain a particular product `Transaction.currentEntitlements(for:)` may still report that the user has an
    /// entitlement. This can happen when upgrading or downgrading subscriptions. Because of this we always need to search the `Product.SubscriptionInfo.Status` collection for a subscribed product with a higher-value.
    ///
    @available(iOS 16.4, macOS 13.3, tvOS 16.4, *)
    @MainActor public func highestValueActiveSubscription(in group: String, with groupId: String) async -> Product? {
        // The higher the value product, the LOWER the `Product.subscription.groupLevel` value.
        // The highest value product will have a `Product.subscription.groupLevel` value of 1.
        
        // Get all the subscriptions statuses for the group
        guard let groupSubscriptionStatus = try? await Product.SubscriptionInfo.status(for: groupId) else { return nil }
        
        // Filter-out any subscription the user's not actively subscribed to
        let activeSubscriptions = groupSubscriptionStatus.filter { $0.state == .subscribed }
        guard !activeSubscriptions.isEmpty else { return nil }
        
        // Check the transaction for each subscription is verified and collect their products ids
        let verifiedActiveSubscriptionProductIds = activeSubscriptions.compactMap {
            let statusTransactionResult = storeHelper.checkVerificationResult(result: $0.transaction)
            if statusTransactionResult.verified { return statusTransactionResult.transaction.productID as ProductId } else { return nil }
        }
        
        // Get the actual `Product` objects for each active and verified subscrition
        let subscriptionProducts = storeHelper.products(from: verifiedActiveSubscriptionProductIds)
        
        // Return the active subscription with the highest value (lowest group level).
        // Important: Remember, the higher the value product, the LOWER the `Product.subscription.groupLevel` value.
        // The highest value product will have a `Product.subscription.groupLevel` value of 1.
        return subscriptionProducts.min { $0.subscription?.groupLevel ?? Int.max < $1.subscription?.groupLevel ?? Int.max }
    }
}
