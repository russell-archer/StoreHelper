//
//  PurchaseInfoView.swift
//  PurchaseInfoView
//
//  Created by Russell Archer on 19/07/2021.
//
// View hierachy:
// Non-Consumables: [Purchases].[ProductListView].[ProductListViewRow]......[ProductView]......[if purchased].[PurchaseInfoView].....[PurchaseInfoSheet]
// Consumables:     [Purchases].[ProductListView].[ProductListViewRow]......[ConsumableView]...[if purchased].[PurchaseInfoView].....[PurchaseInfoSheet]
// Subscriptions:   [Purchases].[ProductListView].[SubscriptionListViewRow].[SubscriptionView].[if purchased].[SubscriptionInfoView].[SubscriptionInfoSheet]

import SwiftUI
import StoreKit

/// Displays information on a consumable or non-consumable purchase.
struct PurchaseInfoView: View {
    @EnvironmentObject var storeHelper: StoreHelper
    @State private var purchaseInfoText = ""
    @State private var showPurchaseInfoSheet = false
    #if os(iOS)
    @Binding var showRefundSheet: Bool
    @Binding var refundRequestTransactionId: UInt64
    #endif
    var productId: ProductId
    
    var body: some View {
        
        let viewModel = PurchaseInfoViewModel(storeHelper: storeHelper, productId: productId)
        
        #if os(iOS)
        HStack(alignment: .center) {
            Button(action: { withAnimation { showPurchaseInfoSheet.toggle()}}) {
                HStack {
                    Image(systemName: "creditcard.circle")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 30)
                    
                    Text(purchaseInfoText)
                        .font(.subheadline)
                        .foregroundColor(.blue)
                        .lineLimit(nil)
                }
                .padding()
            }
        }
        .onAppear {
            Task.init { purchaseInfoText = await viewModel.info(for: productId) }
        }
        .sheet(isPresented: $showPurchaseInfoSheet) {
            PurchaseInfoSheet(showPurchaseInfoSheet: $showPurchaseInfoSheet, showRefundSheet: $showRefundSheet, refundRequestTransactionId: $refundRequestTransactionId, productId: productId, viewModel: viewModel)
        }
        #elseif os(macOS)
        HStack(alignment: .center) {
            Image(systemName: "creditcard.circle")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundColor(.blue)
                .frame(height: 30)
            
            Text(purchaseInfoText)
                .font(.title3)
                .foregroundColor(.blue)
                .lineLimit(nil)
        }
        .padding()
        .onTapGesture { withAnimation { showPurchaseInfoSheet.toggle()}}
        .onAppear {
            Task.init { purchaseInfoText = await viewModel.info(for: productId) }
        }
        .sheet(isPresented: $showPurchaseInfoSheet) {
            PurchaseInfoSheet(showPurchaseInfoSheet: $showPurchaseInfoSheet, productId: productId, viewModel: viewModel)
        }
        #endif
    }
}
