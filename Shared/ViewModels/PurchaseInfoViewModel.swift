//
//  PurchaseInfoViewModel.swift
//  PurchaseInfoViewModel
//
//  Created by Russell Archer on 21/07/2021.
//

import StoreKit
import SwiftUI

/// ViewModel for `PurchaseInfoView`. Enables gathering of purchase or subscription information.
struct PurchaseInfoViewModel {
    
    @ObservedObject var storeHelper: StoreHelper
    var productId: ProductId
    
    /// Provides text information on the purchase of a non-consumable product or auto-renewing subscription.
    /// - Parameter productId: The `ProductId` of the product or subscription.
    /// - Returns: Returns text information on the purchase of a non-consumable product or auto-renewing subscription.
    func info(for productId: ProductId) async -> String {
        
        guard let product = storeHelper.product(from: productId) else { return "No purchase info available." }
        guard product.type != .consumable, product.type != .nonRenewable else { return "" }
        
        // Get detail purchase/subscription info on the product
        guard let info = await storeHelper.purchaseInfo(for: product) else { return "" }
        
        var text: String
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d MMM y"
        
        if info.product.type == .nonConsumable {
            guard let transaction = info.verifiedTransaction else { return "" }
            
            text = "Purchased on \(dateFormatter.string(from: transaction.purchaseDate))."
            if transaction.revocationDate != nil {
                text += " App Store revoked the purchase on \(dateFormatter.string(from: transaction.revocationDate!))."
            }
            
            return text
        }

        text = "Subscription."
        
        if let state = info.subscriptionState {
            switch state {
                case .subscribed: text += " You are currently subscribed."
                case .inGracePeriod: text += " You are subscribed, but your subscription will expire shortly."
                case .inBillingRetryPeriod: text += " You are subscribed, but the last attempt to renew failed."
                case .revoked: text += " Your subscription has been revoked."
                case .expired: text += " Your subscription has expired."
                default: text += " Your subscription state is unknown."
            }
        }
        
        if let subscription = info.product.subscription {
            var periodUnitText: String
            switch subscription.subscriptionPeriod.unit {
                    
                case .day:   periodUnitText = subscription.subscriptionPeriod.value > 1 ? String(subscription.subscriptionPeriod.value) + "days"   : "day"
                case .week:  periodUnitText = subscription.subscriptionPeriod.value > 1 ? String(subscription.subscriptionPeriod.value) + "weeks"  : "week"
                case .month: periodUnitText = subscription.subscriptionPeriod.value > 1 ? String(subscription.subscriptionPeriod.value) + "months" : "month"
                case .year:  periodUnitText = subscription.subscriptionPeriod.value > 1 ? String(subscription.subscriptionPeriod.value) + "years"  : "year"
                @unknown default: periodUnitText = "period unknown."
            }
            
            text += " Renews every \(periodUnitText)."
        }
        
        if let renewalInfo = info.verifiedSubscriptionRenewalInfo {
            text += " Auto-renew is"
            text += renewalInfo.willAutoRenew ? " on." : " off."
            
        } else {
            text += " Your renewal transaction could not be verified with the App Store."
        }
        
        if let status = info.subscriptionStatus {
            let result = storeHelper.checkVerificationResult(result: status.transaction)
            if result.verified, let renewalDate = result.transaction.expirationDate {
                text += " Renewal date is \(dateFormatter.string(from: renewalDate))."
                
                let diffComponents = Calendar.current.dateComponents([.day], from: Date(), to: renewalDate)
                if let daysLeft = diffComponents.day {
                    text += " Subscription renews in \(daysLeft)"
                    if daysLeft > 1 { text += " days." }
                    else if daysLeft == 1 { text += " day." }
                    else { text += " Subscription renews today!" }
                }
            }
        }
        
        return text
    }
}
