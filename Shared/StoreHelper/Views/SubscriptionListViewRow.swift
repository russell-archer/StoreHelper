//
//  SubscriptionListViewRow.swift
//  SubscriptionListViewRow
//
//  Created by Russell Archer on 07/08/2021.
//
// View hierachy:
// Non-Consumables: [Purchases].[ProductListView].[ProductListViewRow]......[ProductView]......[if purchased].[PurchaseInfoView].....[PurchaseInfoSheet]
// Consumables:     [Purchases].[ProductListView].[ProductListViewRow]......[ConsumableView]...[if purchased].[PurchaseInfoView].....[PurchaseInfoSheet]
// Subscriptions:   [Purchases].[ProductListView].[SubscriptionListViewRow].[SubscriptionView].[if purchased].[SubscriptionInfoView].[SubscriptionInfoSheet]

import SwiftUI
import StoreKit
import OrderedCollections

struct SubscriptionListViewRow: View {
    @EnvironmentObject var storeHelper: StoreHelper
    @State private var subscriptionGroups: OrderedSet<String>?
    @State private var subscriptionInfo: OrderedSet<SubscriptionInfo>?
    @Binding var productInfoProductId: ProductId?
    @Binding var showProductInfoSheet: Bool
    var products: [Product]
    var headerText: String
    
    var body: some View {
        Section(header: Text(headerText)) {
            // For each product in the group, display as a row using SubscriptionView().
            // If a product is the highest subscription level then pass its SubscriptionInfo to SubscriptionView().
            ForEach(products, id: \.id) { product in
                SubscriptionView(productInfoProductId: $productInfoProductId,
                                 showProductInfoSheet: $showProductInfoSheet,
                                 productId: product.id,
                                 displayName: product.displayName,
                                 description: product.description,
                                 price: product.displayPrice,
                                 subscriptionInfo: storeHelper.subscriptionHelper.subscriptionInformation(for: product, in: subscriptionInfo))
                    .contentShape(Rectangle())
                    .onTapGesture { productInfoProductId = product.id }
            }
        }
        .onAppear {
            Task.init { subscriptionInfo = await storeHelper.subscriptionHelper.groupSubscriptionInfo()}
        }
        .onChange(of: storeHelper.purchasedProducts) { _ in
            Task.init { subscriptionInfo = await storeHelper.subscriptionHelper.groupSubscriptionInfo()}
        }
    }
}
