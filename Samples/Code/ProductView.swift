//
//  ProductView.swift
//  StoreHelperDemo
//
//  Created by Russell Archer on 25/01/2022.
//

import SwiftUI
import StoreHelper

@available(iOS 15.0, macOS 12.0, *)
struct ProductView: View {
    @EnvironmentObject var storeHelper: StoreHelper
    @State private var purchaseState: PurchaseState = .unknown
    var productId: ProductId
    
    var body: some View {
        VStack {
            Image(productId).bodyImage()

            switch purchaseState {
                case .purchased: Text("You have purchased this product and have full access.")
                        .font(.title)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.green)
                        .padding()
                    
                case .notPurchased: Text("Sorry, you have not purchased this product and do not have access.")
                        .font(.title)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.red)
                        .padding()
                    
                default:
                    ProgressView().padding()
                    Text("The purchase state for this product is \(purchaseState.shortDescription().lowercased())")
                        .font(.title)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.orange)
                        .padding()
            }
        }
        .padding()
        .task {
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

