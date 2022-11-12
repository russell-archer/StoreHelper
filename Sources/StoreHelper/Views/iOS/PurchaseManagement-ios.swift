//
//  PurchaseManagement.swift
//  StoreHelper
//
//  Created by Russell Archer on 22/07/2021.
//

import SwiftUI
import StoreKit

/*
 
 Menu structure in iOS:
 
 Manage Subscriptions   􀏺
 Restore Purchases      􀚐
 Contact Us             􀌨
 
 View in macOS:
 
 [Restore Purchases] [Contact Us]
 
 Note that the APIs to request refunds and manage subscriptions are not currently available for macOS.
 On macOS when the user want to request a refund all we can do is open the Apple "https://reportaproblem.apple.com/" web page.
 
 */

/// Allows the user to manage subscriptions, restore purchases, request refunds and contact us.
#if os(iOS)
@available(iOS 15.0, *)
public struct PurchaseManagement: View {
    @Environment(\.openURL) var openURL
    @EnvironmentObject var storeHelper: StoreHelper
    @State private var purchasesRestored: Bool = false
    @State private var showManageSubscriptions = false
    
    public init() {}
    
    public var body: some View {
        if  storeHelper.hasProducts,
            let sContactUrl = storeHelper.configurationProvider?.value(configuration: .contactUsUrl) ?? Configuration.contactUsUrl.value(),
            let contactUrl = URL(string: sContactUrl) {
            
            Menu {
                Button(action: {
                    if Utils.isSimulator() { StoreLog.event("You cannot manage subscriptions from the simulator. You must use the sandbox environment.")}
                    showManageSubscriptions.toggle()

                }) { Label("Manage Subscriptions", systemImage: "rectangle.stack.fill.badge.person.crop")}
                .disabled(!storeHelper.hasSubscriptionProducts)
                
                Button(action: { restorePurchases()}) { Label("Restore Purchases", systemImage: "purchased")}
                Button(action: { openURL(contactUrl)}) { Label("Contact Us", systemImage: "bubble.right")}

            } label: { Label("", systemImage: "line.3.horizontal").labelStyle(.iconOnly)}
            .manageSubscriptionsSheet(isPresented: $showManageSubscriptions)
        }
    }

    /// Restores previous user purchases. With StoreKit2 this is normally not necessary and should only be
    /// done in response to explicit user action. Will result in the user having to authenticate with the
    /// App Store.
    private func restorePurchases() {
        Task.init {
            try? await AppStore.sync()
            purchasesRestored.toggle()
        }
    }
}
#endif
