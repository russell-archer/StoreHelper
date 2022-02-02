//
//  ProductPurchaseInfo.swift
//  StoreHelperDemo
//
//  Created by Russell Archer on 16/01/2022.
//

import SwiftUI
import StoreHelper
import StoreKit

struct ProductInfo: View {
    @EnvironmentObject var storeHelper: StoreHelper
    @State private var product: Product?
    @Binding var productInfoProductId: ProductId
    @Binding var showProductInfoSheet: Bool
    
    var body: some View {
        VStack {
            // Provides platform-appropriate sheet close buttons and title
            SheetBarView(showSheet: $showProductInfoSheet, title: product?.displayName ?? "Product Info")
            
            ScrollView {
                VStack {
                    if let p = product {
                        // Show an image of the product
                        Image(p.id)
                            .resizable()
                            .frame(maxWidth: 200, maxHeight: 200)
                            .aspectRatio(contentMode: .fit)
                            .cornerRadius(25)
                    }
                    
                    // Pull in the text appropriate for the product
                    switch productInfoProductId {
                        case "com.rarcher.nonconsumable.flowers-large": ProductInfoFlowersLarge()
                        case "com.rarcher.nonconsumable.flowers-small": ProductInfoFlowersSmall()
                        default: ProductInfoDefault()
                    }
                }
                .padding(.bottom)
            }
        }
        .onAppear {
            product = storeHelper.product(from: productInfoProductId)
        }
    }
}

struct ProductInfoFlowersLarge: View {
    @ViewBuilder var body: some View {
        Text("This is a information about the **Large Flowers** product.").font(.title2).padding().multilineTextAlignment(.center)
        Text("Add text and images explaining this product here.").font(.title3).padding().multilineTextAlignment(.center)
    }
}

struct ProductInfoFlowersSmall: View {
    @ViewBuilder var body: some View {
        Text("This is a information about the **Small Flowers** product.").font(.title2).padding().multilineTextAlignment(.center)
        Text("Add text and images explaining this product here.").font(.title3).padding().multilineTextAlignment(.center)
    }
}

struct ProductInfoDefault: View {
    @ViewBuilder var body: some View {
        Text("This is generic information about a product.").font(.title2).padding().multilineTextAlignment(.center)
        Text("Add text and images explaining your product here.").font(.title3).padding().multilineTextAlignment(.center)
    }
}
