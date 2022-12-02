//
//  SimplePurchaseView.swift
//  StoreHelperDemo
//
//  Created by Russell Archer on 19/10/2022.
//

import SwiftUI
import StoreKit
import StoreHelper

struct SimplePurchaseView: View {
    @EnvironmentObject var storeHelper: StoreHelper
    @State var purchaseState: PurchaseState = .unknown
    var price = "1.99"
    let productId = "com.rarcher.nonconsumable.flowers.large"
    
    var body: some View {
        VStack {
            Text("This view shows how to create a minimal purchase page for a product. The product shown is **Large Flowers**").multilineTextAlignment(.center)
            Image(productId)
                .resizable()
                .frame(maxWidth: 250, maxHeight: 250)
                .aspectRatio(contentMode: .fit)
                .cornerRadius(25)
            
            PurchaseButton(purchaseState: $purchaseState, productId: productId, price: price).padding()
            
            if purchaseState == .purchased {
                Text("This product has already been purchased").multilineTextAlignment(.center)
            } else {
                Text("This product is available for purchase").multilineTextAlignment(.center)
            }
            
            Spacer()
        }
        .padding()
        .task {
            let purchased = (try? await storeHelper.isPurchased(productId: productId)) ?? false
            purchaseState = purchased ? .purchased : .unknown
        }
    }
}

