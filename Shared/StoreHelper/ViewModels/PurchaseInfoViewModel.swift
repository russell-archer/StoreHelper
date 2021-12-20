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
    @MainActor func info(for productId: ProductId) async -> String {
        
        guard let product = storeHelper.product(from: productId) else { return "No purchase info available." }
        guard product.type != .consumable, product.type != .nonRenewable else { return "" }
        
        // Get detail purchase/subscription info on the product
        guard let info = await storeHelper.purchaseInfo(for: product) else { return "" }
        
        var text = ""
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d MMM y"
        
        if info.product.type == .nonConsumable {
            guard let transaction = info.latestVerifiedTransaction else { return "" }
            
            text = "Purchased on \(dateFormatter.string(from: transaction.purchaseDate)). Thank you 😀"
            if let revocationDate = transaction.revocationDate {
                text += " App Store revoked the purchase on \(dateFormatter.string(from: revocationDate))."
            }
        }
        
        return text
    }
}
