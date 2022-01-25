//
//  ProductInfoView.swift
//  StoreHelper
//
//  Created by Russell Archer on 06/01/2022.
//
// View hierachy:
// Non-Consumables: [Products].[ProductListView].[ProductListViewRow]......[ProductView]......[if purchased].[PurchaseInfoView].....[PurchaseInfoSheet]
// Consumables:     [Products].[ProductListView].[ProductListViewRow]......[ConsumableView]...[if purchased].[PurchaseInfoView].....[PurchaseInfoSheet]
// Subscriptions:   [Products].[ProductListView].[SubscriptionListViewRow].[SubscriptionView].[if purchased].[SubscriptionInfoView].[SubscriptionInfoSheet]

import SwiftUI

public struct ProductInfoView: View {
    @Binding var productInfoProductId: ProductId
    var productId: ProductId
    var displayName: String
    
    public var body: some View {
        #if os(iOS)
        Button(action: {
            productInfoProductId = productId
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
        .onTapGesture { productInfoProductId = productId }
        #endif
    }
}

