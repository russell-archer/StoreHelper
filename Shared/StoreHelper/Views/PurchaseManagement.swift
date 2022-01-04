//
//  PurchaseManagement.swift
//  PurchaseManagement
//
//  Created by Russell Archer on 22/07/2021.
//

import SwiftUI
import StoreKit

/*
 
 Menu structure in iOS:
 
 Manage Subscriptions   􀏺
 Request Refund         􀒯
 Restore Purchases      􀚐
 Contact Us             􀌨
 
 View in macOS:
 
 [Restore Purchases] [Request Refund] [Contact Us]
 
 Note that the APIs to request refunds and manage subscriptions are not currently available for macOS.
 On macOS when the user want to request a refund all we can do is open the Apple "https://reportaproblem.apple.com/" web page.
 
 */

struct ProductPurchaseInfo: Hashable {
    let productId: ProductId    // The product's unique id
    let name: String            // The product's display name
    let isPurchased: Bool       // true if the product has been purchased
    let transactionId: UInt64   // The transactionid for the purchase. UInt64.min if not purchased
    
    init(productId: ProductId = "", name: String = "", isPurchased: Bool = false, transactionId: UInt64 = UInt64.min) {
        self.productId = productId
        self.name = name
        self.isPurchased = isPurchased
        self.transactionId = transactionId
    }
}

/// Allows the user to manage subscriptions, restore purchases, request refunds and contact us.
struct PurchaseManagement: View {
    @Environment(\.openURL) var openURL
    @EnvironmentObject var storeHelper: StoreHelper
    @State private var purchasesRestored: Bool = false
    
    #if os(iOS)
    @State private var showManageSubscriptions = false
    @State private var showRefundProductSelector = false
    @State private var showRefundSheet = false
    @State private var selectProductForRefund = ProductPurchaseInfo()
    @State private var purchaseInfo = [ProductPurchaseInfo]()
    
    var body: some View {

        if storeHelper.hasProducts {
            Menu {
                Button(action: {
                    if Utils.isSimulator() { StoreLog.event("You cannot manage subscriptions from the simulator. You must use the sandbox environment.")}
                    showManageSubscriptions.toggle()

                }, label: { Label("Manage Subscriptions", systemImage: "rectangle.stack.fill.badge.person.crop")}).disabled(storeHelper.subscriptionProducts == nil)
                
                Button(action: {
                    if Utils.isSimulator() { StoreLog.event("You cannot request refunds from the simulator. You must use the sandbox environment.")}
                    showRefundProductSelector.toggle()
                    
                }, label: { Label("Request Refund", systemImage: "creditcard.circle")})
                
                Button(action: { restorePurchases()}, label: { Label("Restore Purchases", systemImage: "purchased")})
                Button(action: { openURL(URL(string: StorageKey.contactUsUrl.value()!)!)}, label: { Label("Contact Us", systemImage: "bubble.right")})

            } label: { Label("", systemImage: "line.3.horizontal").labelStyle(.iconOnly)}
            .onAppear { getPurchaseInfo() }
            .confirmationDialog("Select purchased product for refund", isPresented: $showRefundProductSelector, titleVisibility: .visible) {
                ForEach(purchaseInfo, id: \.self) { pi in
                    if pi.isPurchased {
                        Button(pi.name) {
                            selectProductForRefund = pi
                            showRefundSheet.toggle()
                        }
                    }
                }
            }
            .manageSubscriptionsSheet(isPresented: $showManageSubscriptions)
            .refundRequestSheet(for: 0, isPresented: $showRefundSheet) { refundRequestStatus in
                switch(refundRequestStatus) {
                    case .failure(_): print("")
                    case .success(_): print("")
                }
            }
        }
    }
    #elseif os(macOS)
    var body: some View {
        if storeHelper.hasProducts {
            let edgeInsets = EdgeInsets(top: 10, leading: 3, bottom: 10, trailing: 3)
            VStack {
                HStack {
                    Button(action: { restorePurchases()}) { Label("Restore Purchases", systemImage: "purchased")}.macOSStyle(padding: edgeInsets).disabled(purchasesRestored)
                    Button(action: { openURL(URL(string: StorageKey.requestRefund.value()!)!)}) { Label("Request Refund", systemImage: "creditcard.circle")}.macOSStyle(padding: edgeInsets)
                    Button(action: { openURL(URL(string: StorageKey.contactUsUrl.value()!)!)}) { Label("Contact Us", systemImage: "bubble.right")}.macOSStyle(padding: edgeInsets)
                }
                
                Text("Manually restoring previous purchases is not normally necessary. Click \"Restore Purchases\" only if this app does not correctly identify your previous purchases. You will be prompted to authenticate with the App Store. You may request a refund from the App Store if a purchase does not perform as expected. This requires you to authenticate with the App Store. Note that this app does not have access to credentials used to sign-in to the App Store.")
                    .font(.caption)
                    .multilineTextAlignment(.center)
                    .padding(EdgeInsets(top: 0, leading: 10, bottom: 10, trailing: 10))
                    .foregroundColor(.secondary)
            }
        }
    }
    #endif

    /// Restores previous user purchases. With StoreKit2 this is normally not necessary and should only be
    /// done in response to explicit user action. Will result in the user having to authenticate with the
    /// App Store.
    private func restorePurchases() {
        Task.init {
            try? await AppStore.sync()
            purchasesRestored.toggle()
        }
    }
    
    #if os(iOS)
    /// Get a collection of purchase data.
    private func getPurchaseInfo() {
        if storeHelper.hasProducts, let products = storeHelper.products {
            products.forEach { product in
                Task.init {
                    var id: UInt64? = UInt64.min
                    let purchased = (try? await storeHelper.isPurchased(productId: product.id)) ?? false
                    if purchased { id = await storeHelper.mostRecentTransactionId(for: product.id)}
                    purchaseInfo.append(ProductPurchaseInfo(productId: product.id, name: product.displayName, isPurchased: purchased, transactionId: id ?? UInt64.min))
                }
            }
        }
    }
    #endif
}


