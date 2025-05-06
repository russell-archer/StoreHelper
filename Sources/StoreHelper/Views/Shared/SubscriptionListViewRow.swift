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
    @State private var subscriptionInfo: OrderedSet<SubInfo>?
    private var products: [Product]
    private var headerText: String
    private var signPromotionalOffer: ((ProductId, String) async -> Product.PurchaseOption?)?
    private var productInfoCompletion: ((ProductId) -> Void)
    
    public init(products: [Product],
                headerText: String,
                signPromotionalOffer: ((ProductId, String) async -> Product.PurchaseOption?)? = nil,
                productInfoCompletion: @escaping ((ProductId) -> Void)) {
        
        self.products = products
        self.headerText = headerText
        self.signPromotionalOffer = signPromotionalOffer
        self.productInfoCompletion = productInfoCompletion
    }
    
    public var body: some View {
        Section(header: BodyFont(scaleFactor: storeHelper.fontScaleFactor) { Text(headerText).padding()}) {
            // For each product in the group, display as a row using SubscriptionView().
            // If a product is the highest subscription level then pass its SubscriptionInfo to SubscriptionView().
            ForEach(products, id: \.id) { product in
                SubscriptionView(productId: product.id,
                                 displayName: product.displayName,
                                 description: product.description,
                                 price: product.displayPrice,
                                 subscriptionInfo: storeHelper.subscriptionHelper.subscriptionInformation(for: product, in: subscriptionInfo),
                                 signPromotionalOffer: signPromotionalOffer,
                                 productInfoCompletion: productInfoCompletion)
                    .contentShape(Rectangle())
                    .xPlatformOnTapGesture { productInfoCompletion(product.id) }
            }
        }
        .task { subscriptionInfo = await storeHelper.subscriptionHelper.groupSubscriptionInfo()}
        .onChange(of: storeHelper.purchasedProducts) { _ in
            Task.init { subscriptionInfo = await storeHelper.subscriptionHelper.groupSubscriptionInfo()}
        }
    }
}
