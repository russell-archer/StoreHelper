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

#if os(iOS)
@available(iOS 15.0, *)
public struct ProductListView: View {
    @EnvironmentObject var storeHelper: StoreHelper
    @Binding var showRefundSheet: Bool
    @Binding var refundRequestTransactionId: UInt64
    
    var productInfoCompletion: ((ProductId) -> Void)
    
    public var body: some View {
        
        if storeHelper.hasProducts {
    
            if storeHelper.hasNonConsumableProducts, let nonConsumables = storeHelper.nonConsumableProducts {
                ProductListViewRow(showRefundSheet: $showRefundSheet, refundRequestTransactionId: $refundRequestTransactionId, products: nonConsumables, headerText: "Products", productInfoCompletion: productInfoCompletion)
            }
            
            if storeHelper.hasConsumableProducts, let consumables = storeHelper.consumableProducts {
                ProductListViewRow(showRefundSheet: $showRefundSheet, refundRequestTransactionId: $refundRequestTransactionId, products: consumables, headerText: "VIP Services", productInfoCompletion: productInfoCompletion)
            }
            
            if storeHelper.hasSubscriptionProducts, let subscriptions = storeHelper.subscriptionProducts {
                SubscriptionListViewRow(products: subscriptions, headerText: "Subscriptions", productInfoCompletion: productInfoCompletion)
            }
            
        } else {
            
            if storeHelper.isRefreshingProducts {
                VStack {
                    Text("Getting products from the App Store...").font(.subheadline)
                    ProgressView()
                }
                .padding()
                
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
                    .buttonStyle(.borderedProminent).padding()
                    
                    Divider()
                }
            }
        }
    }
}
#endif
