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

#if os(macOS)
@available(macOS 12.0, *)
public struct ProductInfoView: View {
    @EnvironmentObject var storeHelper: StoreHelper
    var productId: ProductId
    var displayName: String
    var productInfoCompletion: ((ProductId) -> Void)
    
    public var body: some View {
        HStack {
            Image(systemName: "info.circle")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundColor(.blue)
                .frame(height: 30)
            
            Title3Font(scaleFactor: storeHelper.fontScaleFactor) { Text("Info on \"\(displayName)\"")}
                .padding()
                .foregroundColor(.blue)
                .lineLimit(nil)
        }
        .padding()
        .onTapGesture { productInfoCompletion(productId)}
    }
}
#endif
