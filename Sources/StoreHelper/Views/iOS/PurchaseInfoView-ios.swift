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
#if os(iOS)
@available(iOS 15.0, *)
public struct PurchaseInfoView: View {
    @EnvironmentObject var storeHelper: StoreHelper
    @State private var purchaseInfoText = ""
    @State private var showPurchaseInfoSheet = false
    @Binding var showRefundSheet: Bool
    @Binding var refundRequestTransactionId: UInt64
    var productId: ProductId
    
    public init(showRefundSheet: Binding<Bool>, refundRequestTransactionId: Binding<UInt64>, productId: ProductId) {
        self._showRefundSheet = showRefundSheet
        self._refundRequestTransactionId = refundRequestTransactionId
        self.productId = productId
    }
    
    public var body: some View {
        let viewModel = PurchaseInfoViewModel(storeHelper: storeHelper, productId: productId)
        
        HStack(alignment: .center) {
            Button(action: { withAnimation { showPurchaseInfoSheet.toggle()}}) {
                HStack {
                    Image(systemName: "creditcard.circle")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 30)
                    
                    SubHeadlineFont(scaleFactor: storeHelper.fontScaleFactor) { Text(purchaseInfoText)}
                        .foregroundColor(.blue)
                        .lineLimit(nil)
                }
                .padding()
            }
        }
        .task { purchaseInfoText = await viewModel.info(for: productId)}
        .sheet(isPresented: $showPurchaseInfoSheet) {
            PurchaseInfoSheet(showPurchaseInfoSheet: $showPurchaseInfoSheet, showRefundSheet: $showRefundSheet, refundRequestTransactionId: $refundRequestTransactionId, productId: productId, viewModel: viewModel)
        }
    }
}
#endif
