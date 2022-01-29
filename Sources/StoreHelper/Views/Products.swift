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

public struct Products: View {
    @State private var showManageSubscriptions = false
    @State private var showRefundSheet = false
    @State private var refundRequestTransactionId: UInt64 = UInt64.min
    @State private var canMakePayments: Bool = false
    @State private var purchasesRestored: Bool = false
    @State private var showRefundAlert: Bool = false
    @State private var refundAlertText: String = ""
    @State private var productInfoProductId: ProductId = ""
    
    private var productInfoCompletion: ((ProductId) -> Void)
    
    #if os(macOS)
    @State private var showManagePurchases = false
    #endif
    
    public init(productInfoCompletion: @escaping ((ProductId) -> Void)) {
        self.productInfoCompletion = productInfoCompletion
    }
    
    @ViewBuilder public var body: some View {
        VStack {
            #if os(iOS)
            ProductListView(productInfoProductId: $productInfoProductId, showRefundSheet: $showRefundSheet, refundRequestTransactionId: $refundRequestTransactionId)
            Button(purchasesRestored ? "Purchases Restored" : "Restore Purchases") {
                Task.init {
                    try? await AppStore.sync()
                    purchasesRestored = true
                }
            }
            .buttonStyle(.borderedProminent).padding()
            .disabled(purchasesRestored)
            
            Text("Manually restoring previous purchases is not normally necessary. Tap \"Restore Purchases\" only if this app does not correctly identify your previous purchases. You will be prompted to authenticate with the App Store. Note that this app does not have access to credentials used to sign-in to the App Store.")
                .font(.caption2)
                .multilineTextAlignment(.center)
                .padding(EdgeInsets(top: 0, leading: 10, bottom: 10, trailing: 10))
                .foregroundColor(.secondary)
            
            #elseif os(macOS)
            ProductListView(productInfoProductId: $productInfoProductId)
            DisclosureGroup(isExpanded: $showManagePurchases, content: { PurchaseManagement()}, label: { Label("Manage Purchases", systemImage: "creditcard.circle")})
                .onTapGesture { withAnimation { showManagePurchases.toggle()}}
                .padding(EdgeInsets(top: 0, leading: 20, bottom: 5, trailing: 20))
            #endif
            
            if !canMakePayments {
                Spacer()
                Text("Purchases are not permitted on your device.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        #if os(iOS)
        .navigationBarTitle("Available Products", displayMode: .inline)
        .toolbar { PurchaseManagement() }
        .refundRequestSheet(for: refundRequestTransactionId, isPresented: $showRefundSheet) { refundRequestStatus in
            switch(refundRequestStatus) {
                case .failure(_): refundAlertText = "Refund request submission failed"
                case .success(_): refundAlertText = "Refund request submitted successfully"
            }

            showRefundAlert.toggle()
        }
        #endif
        .alert(refundAlertText, isPresented: $showRefundAlert) {
            Button("OK") { showRefundAlert.toggle()}
        }
        .onAppear { canMakePayments = AppStore.canMakePayments }
        .onChange(of: productInfoProductId) { _ in
            guard productInfoProductId.count > 0 else { return }
            productInfoCompletion(productInfoProductId)
        }
        
        VersionInfo()
    }
}

