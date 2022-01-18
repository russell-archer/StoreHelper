//
//  ProductPurchaseInfo.swift
//  StoreHelper (iOS)
//
//  Created by Russell Archer on 16/01/2022.
//

import SwiftUI
import StoreKit

struct ProductPurchaseInfo: View {
    @EnvironmentObject var storeHelper: StoreHelper
    @Binding var productInfoProductId: ProductId?
    @State private var product: Product?
    
    var body: some View {
        VStack {
            HStack { Spacer() }
            ScrollView {
                VStack {
                    if let p = product {
                        Text(p.displayName).font(.largeTitle).foregroundColor(.blue)
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
            if let pid = productInfoProductId {
                product = storeHelper.product(from: pid)
            }
        }
    }
}

struct ProductInfoFlowersLarge: View {
    var body: some View {
        Text("This is a information about the **Large Flowers** product.").font(.title2).padding().multilineTextAlignment(.center)
        Text("Add text and images explaining this product here.").font(.title3).padding().multilineTextAlignment(.center)
    }
}

struct ProductInfoFlowersSmall: View {
    var body: some View {
        Text("This is a information about the **Small Flowers** product.").font(.title2).padding().multilineTextAlignment(.center)
        Text("Add text and images explaining this product here.").font(.title3).padding().multilineTextAlignment(.center)
    }
}

struct ProductInfoDefault: View {
    var body: some View {
        Text("This is generic information about a product.").font(.title2).padding().multilineTextAlignment(.center)
        Text("Add text and images explaining your product here.").font(.title3).padding().multilineTextAlignment(.center)
    }
}

