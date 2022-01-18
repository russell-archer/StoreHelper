//
//  Purchases.swift
//  Purchases
//
//  Created by Russell Archer on 10/09/2021.
//
// View hierachy:
// Non-Consumables: [Purchases].[ProductListView].[ProductListViewRow]......[ProductView]......[if purchased].[PurchaseInfoView].....[PurchaseInfoSheet]
// Consumables:     [Purchases].[ProductListView].[ProductListViewRow]......[ConsumableView]...[if purchased].[PurchaseInfoView].....[PurchaseInfoSheet]
// Subscriptions:   [Purchases].[ProductListView].[SubscriptionListViewRow].[SubscriptionView].[if purchased].[SubscriptionInfoView].[SubscriptionInfoSheet]

import SwiftUI
import StoreKit

struct Purchases: View {
    @State private var showManageSubscriptions = false
    @State private var showProductInfoSheet = false
    @State private var showRefundSheet = false
    @State private var refundRequestTransactionId: UInt64 = UInt64.min
    @State private var productInfoProductId: ProductId? = nil
    @State private var canMakePayments: Bool = false
    @State private var purchasesRestored: Bool = false
    @State private var showRefundAlert: Bool = false
    @State private var refundAlertText: String = ""
    
    @ViewBuilder var body: some View {
        VStack {
            ProductListView(productInfoProductId: $productInfoProductId,
                            showProductInfoSheet: $showProductInfoSheet,
                            showRefundSheet: $showRefundSheet,
                            refundRequestTransactionId: $refundRequestTransactionId)
            
            Divider()
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
            
            if !canMakePayments {
                Spacer()
                Text("Purchases are not permitted on your device.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .navigationBarTitle("Purchases", displayMode: .inline)
        .toolbar { PurchaseManagement() }
        .sheet(isPresented: $showProductInfoSheet) {
            VStack {
                HStack {
                    Spacer()
                    Button(action: { showProductInfoSheet = false }) {
                        Image(systemName: "xmark.circle")
                            .foregroundColor(.secondary)
                    }
                    .padding(EdgeInsets(top: 10, leading: 10, bottom: 0, trailing: 10))
                }
                Spacer()
                
                // Pull in text and images that explain the particular product identified by `productInfoProductId`
                ProductPurchaseInfo(productInfoProductId: $productInfoProductId)
            }
        }
        .refundRequestSheet(for: refundRequestTransactionId, isPresented: $showRefundSheet) { refundRequestStatus in
            switch(refundRequestStatus) {
                case .failure(_): refundAlertText = "Refund request submission failed"
                case .success(_): refundAlertText = "Refund request submitted successfully"
            }

            showRefundAlert.toggle()
        }
        .alert(refundAlertText, isPresented: $showRefundAlert) {
            Button("OK") { showRefundAlert.toggle()}
        }
        .onAppear { canMakePayments = AppStore.canMakePayments }
        .onChange(of: productInfoProductId) { _ in showProductInfoSheet = true }
        
        VersionInfo()
    }
}

struct Purchases_Previews: PreviewProvider {
    static var previews: some View {
        VStack(alignment: .leading) {
            HStack { Spacer() }  // Left-align subsequent views
            
            Text("Purchases").font(.largeTitle)
            ScrollView {
                Purchases()
                    .environmentObject(StoreHelper())
            }
        }
        .padding()
    }
}
