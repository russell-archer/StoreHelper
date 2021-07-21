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
    
    func info(for productId: ProductId) async -> String {
        
        guard let product = storeHelper.product(from: productId) else { return "No purchase info available." }
        guard product.type != .consumable else { return "" }
        
        return await storeHelper.purchaseInfo(for: product)
    }
}
