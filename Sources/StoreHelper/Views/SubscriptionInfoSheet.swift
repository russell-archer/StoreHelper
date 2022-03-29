//
//  SubscriptionInfoSheet.swift
//  StoreHelper
//
//  Created by Russell Archer on 16/01/2022.
//

import SwiftUI

// View hierachy:
// Non-Consumables: [Products].[ProductListView].[ProductListViewRow]......[ProductView]......[if purchased].[PurchaseInfoView].....[PurchaseInfoSheet]
// Consumables:     [Products].[ProductListView].[ProductListViewRow]......[ConsumableView]...[if purchased].[PurchaseInfoView].....[PurchaseInfoSheet]
// Subscriptions:   [Products].[ProductListView].[SubscriptionListViewRow].[SubscriptionView].[if purchased].[SubscriptionInfoView].[SubscriptionInfoSheet]

public struct SubscriptionInfoSheet: View {
    @EnvironmentObject var storeHelper: StoreHelper
    @State private var showManageSubscriptionsSheet = false
    @State private var extendedSubscriptionInfo: ExtendedSubscriptionInfo?
    @Binding var showPurchaseInfoSheet: Bool
    var productId: ProductId
    var viewModel: SubscriptionInfoViewModel
    
    public var body: some View {
        VStack {
            SheetBarView(showSheet: $showPurchaseInfoSheet, title: "Subscription Information", sysImage: "creditcard.circle")
            
            Image(productId)
                .resizable()
                .frame(maxWidth: 85, maxHeight: 85)
                .aspectRatio(contentMode: .fit)
                .cornerRadius(25)
            
            ScrollView {
                if let esi = extendedSubscriptionInfo, esi.isPurchased {
                    
                    VStack {
                        Group {
                            PurchaseInfoFieldView(fieldName: "Product name:", fieldValue: esi.name)
                            PurchaseInfoFieldView(fieldName: "Product ID:", fieldValue: esi.productId)
                            PurchaseInfoFieldView(fieldName: "Price:", fieldValue: esi.purchasePrice ?? "Unknown")
                            PurchaseInfoFieldView(fieldName: "Upgrade:", fieldValue: esi.upgraded == nil ? "Unknown" : (esi.upgraded! ? "Yes" : "No"))
                            if let willAutoRenew = esi.autoRenewOn {
                                if willAutoRenew {
                                    PurchaseInfoFieldView(fieldName: "Status:", fieldValue: esi.subscribedtext ?? "Unknown")
                                    PurchaseInfoFieldView(fieldName: "Auto-renews:", fieldValue: "Yes")
                                    PurchaseInfoFieldView(fieldName: "Renews:", fieldValue: esi.renewalPeriod ?? "Unknown")
                                    PurchaseInfoFieldView(fieldName: "Renewal date:", fieldValue: esi.renewalDate ?? "Unknown")
                                    PurchaseInfoFieldView(fieldName: "Renews in:", fieldValue: esi.renewsIn ?? "Unknown")
                                } else {
                                    PurchaseInfoFieldView(fieldName: "Status:", fieldValue: "Cancelled")
                                    PurchaseInfoFieldView(fieldName: "Auto-renews:", fieldValue: "No")
                                    PurchaseInfoFieldView(fieldName: "Renews:", fieldValue: "Will not renew")
                                    PurchaseInfoFieldView(fieldName: "Expirary date:", fieldValue: esi.renewalDate ?? "Unknown")
                                    PurchaseInfoFieldView(fieldName: "Expires in:", fieldValue: esi.renewsIn ?? "Unknown")
                                }
                            }
                        }
                        
                        Group {
                            Divider()
                            Text("Most recent transaction").foregroundColor(.secondary)
                            PurchaseInfoFieldView(fieldName: "Date:", fieldValue: esi.purchaseDateFormatted ?? "Unknown")
                            PurchaseInfoFieldView(fieldName: "ID:", fieldValue: String(esi.transactionId ?? UInt64.min))
                            PurchaseInfoFieldView(fieldName: "Purchase type:", fieldValue: esi.ownershipType == nil ? "Unknown" : (esi.ownershipType! == .purchased ? "Personal purchase" : "Family sharing"))
                            PurchaseInfoFieldView(fieldName: "Notes:", fieldValue: "\(esi.revocationDate == nil ? "-" : "Purchased revoked \(esi.revocationDateFormatted ?? "") \(esi.revocationReason == .developerIssue ? "(developer issue)" : "(other issue)")")")
                        }
                    }
                    
                    Divider().padding(.bottom)
                    
                    #if os(iOS)
                    Button(action: {
                        if Utils.isSimulator() { StoreLog.event("Warning: You cannot request refunds from the simulator. You must use the sandbox environment.")}
                        withAnimation { showManageSubscriptionsSheet.toggle()}
                    }) {
                        Label(title: { BodyFont(scaleFactor: storeHelper.fontScaleFactor) { Text("Manage Subscription")}.padding()},
                              icon:  { Image(systemName: "creditcard.circle").bodyImageNotRounded().frame(height: 24)})
                    }
                    .buttonStyle(.borderedProminent)
                    #endif
                    
                    Caption2Font(scaleFactor: storeHelper.fontScaleFactor) { Text("Managing your subscriptions may require you to authenticate with the App Store. Note that this app does not have access to credentials used to sign-in to the App Store.")}
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                        .padding()
                    
                } else {
                    TitleFont(scaleFactor: storeHelper.fontScaleFactor) { Text("No purchase information available")}
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding(EdgeInsets(top: 1, leading: 5, bottom: 0, trailing: 5))
                }
            }
        }
        .task { extendedSubscriptionInfo = await viewModel.extendedSubscriptionInfo()}
        #if os(iOS)
        .manageSubscriptionsSheet(isPresented: $showManageSubscriptionsSheet)  // Not available for macOS
        #elseif os(macOS)
        .frame(minWidth: 650, idealWidth: 650, maxWidth: 650, minHeight: 650, idealHeight: 650, maxHeight: 650)
        .fixedSize(horizontal: true, vertical: true)
        #endif
    }
}

