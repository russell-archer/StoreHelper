//
//  ProductInfoView.swift
//  StoreHelper
//
//  Created by Russell Archer on 06/01/2022.
//
// View hierachy:
// Non-Consumables: [Purchases].[ProductListView].[ProductListViewRow]......[ProductView]......[if purchased].[PurchaseInfoView].....[PurchaseInfoSheet]
// Consumables:     [Purchases].[ProductListView].[ProductListViewRow]......[ConsumableView]...[if purchased].[PurchaseInfoView].....[PurchaseInfoSheet]
// Subscriptions:   [Purchases].[ProductListView].[SubscriptionListViewRow].[SubscriptionView].[if purchased].[SubscriptionInfoView].[SubscriptionInfoSheet]

import SwiftUI

struct ProductInfoView: View {
    @Binding var productInfoProductId: ProductId?
    @Binding var showProductInfoSheet: Bool
    var productId: ProductId
    var displayName: String
    
    var body: some View {
        #if os(iOS)
        Button(action: {
            productInfoProductId = productId
            showProductInfoSheet = true
        }) {
            HStack {
                Image(systemName: "info.circle")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 30)
                Text("Info on \"\(displayName)\"")
                    .font(.subheadline)
                    .foregroundColor(.blue)
                    .lineLimit(nil)
            }
            .padding()
        }
        #elseif os(macOS)
        HStack {
            Image(systemName: "info.circle")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundColor(.blue)
                .frame(height: 30)
            Text("Info on \"\(displayName)\"")
                .font(.title3)
                .foregroundColor(.blue)
                .lineLimit(nil)
        }
        .padding()
        .onTapGesture {
            productInfoProductId = productId
            showProductInfoSheet = true
        }
        #endif
    }
}

