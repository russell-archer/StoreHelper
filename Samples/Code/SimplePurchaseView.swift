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
    @State var product: Product?
    let productId = "com.rarcher.nonconsumable.flowers.large"
    
    var body: some View {
        VStack {
            Text("This view shows how to create a minimal purchase page for a product. The product shown is **Large Flowers**").multilineTextAlignment(.center)
            Image(productId)
                .resizable()
                .frame(maxWidth: 250, maxHeight: 250)
                .aspectRatio(contentMode: .fit)
                .cornerRadius(25)
            
            if let product {
                PurchaseButton(purchaseState: $purchaseState, productId: productId, price: product.displayPrice).padding()
            } else {
                Text("Unable to get Product for \(productId)")
            }
            
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
            product = storeHelper.product(from: productId)
        }
    }
}

