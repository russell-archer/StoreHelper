//
//  PurchaseInfoSheet.swift
//  StoreHelper
//
//  Created by Russell Archer on 05/01/2022.
//
// View hierachy:
// Non-Consumables: [Products].[ProductListView].[ProductListViewRow]......[ProductView]......[if purchased].[PurchaseInfoView].....[PurchaseInfoSheet]
// Consumables:     [Products].[ProductListView].[ProductListViewRow]......[ConsumableView]...[if purchased].[PurchaseInfoView].....[PurchaseInfoSheet]
// Subscriptions:   [Products].[ProductListView].[SubscriptionListViewRow].[SubscriptionView].[if purchased].[SubscriptionInfoView].[SubscriptionInfoSheet]

import SwiftUI

public struct PurchaseInfoSheet: View {
    @State private var extendedPurchaseInfo: ExtendedPurchaseInfo?
    @Binding var showPurchaseInfoSheet: Bool
    #if os(iOS)
    @Binding var showRefundSheet: Bool
    @Binding var refundRequestTransactionId: UInt64
    #endif
    var productId: ProductId
    var viewModel: PurchaseInfoViewModel
    
    public var body: some View {
        VStack {
            SheetBarView(showSheet: $showPurchaseInfoSheet, title: "Purchase Information", sysImage: "creditcard.circle")
            
            Image(productId)
                .resizable()
                .frame(maxWidth: 85, maxHeight: 85)
                .aspectRatio(contentMode: .fit)
                .cornerRadius(25)
            
            Label("Purchase Information", systemImage: "creditcard.circle")
                .font(.largeTitle)
                .foregroundColor(.blue)
                .padding(EdgeInsets(top: 5, leading: 5, bottom: 0, trailing: 5))            
            
            ScrollView {
                if let epi = extendedPurchaseInfo, epi.isPurchased {
                    
                    VStack {
                        PurchaseInfoFieldView(fieldName: "Product name:", fieldValue: epi.name)
                        PurchaseInfoFieldView(fieldName: "Product ID:", fieldValue: epi.productId)
                        PurchaseInfoFieldView(fieldName: "Price:", fieldValue: epi.purchasePrice ?? "Unknown")
                        
                        if epi.productType == .nonConsumable {
                            PurchaseInfoFieldView(fieldName: "Date:", fieldValue: epi.purchaseDateFormatted ?? "Unknown")
                            PurchaseInfoFieldView(fieldName: "Transaction:", fieldValue: String(epi.transactionId ?? UInt64.min))
                            PurchaseInfoFieldView(fieldName: "Purchase type:", fieldValue: epi.ownershipType == nil ? "Unknown" : (epi.ownershipType! == .purchased ? "Personal purchase" : "Family sharing"))
                            PurchaseInfoFieldView(fieldName: "Notes:", fieldValue: "\(epi.revocationDate == nil ? "-" : "Purchased revoked \(epi.revocationDateFormatted ?? "") \(epi.revocationReason == .developerIssue ? "(developer issue)" : "(other issue)")")")
                            
                        } else {
                            Text("No additional purchase information available")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(EdgeInsets(top: 1, leading: 5, bottom: 0, trailing: 5))
                        }
                    }
                    
                    Divider().padding(.bottom)
                    
                    #if os(iOS)
                    Button(action: {
                        if Utils.isSimulator() { StoreLog.event("Warning: You cannot request refunds from the simulator. You must use the sandbox environment.")}
                        if let tid = epi.transactionId {
                            refundRequestTransactionId = tid
                            withAnimation { showRefundSheet.toggle()}
                        }
                    }) { Label("Request Refund", systemImage: "creditcard.circle")}.buttonStyle(.borderedProminent)
                    #elseif os(macOS)
                    Button(action: {
                        NSWorkspace.shared.open(URL(string: Storage.requestRefund.value()!)!)
                    }) { Label("Request Refund", systemImage: "creditcard.circle")}.macOSStyle()
                    #endif
                    
                    Text("You may request a refund from the App Store if a purchase does not perform as expected. This requires you to authenticate with the App Store. Note that this app does not have access to credentials used to sign-in to the App Store.")
                        .font(.caption2)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                        .padding()
                    
                } else {
                    Text("No purchase information available")
                        .font(.title)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding(EdgeInsets(top: 1, leading: 5, bottom: 0, trailing: 5))
                }
            }
        }
        .onAppear { Task.init { extendedPurchaseInfo = await viewModel.extendedPurchaseInfo(for: productId)}}
        #if os(macOS)
        .frame(minWidth: 650, idealWidth: 650, maxWidth: 650, minHeight: 650, idealHeight: 650, maxHeight: 650)
        .fixedSize(horizontal: true, vertical: true)
        #endif
    }
}

struct PurchaseInfoFieldView: View {
    let fieldName: String
    let fieldValue: String
    let edgeInsetsFieldValue = EdgeInsets(top: 7, leading: 5, bottom: 0, trailing: 5)
    
    #if os(iOS)
    let edgeInsetsFieldName = EdgeInsets(top: 7, leading: 10, bottom: 0, trailing: 5)
    let width: CGFloat = 95
    #elseif os(macOS)
    let edgeInsetsFieldName = EdgeInsets(top: 7, leading: 25, bottom: 0, trailing: 5)
    let width: CGFloat = 140
    #endif
    
    var body: some View {
        HStack {
            PurchaseInfoFieldText(text: fieldName).foregroundColor(.secondary).frame(width: width, alignment: .leading).padding(EdgeInsets(top: 10, leading: 10, bottom: 0, trailing: 5))
            PurchaseInfoFieldText(text:fieldValue).foregroundColor(.blue).padding(EdgeInsets(top: 10, leading: 5, bottom: 0, trailing: 5))
            Spacer()
        }
    }
}

struct PurchaseInfoFieldText: View {
    let text: String
    
    var body: some View {
        #if os(iOS)
        Text(text).font(.footnote)
        #elseif os(macOS)
        Text(text).font(.title2)
        #endif
    }
}
