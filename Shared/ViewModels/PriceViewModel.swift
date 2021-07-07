//
//  PriceViewModel.swift
//  StoreHelper
//
//  Created by Russell Archer on 23/06/2021.
//

import StoreKit
import SwiftUI

/// ViewModel for `PriceView`. Enables purchasing.
struct PriceViewModel {
    
    @ObservedObject var storeHelper: StoreHelper
    
    @Binding var purchasing: Bool
    @Binding var cancelled: Bool
    @Binding var pending: Bool
    @Binding var failed: Bool
    @Binding var purchased: Bool
    
    /// Purchase a product using StoreHelper and StoreKit2.
    /// - Parameter product: The `Product` to purchase
    func purchase(product: Product) async {

        do {
            
            let purchaseResult = try await storeHelper.purchase(product)
            if purchaseResult.transaction != nil { updatePurchaseState(newState: purchaseResult.purchaseState) }
            else { updatePurchaseState(newState: purchaseResult.purchaseState) }  // The user cancelled, or it's pending approval
            
        } catch { updatePurchaseState(newState: .failed) }  // The purchase or validation failed
    }
    
    private func updatePurchaseState(newState: StoreHelper.PurchaseState) {
        
        purchasing  = false
        cancelled   = newState == .cancelled
        pending     = newState == .pending
        failed      = newState == .failed
        purchased   = newState == .complete
    }
}
