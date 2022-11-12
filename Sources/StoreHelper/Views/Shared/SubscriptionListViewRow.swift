//
//  SubscriptionListViewRow.swift
//  StoreHelper
//
//  Created by Russell Archer on 07/08/2021.
//
// View hierachy:
// Non-Consumables: [Products].[ProductListView].[ProductListViewRow]......[ProductView]......[if purchased].[PurchaseInfoView].....[PurchaseInfoSheet]
// Consumables:     [Products].[ProductListView].[ProductListViewRow]......[ConsumableView]...[if purchased].[PurchaseInfoView].....[PurchaseInfoSheet]
// Subscriptions:   [Products].[ProductListView].[SubscriptionListViewRow].[SubscriptionView].[if purchased].[SubscriptionInfoView].[SubscriptionInfoSheet]

import SwiftUI
import StoreKit
import OrderedCollections

@available(iOS 15.0, macOS 12.0, *)
public struct SubscriptionListViewRow: View {
    @EnvironmentObject var storeHelper: StoreHelper
    @State private var subscriptionGroups: OrderedSet<String>?
    @State private var subscriptionInfo: OrderedSet<SubscriptionInfo>?
    var products: [Product]
    var headerText: String
    var productInfoCompletion: ((ProductId) -> Void)
    
    public init(products: [Product], headerText: String, productInfoCompletion: @escaping ((ProductId) -> Void)) {
        self.products = products
        self.headerText = headerText
        self.productInfoCompletion = productInfoCompletion
    }
    
    public var body: some View {
        Section(header: Text(headerText)) {
            // For each product in the group, display as a row using SubscriptionView().
            // If a product is the highest subscription level then pass its SubscriptionInfo to SubscriptionView().
            ForEach(products, id: \.id) { product in
                SubscriptionView(productId: product.id,
                                 displayName: product.displayName,
                                 description: product.description,
                                 price: product.displayPrice,
                                 subscriptionInfo: storeHelper.subscriptionHelper.subscriptionInformation(for: product, in: subscriptionInfo),
                                 productInfoCompletion: productInfoCompletion)
                    .contentShape(Rectangle())
                    .onTapGesture { productInfoCompletion(product.id) }
            }
        }
        .task { subscriptionInfo = await storeHelper.subscriptionHelper.groupSubscriptionInfo()}
        .onChange(of: storeHelper.purchasedProducts) { _ in
            Task.init { subscriptionInfo = await storeHelper.subscriptionHelper.groupSubscriptionInfo()}
        }
    }
}
