//
//  SubscriptionInfoViewModel.swift
//  StoreHelper
//
//  Created by Russell Archer on 07/08/2021.
//

import StoreKit
import SwiftUI

/// Extended information about a subscription product. Used for displaying info to the user
@available(iOS 15.0, macOS 12.0, *)
public struct ExtendedSubscriptionInfo: Hashable {
    public var productId: ProductId                                      // The product's unique id
    public var name: String                                              // The product's display name
    public var isPurchased: Bool                                         // true if the product has been purchased
    public var productType: Product.ProductType                          // Consumable, non-consumable, subscription, etc.
    public var subscribed: Bool?                                         // true if the product is subscribed to
    public var subscribedtext: String?                                   // Display text for the subscribed state
    public var upgraded: Bool?                                           // true if the product has been upgraded
    public var autoRenewOn: Bool?                                        // true if auto-renew is on
    public var renewalPeriod: String?                                    // Display text for the renewal period (e.g. "Every month")
    public var renewalDate: String?                                      // Display text for the renewal date
    public var renewsIn: String?                                         // Display text for when the subscription renews (e.g. "12 days")
    public var purchasePrice: String?                                    // Localized price paid when purchased
    public var purchaseDate: Date?                                       // Most recent date of purchase
    public var purchaseDateFormatted: String?                            // Most recent date of purchase formatted as "d MMM y" (e.g. "28 Dec 2021")
    public var transactionId: UInt64?                                    // Transactionid for most recent purchase. UInt64.min if not purchased
    public var revocationDate: Date?                                     // Date the app store revoked the purchase (e.g. because of a refund, etc.)
    public var revocationDateFormatted: String?                          // Date of revocation formatted as "d MMM y"
    public var revocationReason: StoreKit.Transaction.RevocationReason?  // Why the purchase was revoked (.developerIssue or .other)
    public var ownershipType: StoreKit.Transaction.OwnershipType?        // Either .purchased or .familyShared
}

@available(iOS 15.0, macOS 12.0, *)
public struct SubscriptionInfoViewModel {
    
    @ObservedObject public var storeHelper: StoreHelper
    public var subscriptionInfo: SubscriptionInfo
    
    public init(storeHelper: StoreHelper, subscriptionInfo: SubscriptionInfo) {
        self.storeHelper = storeHelper
        self.subscriptionInfo = subscriptionInfo
    }
    
