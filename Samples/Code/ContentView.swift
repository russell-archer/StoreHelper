//
//  ContentView.swift
//  Shared
//
//  Created by Russell Archer on 24/01/2022.
//

import SwiftUI
import StoreKit
import StoreHelper

/// `ContentView` displays the `Products` view, which is responsible for displaying a list of available products, along with
/// purchase buttons and a button to enable users to manually restore previous purchases.
///
/// For notes on signing promotional subscription offers see the section on **"Introductory and Promotional Subscription Offers"**
/// in the [StoreHelper Guide](https://github.com/russell-archer/StoreHelper/blob/main/Documentation/guide.md).
///
@available(iOS 15.0, macOS 12.0, *)
struct ContentView: View {
    @State private var showProductInfoSheet = false
    @State private var productId: ProductId = ""
    
    var body: some View {
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
