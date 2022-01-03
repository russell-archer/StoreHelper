//
//  ProductListView.swift
//  ProductListView
//
//  Created by Russell Archer on 23/07/2021.
//

import SwiftUI

struct ProductListView: View {
    @EnvironmentObject var storeHelper: StoreHelper
    @Binding var productInfoProductId: ProductId?
    @Binding var showProductInfoSheet: Bool
    
    var body: some View {
        
        if storeHelper.hasProducts {
    
            if let nonConsumables = storeHelper.nonConsumableProducts, nonConsumables.count > 0 {
                ProductListViewRow(productInfoProductId: $productInfoProductId,
                                   showProductInfoSheet: $showProductInfoSheet,
                                   products: nonConsumables,
                                   headerText: "Products")
            }
            
            if let consumables = storeHelper.consumableProducts, consumables.count > 0 {
                ProductListViewRow(productInfoProductId: $productInfoProductId,
                                   showProductInfoSheet: $showProductInfoSheet,
                                   products: consumables,
                                   headerText: "VIP Services")
            }
            
            if let subscriptions = storeHelper.subscriptionProducts, subscriptions.count > 0 {
                SubscriptionListViewRow(productInfoProductId: $productInfoProductId,
                                        products: subscriptions,
                                        headerText: "Subscriptions")
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
