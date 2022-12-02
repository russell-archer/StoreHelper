//
//  ContentView.swift
//  Shared
//
//  Created by Russell Archer on 24/01/2022.
//

import SwiftUI
import StoreHelper

@available(iOS 15.0, macOS 12.0, *)
struct ContentView: View {
    @State private var showProductInfoSheet = false
    @State private var productId: ProductId = ""
    
    var body: some View {
        ScrollView {
            Products() { id in
                productId = id
                showProductInfoSheet = true
            }
            .sheet(isPresented: $showProductInfoSheet) {
                VStack {
                    // Pull in text and images that explain the particular product identified by `productId`
                    ProductInfo(productInfoProductId: $productId, showProductInfoSheet: $showProductInfoSheet)
                }
                #if os(macOS)
                .frame(minWidth: 500, idealWidth: 500, maxWidth: 500, minHeight: 500, idealHeight: 500, maxHeight: 500)
                #endif
            }
        }
    }
}
