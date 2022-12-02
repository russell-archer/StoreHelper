//
//  ProductListView-macos.swift
//  StoreHelper
//
//  Created by Russell Archer on 23/07/2021.
//
// View hierachy:
// Non-Consumables: [Products].[ProductListView].[ProductListViewRow]......[ProductView]......[if purchased].[PurchaseInfoView].....[PurchaseInfoSheet]
// Consumables:     [Products].[ProductListView].[ProductListViewRow]......[ConsumableView]...[if purchased].[PurchaseInfoView].....[PurchaseInfoSheet]
// Subscriptions:   [Products].[ProductListView].[SubscriptionListViewRow].[SubscriptionView].[if purchased].[SubscriptionInfoView].[SubscriptionInfoSheet]

import SwiftUI
import StoreKit

#if os(macOS)
@available(macOS 12.0, *)
public struct ProductListView: View {
    @EnvironmentObject var storeHelper: StoreHelper
    private var signPromotionalOffer: ((ProductId, String) async -> Product.PurchaseOption?)?
    private var productInfoCompletion: ((ProductId) -> Void)
    
    public init(signPromotionalOffer: ((ProductId, String) async -> Product.PurchaseOption?)? = nil,
                productInfoCompletion: @escaping ((ProductId) -> Void)) {
        
        self.signPromotionalOffer = signPromotionalOffer
        self.productInfoCompletion = productInfoCompletion
    }
    
    public var body: some View {
        
        if storeHelper.hasProducts {
    
            if storeHelper.hasNonConsumableProducts, let nonConsumables = storeHelper.nonConsumableProducts {
                ProductListViewRow(products: nonConsumables, headerText: "Products", productInfoCompletion: productInfoCompletion)
            }
            
            if storeHelper.hasConsumableProducts, let consumables = storeHelper.consumableProducts {
                ProductListViewRow(products: consumables, headerText: "VIP Services", productInfoCompletion: productInfoCompletion)
            }
            
            if storeHelper.hasSubscriptionProducts, let subscriptions = storeHelper.subscriptionProducts {
                SubscriptionListViewRow(products: subscriptions,
                                        headerText: "Subscriptions",
                                        signPromotionalOffer: signPromotionalOffer,
                                        productInfoCompletion: productInfoCompletion)
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
                    .macOSStyle()
                    
                    Divider()
                }
            }
        }
    }
}
#endif
