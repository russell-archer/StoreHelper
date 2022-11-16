//
//  Products.swift
//  StoreHelper
//
//  Created by Russell Archer on 10/09/2021.
//
// View hierachy:
// Non-Consumables: [Products].[ProductListView].[ProductListViewRow]......[ProductView]......[if purchased].[PurchaseInfoView].....[PurchaseInfoSheet]
// Consumables:     [Products].[ProductListView].[ProductListViewRow]......[ConsumableView]...[if purchased].[PurchaseInfoView].....[PurchaseInfoSheet]
// Subscriptions:   [Products].[ProductListView].[SubscriptionListViewRow].[SubscriptionView].[if purchased].[SubscriptionInfoView].[SubscriptionInfoSheet]

import SwiftUI
import StoreKit

#if os(macOS)
@available(macOS 12.0, *)
public struct Products: View {
    @EnvironmentObject var storeHelper: StoreHelper
    @State private var showManageSubscriptions = false
    @State private var showRefundSheet = false
    @State private var refundRequestTransactionId: UInt64 = UInt64.min
    @State private var canMakePayments: Bool = false
    @State private var purchasesRestored: Bool = false
    @State private var showRefundAlert: Bool = false
    @State private var refundAlertText: String = ""
    @State private var showManagePurchases = false
    
    private var productInfoCompletion: ((ProductId) -> Void)
    
    public init(productInfoCompletion: @escaping ((ProductId) -> Void)) {
        self.productInfoCompletion = productInfoCompletion
    }
    
    @ViewBuilder public var body: some View {
        VStack {
            ProductListView(productInfoCompletion: productInfoCompletion)
            
            if Configuration.restorePurchasesButtonText.value(storeHelper: storeHelper) != nil {
                DisclosureGroup(isExpanded: $showManagePurchases, content: { PurchaseManagement()}, label: { Label("Manage Purchases", systemImage: "creditcard.circle")})
                    .onTapGesture { withAnimation { showManagePurchases.toggle()}}
                    .padding(EdgeInsets(top: 0, leading: 20, bottom: 5, trailing: 20))
            }
            
            if !canMakePayments {
                Spacer()
                SubHeadlineFont(scaleFactor: storeHelper.fontScaleFactor) { Text("Purchases are not permitted on your device.")}.foregroundColor(.secondary)
            }
        }
        .alert(refundAlertText, isPresented: $showRefundAlert) { Button("OK") { showRefundAlert.toggle()}}
        .onAppear { canMakePayments = AppStore.canMakePayments }
        
        VersionInfo()
    }
}
#endif
