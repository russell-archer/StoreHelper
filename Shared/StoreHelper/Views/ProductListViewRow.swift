//
//  ProductListViewRow.swift
//  ProductListViewRow
//
//  Created by Russell Archer on 23/07/2021.
//
// View hierachy:
// Non-Consumables: [Purchases].[ProductListView].[ProductListViewRow]......[ProductView]......[if purchased].[PurchaseInfoView].....[PurchaseInfoSheet]
// Consumables:     [Purchases].[ProductListView].[ProductListViewRow]......[ConsumableView]...[if purchased].[PurchaseInfoView].....[PurchaseInfoSheet]
// Subscriptions:   [Purchases].[ProductListView].[SubscriptionListViewRow].[SubscriptionView].[if purchased].[SubscriptionInfoView].[SubscriptionInfoSheet]

import SwiftUI
import StoreKit

struct ProductListViewRow: View {
    @EnvironmentObject var storeHelper: StoreHelper
    @Binding var productInfoProductId: ProductId?
    @Binding var showProductInfoSheet: Bool
    #if os(iOS)
    @Binding var showRefundSheet: Bool
    @Binding var refundRequestTransactionId: UInt64
    #endif

    var products: [Product]
    var headerText: String
    
    var body: some View {
        Section(header: Text(headerText)) {
            if let p = products.first {
                if p.type == .consumable {
                    ForEach(products, id: \.id) { product in
                        ConsumableView(productInfoProductId: $productInfoProductId,
                                       showProductInfoSheet: $showProductInfoSheet,
                                       productId: product.id,
                                       displayName: product.displayName,
                                       description: product.description,
                                       price: product.displayPrice)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                productInfoProductId = product.id
                                showProductInfoSheet = true
                            }
                    }
                } else {
                    ForEach(products, id: \.id) { product in
                        #if os(iOS)
                        ProductView(productInfoProductId: $productInfoProductId,
                                    showProductInfoSheet: $showProductInfoSheet,
                                    showRefundSheet: $showRefundSheet,
                                    refundRequestTransactionId: $refundRequestTransactionId,
                                    productId: product.id,
                                    displayName: product.displayName,
                                    description: product.description,
                                    price: product.displayPrice)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                productInfoProductId = product.id
                                showProductInfoSheet = true
                            }
                        #elseif os(macOS)
                        ProductView(productInfoProductId: $productInfoProductId,
                                    showProductInfoSheet: $showProductInfoSheet,
                                    productId: product.id,
                                    displayName: product.displayName,
                                    description: product.description,
                                    price: product.displayPrice)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                productInfoProductId = product.id
                                showProductInfoSheet = true
                            }
                        #endif
                    }
                }
            }
        }
    }
}

