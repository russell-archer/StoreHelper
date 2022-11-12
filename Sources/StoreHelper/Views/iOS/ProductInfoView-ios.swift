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

#if os(iOS)
@available(iOS 15.0, *)
public struct ProductInfoView: View {
    @EnvironmentObject var storeHelper: StoreHelper
    var productId: ProductId
    var displayName: String
    var productInfoCompletion: ((ProductId) -> Void)
    
    public init(productId: ProductId, displayName: String, productInfoCompletion: @escaping ((ProductId) -> Void)) {
        self.productId = productId
        self.displayName = displayName
        self.productInfoCompletion = productInfoCompletion
    }
    
    public var body: some View {
        Button(action: { productInfoCompletion(productId)}) {
            HStack {
                Image(systemName: "info.circle")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 30)
                
                SubHeadlineFont(scaleFactor: storeHelper.fontScaleFactor) { Text("Info on \"\(displayName)\"")}
                    .padding()
                    .foregroundColor(.blue)
                    .lineLimit(nil)
            }
            .padding()
        }
    }
}
#endif
