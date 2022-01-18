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
    
    #if os(macOS)
    @State private var showManagePurchases = false
    #endif
    
    @ViewBuilder var body: some View {
        VStack {
            #if os(iOS)
            ProductListView(productInfoProductId: $productInfoProductId, showProductInfoSheet: $showProductInfoSheet, showRefundSheet: $showRefundSheet, refundRequestTransactionId: $refundRequestTransactionId)
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
            ProductListView(productInfoProductId: $productInfoProductId, showProductInfoSheet: $showProductInfoSheet)
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
        .navigationBarTitle("Purchases", displayMode: .inline)
        .toolbar { PurchaseManagement() }
        #endif
        .sheet(isPresented: $showProductInfoSheet) {
            VStack {
                #if os(iOS)
                HStack {
                    Spacer()
                    Button(action: { showProductInfoSheet = false }) {
                        Image(systemName: "xmark.circle")
                            .foregroundColor(.secondary)
                    }
                    .padding(EdgeInsets(top: 10, leading: 10, bottom: 0, trailing: 10))
                }
                Spacer()
                #elseif os(macOS)
                HStack {
                    Spacer()
                    Image(systemName: "xmark.circle")
                        .foregroundColor(.secondary)
                        .padding(EdgeInsets(top: 10, leading: 10, bottom: 0, trailing: 10))
                        .onTapGesture { showProductInfoSheet = false }
                }
                Spacer()
                #endif
                
                // Pull in text and images that explain the particular product identified by `productInfoProductId`
                ProductPurchaseInfo(productInfoProductId: $productInfoProductId)
            }
            #if os(macOS)
            .frame(minWidth: 700, idealWidth: 700, maxWidth: 700, minHeight: 700, idealHeight: 700, maxHeight: 700)
            .fixedSize(horizontal: true, vertical: true)
            #endif
        }
        #if os(iOS)
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
