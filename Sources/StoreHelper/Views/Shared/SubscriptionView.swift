//
//  SubscriptionView.swift
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

@available(iOS 15.0, macOS 12.0, *)
public struct SubscriptionView: View {
    @EnvironmentObject var storeHelper: StoreHelper
    @State var purchaseState: PurchaseState = .unknown
    private var productId: ProductId
    private var displayName: String
    private var description: String
    private var price: String
    private var subscriptionInfo: SubscriptionInfo?  // If non-nil then the product is the highest service level product the user is subscribed to in the subscription group
    private var signPromotionalOffer: ((ProductId, String) async -> Product.PurchaseOption?)?
    private var productInfoCompletion: ((ProductId) -> Void)
    
    public init(productId: ProductId,
                displayName: String,
                description: String,
                price: String,
                subscriptionInfo: SubscriptionInfo? = nil,
                signPromotionalOffer: ((ProductId, String) async -> Product.PurchaseOption?)? = nil,
                productInfoCompletion: @escaping ((ProductId) -> Void)) {
        
        self.productId = productId
        self.displayName = displayName
        self.description = description
        self.price = price
        self.subscriptionInfo = subscriptionInfo
        self.signPromotionalOffer = signPromotionalOffer
        self.productInfoCompletion = productInfoCompletion
    }
    
    public var body: some View {
        VStack {
            LargeTitleFont(scaleFactor: storeHelper.fontScaleFactor) { Text(displayName)}.padding(5)
            SubHeadlineFont(scaleFactor: storeHelper.fontScaleFactor) { Text(description)}
                .padding(EdgeInsets(top: 0, leading: 5, bottom: 3, trailing: 5))
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .lineLimit(2)
                .contentShape(Rectangle())
                .onTapGesture { productInfoCompletion(productId) }

            Image(productId)
                .resizable()
                .frame(maxWidth: 250, maxHeight: 250)
                .aspectRatio(contentMode: .fit)
                .cornerRadius(25)
                .contentShape(Rectangle())
                .onTapGesture { productInfoCompletion(productId) }
            
            PurchaseButton(purchaseState: $purchaseState, productId: productId, price: price, signPromotionalOffer: signPromotionalOffer)
            
            if purchaseState == .purchased, subscriptionInfo != nil {
                SubscriptionInfoView(subscriptionInfo: subscriptionInfo!)
            } else {
                ProductInfoView(productId: productId, displayName: displayName, productInfoCompletion: productInfoCompletion)
            }
            
            Divider()
        }
        .task { await purchaseState(for: productId)}
        .onChange(of: storeHelper.purchasedProducts) { _ in
            Task.init { await purchaseState(for: productId) }
        }
    }
    
    public func purchaseState(for productId: ProductId) async {
        let purchased = (try? await storeHelper.isPurchased(productId: productId)) ?? false
        purchaseState = purchased ? .purchased : .notPurchased
    }
}

