//
//  ContentView.swift
//  StoreHelperDemo
//
//  Created by Russell Archer on 18/01/2022.
//

import SwiftUI
import StoreHelper

struct ContentView: View {
    @State private var showProductInfoSheet = false
    @State private var productId: ProductId = ""
    
    var body: some View {
        ScrollView {
            Purchases() { id in
                productId = id
                showProductInfoSheet = true
            }
            .sheet(isPresented: $showProductInfoSheet) {
                VStack {
                    #if os(iOS)
                    HStack {
                        Spacer()
                        Button(action: { showProductInfoSheet = false }) {
                            Image(systemName: "xmark.circle")
                                .foregroundColor(.secondary)
                        }
                        .padding(EdgeInsets(top: 10, leading: 10, bottom: 0, trailing: 10))
                    }
                    Spacer()
                    #elseif os(macOS)
                    HStack {
                        Spacer()
                        Image(systemName: "xmark.circle")
                            .foregroundColor(.secondary)
                            .padding(EdgeInsets(top: 10, leading: 10, bottom: 0, trailing: 10))
                            .onTapGesture { showProductInfoSheet = false }
                    }
                    Spacer()
                    #endif
    
                    // Pull in text and images that explain the particular product identified by `productInfoProductId`
                    ProductInfo(productInfoProductId: $productId)
                }
                #if os(macOS)
                .frame(minWidth: 700, idealWidth: 700, maxWidth: 700, minHeight: 700, idealHeight: 800, maxHeight: 900)
                .fixedSize(horizontal: true, vertical: true)
                #endif
            }
        }
    }
}
