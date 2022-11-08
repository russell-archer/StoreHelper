//
//  ProductListViewRow.swift
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
@available(iOS 15.0, macOS 12.0, *)
public struct ProductListViewRow: View {
    @EnvironmentObject var storeHelper: StoreHelper

    var products: [Product]
    var headerText: String
    var productInfoCompletion: ((ProductId) -> Void)
    
    public var body: some View {
        Section(content: {
            if let p = products.first {
                if p.type == .consumable {
                    ForEach(products, id: \.id) { product in
                        ConsumableView(productId: product.id,
                                       displayName: product.displayName,
                                       description: product.description,
                                       price: product.displayPrice,
                                       productInfoCompletion: productInfoCompletion)
                        .contentShape(Rectangle())
                        .onTapGesture { productInfoCompletion(product.id)}
                    }
                } else {
                    ForEach(products, id: \.id) { product in
                        ProductView(productId: product.id,
                                    displayName: product.displayName,
                                    description: product.description,
                                    price: product.displayPrice,
                                    productInfoCompletion: productInfoCompletion)
                        .contentShape(Rectangle())
                        .onTapGesture { productInfoCompletion(product.id) }
                    }
                }
            }
        }, header: { BodyFont(scaleFactor: storeHelper.fontScaleFactor) { Text(headerText)}})
    }
}
#endif
