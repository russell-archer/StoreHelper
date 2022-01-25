//
//  ProductListView.swift
//  StoreHelper
//
//  Created by Russell Archer on 23/07/2021.
//
// View hierachy:
// Non-Consumables: [Products].[ProductListView].[ProductListViewRow]......[ProductView]......[if purchased].[PurchaseInfoView].....[PurchaseInfoSheet]
// Consumables:     [Products].[ProductListView].[ProductListViewRow]......[ConsumableView]...[if purchased].[PurchaseInfoView].....[PurchaseInfoSheet]
// Subscriptions:   [Products].[ProductListView].[SubscriptionListViewRow].[SubscriptionView].[if purchased].[SubscriptionInfoView].[SubscriptionInfoSheet]

import SwiftUI

public struct ProductListView: View {
    @EnvironmentObject var storeHelper: StoreHelper
    @Binding var productInfoProductId: ProductId
    #if os(iOS)
    @Binding var showRefundSheet: Bool
    @Binding var refundRequestTransactionId: UInt64
    #endif
    
    public var body: some View {
        
        if storeHelper.hasProducts {
    
            if storeHelper.hasNonConsumableProducts, let nonConsumables = storeHelper.nonConsumableProducts {
                #if os(iOS)
                ProductListViewRow(productInfoProductId: $productInfoProductId, showRefundSheet: $showRefundSheet, refundRequestTransactionId: $refundRequestTransactionId, products: nonConsumables, headerText: "Products")
                #elseif os(macOS)
                ProductListViewRow(productInfoProductId: $productInfoProductId, products: nonConsumables, headerText: "Products")
                #endif
            }
            
            if storeHelper.hasConsumableProducts, let consumables = storeHelper.consumableProducts {
                #if os(iOS)
                ProductListViewRow(productInfoProductId: $productInfoProductId, showRefundSheet: $showRefundSheet, refundRequestTransactionId: $refundRequestTransactionId, products: consumables, headerText: "VIP Services")
                #elseif os(macOS)
                ProductListViewRow(productInfoProductId: $productInfoProductId, products: consumables, headerText: "VIP Services")
                #endif
            }
            
            if storeHelper.hasSubscriptionProducts, let subscriptions = storeHelper.subscriptionProducts {
                SubscriptionListViewRow(productInfoProductId: $productInfoProductId, products: subscriptions, headerText: "Subscriptions")
            }
            
        } else {
            
            VStack {
                Text("No products available")
                    .font(.title)
                    .foregroundColor(.red)
                
                Text("This error indicates that a connection to the App Store is temporarily unavailable. Purchases you have made previously may not be available.\n\nCheck your network connectivity and try again.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding()
                
                Button("Retry App Store") {
                    storeHelper.refreshProductsFromAppStore()
                }
                #if os(iOS)
                .buttonStyle(.borderedProminent).padding()
                #elseif os(macOS)
                .macOSStyle()
                #endif
                
                Divider()
            }
        }
    }
}
