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

#if os(macOS)
@available(macOS 12.0, *)
public struct SubscriptionView: View {
    @EnvironmentObject var storeHelper: StoreHelper
    @State var purchaseState: PurchaseState = .unknown
    var productId: ProductId
    var displayName: String
    var description: String
    var price: String
    var subscriptionInfo: SubscriptionInfo?  // If non-nil then the product is the highest service level product the user is subscribed to in the subscription group
    var productInfoCompletion: ((ProductId) -> Void)
    
    public var body: some View {
        VStack {
            LargeTitleFont(scaleFactor: storeHelper.fontScaleFactor) { Text(displayName)}.padding(.bottom, 1)
            BodyFont(scaleFactor: storeHelper.fontScaleFactor) { Text(description)}
                .padding(EdgeInsets(top: 0, leading: 5, bottom: 3, trailing: 5))
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .lineLimit(2)
                .contentShape(Rectangle())
                .onTapGesture { productInfoCompletion(productId) }

            HStack {
                Image(productId)
                    .resizable()
                    .frame(maxWidth: 250, maxHeight: 250)
                    .aspectRatio(contentMode: .fit)
                    .cornerRadius(25)
                    .contentShape(Rectangle())
                    .onTapGesture { productInfoCompletion(productId) }
                
                Spacer()
                PurchaseButton(purchaseState: $purchaseState, productId: productId, price: price)
            }
            .frame(width: 500)
            .padding()
            
            if purchaseState == .purchased, subscriptionInfo != nil {
                SubscriptionInfoView(subscriptionInfo: subscriptionInfo!)
            } else {
                ProductInfoView(productId: productId, displayName: displayName, productInfoCompletion: productInfoCompletion)
            }
            
            Divider()
        }
        .padding()
        .task { await purchaseState(for: productId)}
        .onChange(of: storeHelper.purchasedProducts) { _ in
            Task.init { await purchaseState(for: productId) }
        }
    }
    
    func purchaseState(for productId: ProductId) async {
        let purchased = (try? await storeHelper.isPurchased(productId: productId)) ?? false
        purchaseState = purchased ? .purchased : .unknown
    }
}
#endif
