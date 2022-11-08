//
//  PurchaseInfoView.swift
//  StoreHelper
//
//  Created by Russell Archer on 19/07/2021.
//
// View hierachy:
// Non-Consumables: [Products].[ProductListView].[ProductListViewRow]......[ProductView]......[if purchased].[PurchaseInfoView].....[PurchaseInfoSheet]
// Consumables:     [Products].[ProductListView].[ProductListViewRow]......[ConsumableView]...[if purchased].[PurchaseInfoView].....[PurchaseInfoSheet]
// Subscriptions:   [Products].[ProductListView].[SubscriptionListViewRow].[SubscriptionView].[if purchased].[SubscriptionInfoView].[SubscriptionInfoSheet]

import SwiftUI
import StoreKit

/// Displays information on a consumable or non-consumable purchase.
#if os(macOS)
@available(macOS 12.0, *)
public struct PurchaseInfoView: View {
    @EnvironmentObject var storeHelper: StoreHelper
    @State private var purchaseInfoText = ""
    @State private var showPurchaseInfoSheet = false
    var productId: ProductId
    
    public var body: some View {
        
        let viewModel = PurchaseInfoViewModel(storeHelper: storeHelper, productId: productId)
        
        HStack(alignment: .center) {
            Image(systemName: "creditcard.circle")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundColor(.blue)
                .frame(height: 30)
            
            Title3Font(scaleFactor: storeHelper.fontScaleFactor) { Text(purchaseInfoText)}
                .foregroundColor(.blue)
                .lineLimit(nil)
        }
        .padding()
        .onTapGesture { withAnimation { showPurchaseInfoSheet.toggle()}}
        .task { purchaseInfoText = await viewModel.info(for: productId)}
        .sheet(isPresented: $showPurchaseInfoSheet) {
            PurchaseInfoSheet(showPurchaseInfoSheet: $showPurchaseInfoSheet, productId: productId, viewModel: viewModel)
        }
    }
}
#endif
