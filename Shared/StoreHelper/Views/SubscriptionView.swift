//
//  SubscriptionView.swift
//  SubscriptionView
//
//  Created by Russell Archer on 07/08/2021.
//

import SwiftUI

struct SubscriptionView: View {
    
    @EnvironmentObject var storeHelper: StoreHelper
    @State var purchaseState: PurchaseState = .unknown
    
    var productId: ProductId
    var displayName: String
    var description: String
    var price: String
    var subscriptionInfo: SubscriptionInfo?  // If non-nil then the product is the highest service level product the user is subscribed to in the subscription group
    
    var body: some View {
        VStack {
            HStack {
                Image(productId)
                    .resizable()
                    .frame(width: 75, height: 80)
                    .aspectRatio(contentMode: .fit)
                    .cornerRadius(25)
                
                Text(displayName)
                    .font(.headline)
                    .padding()
                
                Spacer()
                
                PurchaseButton(purchaseState: $purchaseState, productId: productId, price: price)
            }
            
            Text(description)
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .foregroundColor(.gray)
                .lineLimit(2)
            
            if purchaseState == .purchased, subscriptionInfo != nil {
                SubscriptionInfoView(subscriptionInfo: subscriptionInfo!)
            }
        }
        .padding()
        .onAppear {
            Task.init { await purchaseState(for: productId) }
        }
        .onChange(of: storeHelper.purchasedProducts) { _ in
            Task.init { await purchaseState(for: productId) }
        }
    }
    
    func purchaseState(for productId: ProductId) async {
        let purchased = (try? await storeHelper.isPurchased(productId: productId)) ?? false
        purchaseState = purchased ? .purchased : .unknown
    }
}
