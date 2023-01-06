//
//  PurchaseManagement-ios.swift
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
 
 */

/// Allows the user to manage subscriptions, restore purchases, request refunds and contact us.
#if os(iOS)
@available(iOS 15.0, *)
public struct PurchaseManagement: View {
    @Environment(\.openURL) var openURL
    @EnvironmentObject var storeHelper: StoreHelper
    @State private var purchasesRestored: Bool = false
    @State private var showManageSubscriptions = false
    @State private var contactUrl: URL? = nil
    
    public init() {}
    
    public var body: some View {
        if  storeHelper.hasProducts {
            
            Menu {
                Button(action: {
                    if Utils.isSimulator() { StoreLog.event("You cannot manage subscriptions from the simulator. You must use the sandbox environment.")}
                    showManageSubscriptions.toggle()

                }) { Label("Manage Subscriptions", systemImage: "rectangle.stack.fill.badge.person.crop")}
                    .xPlatformButtonStyleBorderedProminent()
                    .disabled(!storeHelper.hasSubscriptionProducts)
                
                Button(action: { restorePurchases()}) { Label("Restore Purchases", systemImage: "purchased")}
                    .xPlatformButtonStyleBorderedProminent()
                
                if let contactUrl {
                    Button(action: { openURL(contactUrl)}) { Label("Contact Us", systemImage: "bubble.right")}
                        .xPlatformButtonStyleBorderedProminent()
                }

            } label: { Label("", systemImage: "line.3.horizontal").labelStyle(.iconOnly)}
            .manageSubscriptionsSheet(isPresented: $showManageSubscriptions)
            .task {
                if let contact = Configuration.contactUsUrl.stringValue(storeHelper: storeHelper) { contactUrl = URL(string: contact)}
            }
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
