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

@available(iOS 15.0, macOS 12.0, *)
public struct ProductListView: View {
    @EnvironmentObject var storeHelper: StoreHelper
    #if os(iOS)
    @Binding var showRefundSheet: Bool
    @Binding var refundRequestTransactionId: UInt64
    #endif
    
    var productInfoCompletion: ((ProductId) -> Void)
    
    public var body: some View {
        
        if storeHelper.hasProducts {
    
            if storeHelper.hasNonConsumableProducts, let nonConsumables = storeHelper.nonConsumableProducts {
                #if os(iOS)
                ProductListViewRow(showRefundSheet: $showRefundSheet, refundRequestTransactionId: $refundRequestTransactionId, products: nonConsumables, headerText: "Products", productInfoCompletion: productInfoCompletion)
                #else
                ProductListViewRow(products: nonConsumables, headerText: "Products", productInfoCompletion: productInfoCompletion)
                #endif
            }
            
            if storeHelper.hasConsumableProducts, let consumables = storeHelper.consumableProducts {
                #if os(iOS)
                ProductListViewRow(showRefundSheet: $showRefundSheet, refundRequestTransactionId: $refundRequestTransactionId, products: consumables, headerText: "VIP Services", productInfoCompletion: productInfoCompletion)
                #else
                ProductListViewRow(products: consumables, headerText: "VIP Services", productInfoCompletion: productInfoCompletion)
                #endif
            }
            
            if storeHelper.hasSubscriptionProducts, let subscriptions = storeHelper.subscriptionProducts {
                SubscriptionListViewRow(products: subscriptions, headerText: "Subscriptions", productInfoCompletion: productInfoCompletion)
            }
            
        } else {
            
            VStack {
                TitleFont(scaleFactor: storeHelper.fontScaleFactor) { Text("No products available")}.foregroundColor(.red)
                
                CaptionFont(scaleFactor: storeHelper.fontScaleFactor) { Text("This error indicates that a connection to the App Store is temporarily unavailable. Purchases you have made previously may not be available.\n\nCheck your network connectivity and try again.")}
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding()
                
                Button(action: { storeHelper.refreshProductsFromAppStore()}) {
                    BodyFont(scaleFactor: storeHelper.fontScaleFactor) { Text("Retry App Store")}
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
