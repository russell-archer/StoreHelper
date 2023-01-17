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
    @State private var purchaseState: PurchaseState = .unknown
    @State private var product: Product?
    let productId = "com.rarcher.nonconsumable.flowers.large"
    
    var body: some View {
        VStack {
            Text("This view shows how to create a minimal purchase page for a product. The product shown is **Large Flowers**").multilineTextAlignment(.center)
            Image(productId)
                .resizable()
                .frame(maxWidth: 250, maxHeight: 250)
                .aspectRatio(contentMode: .fit)
                .cornerRadius(25)
            
            if let product { PurchaseButton(purchaseState: $purchaseState, productId: productId, price: product.displayPrice).padding() }
            
            switch purchaseState {
                case .purchased: Text("This product has already been purchased")
                        .font(.title)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.blue)
                        .padding()
                    
                case .notPurchased: Text("This product is available for purchase")
                        .font(.title)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.green)
                        .padding()
                    
                case .unknown: Text("The purchase state for this product has not been determined")
                        .font(.title)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.orange)
                        .padding()
                    
                default: Text("The purchase state for this product is \(purchaseState.shortDescription().lowercased())")
                        .font(.title)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.red)
                        .padding()
            }
            
            Spacer()
        }
        .padding()
        .task {
            product = storeHelper.product(from: productId)
            let isPurchased = (try? await storeHelper.isPurchased(productId: productId)) ?? false
            purchaseState = isPurchased ? .purchased : .notPurchased
        }
        .onChange(of: storeHelper.purchasedProducts) { _ in
            Task.init {
                let isPurchased = (try? await storeHelper.isPurchased(productId: productId)) ?? false
                purchaseState = isPurchased ? .purchased : .notPurchased
            }
        }
    }
}