    /// Extended information related to a product subscription.
    /// - Returns: Returns extended information related to a product subscription.
    @MainActor public func extendedSubscriptionInfo() async -> ExtendedSubscriptionInfo? {
        guard let product = subscriptionInfo.product else { return nil }
        
        var esi = ExtendedSubscriptionInfo(productId: product.id, name: product.displayName, isPurchased: false, productType: .autoRenewable, purchasePrice: product.displayPrice)
        esi.isPurchased = (try? await storeHelper.isPurchased(productId: product.id)) ?? false
        guard esi.isPurchased else { return esi }
        esi.subscribed = true
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d MMM y"
        
        if let state = subscriptionInfo.subscriptionStatus?.state {
            switch state {
                case .subscribed: esi.subscribedtext = "Subscribed"
                case .inGracePeriod: esi.subscribedtext =  "Subscribed. Expires shortly"
                case .inBillingRetryPeriod: esi.subscribedtext = "Subscribed. Renewal failed"
                case .revoked: esi.subscribedtext = "Subscription revoked"
                case .expired: esi.subscribedtext = "Subscription expired"
                default:
                    esi.subscribed = false
                    esi.subscribedtext = "Subscription state unknown"
            }
        }
        
        if let subscription = subscriptionInfo.product?.subscription {
            var periodUnitText: String?
            switch subscription.subscriptionPeriod.unit {
                    
                case .day:   periodUnitText = subscription.subscriptionPeriod.value > 1 ? String(subscription.subscriptionPeriod.value) + "days"   : "day"
                case .week:  periodUnitText = subscription.subscriptionPeriod.value > 1 ? String(subscription.subscriptionPeriod.value) + "weeks"  : "week"
                case .month: periodUnitText = subscription.subscriptionPeriod.value > 1 ? String(subscription.subscriptionPeriod.value) + "months" : "month"
                case .year:  periodUnitText = subscription.subscriptionPeriod.value > 1 ? String(subscription.subscriptionPeriod.value) + "years"  : "year"
                @unknown default: periodUnitText = nil
            }
            
            if let put = periodUnitText { esi.renewalPeriod = "Every \(put)"}
            else { esi.renewalPeriod = "Unknown renewal period"}
        }
        
        if let renewalInfo = subscriptionInfo.verifiedSubscriptionRenewalInfo { esi.autoRenewOn = renewalInfo.willAutoRenew }
        else { esi.autoRenewOn = false }
        
        if let latestTransaction = subscriptionInfo.latestVerifiedTransaction, let renewalDate = latestTransaction.expirationDate {
            if latestTransaction.isUpgraded { esi.upgraded = true }
            else  {
                
                esi.upgraded = false
                esi.renewalDate = dateFormatter.string(from: renewalDate)
                
                let diffComponents = Calendar.current.dateComponents([.day], from: Date(), to: renewalDate)
                if let daysLeft = diffComponents.day {
                    if daysLeft > 1 { esi.renewsIn = "\(daysLeft) days" }
                    else if daysLeft == 1 { esi.renewsIn! += "\(daysLeft) day" }
                    else { esi.renewsIn = "Today" }
                }
            }
        }
        
        // Most recent transaction
        guard let transaction = await storeHelper.mostRecentTransaction(for: product.id) else { return esi }
        esi.transactionId = transaction.id
        esi.purchaseDate = transaction.purchaseDate
        esi.purchaseDateFormatted = dateFormatter.string(from: transaction.purchaseDate)
        esi.revocationDate = transaction.revocationDate
        esi.revocationDateFormatted = transaction.revocationDate == nil ? nil : dateFormatter.string(from: transaction.revocationDate!)
        esi.revocationReason = transaction.revocationReason
        esi.ownershipType = transaction.ownershipType
        
        return esi
    }
    
    /// Text related to a product subscription in the form "Subscribed.", "Subscribed. Renews in x days.", etc.
    /// - Returns: Returns text related to a product subscription in the form "Subscribed.", "Subscribed. Renews in x days.", "Subscription cancelled. Expires date". etc.
    @MainActor public func shortInfo() async -> String {
        
        var text = ""
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d MMM y"
        
        // Is the subscription cancelled, but still valid until the expirary date?
        if let esi = await extendedSubscriptionInfo(), let autoRenewOn = esi.autoRenewOn {
            if !autoRenewOn, esi.isPurchased {
                return "Subscription cancelled. Expires \(esi.renewalDate ?? "unknown")"
            }
        } else { return "No subscription info available" }
        
        if let state = subscriptionInfo.subscriptionStatus?.state {
            switch state {
                case .subscribed: text += "Subscribed."
                case .inGracePeriod: text += "Subscribed. Expires shortly."
                case .inBillingRetryPeriod: text += "Subscribed. Renewal failed."
                case .revoked: text += "Subscription revoked."
                case .expired: text += "Subscription expired."
                default: text += "Subscription state unknown."
            }
        }
        
        if let latestTransaction = subscriptionInfo.latestVerifiedTransaction,
           let renewalDate = latestTransaction.expirationDate {
            
            if latestTransaction.isUpgraded { text += " Upgraded" }
            else  {
                
                let diffComponents = Calendar.current.dateComponents([.day], from: Date(), to: renewalDate)
                if let daysLeft = diffComponents.day {
                    if daysLeft > 1 { text += " Renews in \(daysLeft) days." }
                    else if daysLeft == 1 { text += " Renews in 1 day." }
                    else { text += " Renews today." }
                }
            }
        }
        
        return text
    }
}
