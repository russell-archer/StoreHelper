//
//  ContentView.swift
//  Shared
//
//  Created by Russell Archer on 24/01/2022.
//

import SwiftUI
import StoreHelper

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
                    ProductInfo(productInfoProductId: $productId)
                }
                #if os(macOS)
                .frame(minWidth: 700, idealWidth: 700, maxWidth: 700, minHeight: 700, idealHeight: 800, maxHeight: 900)
                #endif
            }
        }
    }
}

