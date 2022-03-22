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
public struct PurchaseManagement: View {
    @Environment(\.openURL) var openURL
    @EnvironmentObject var storeHelper: StoreHelper
    @State private var purchasesRestored: Bool = false
    
    #if os(iOS)
    @State private var showManageSubscriptions = false
    
    public var body: some View {
        if storeHelper.hasProducts {
            Menu {
                Button(action: {
                    if Utils.isSimulator() { StoreLog.event("You cannot manage subscriptions from the simulator. You must use the sandbox environment.")}
                    showManageSubscriptions.toggle()

                }) { Label("Manage Subscriptions", systemImage: "rectangle.stack.fill.badge.person.crop")}
                .disabled(!storeHelper.hasSubscriptionProducts)
                
                Button(action: { restorePurchases()}) { Label("Restore Purchases", systemImage: "purchased")}
                Button(action: { openURL(URL(string: Storage.contactUsUrl.value()!)!)}) { Label("Contact Us", systemImage: "bubble.right")}

            } label: { Label("", systemImage: "line.3.horizontal").labelStyle(.iconOnly)}
            .manageSubscriptionsSheet(isPresented: $showManageSubscriptions)
        }
    }
    
    #elseif os(macOS)
    public var body: some View {
        if storeHelper.hasProducts {
            let edgeInsets = EdgeInsets(top: 10, leading: 3, bottom: 10, trailing: 3)
            VStack {
                HStack {
                    Button(action: { restorePurchases()}) {
                        Label(title: { BodyFont(scaleFactor: storeHelper.fontScaleFactor) { Text("Restore Purchases")}.padding()},
                              icon:  { Image(systemName: "purchased").bodyImageNotRounded().frame(height: 24)})
                    }
                    .macOSStyle(padding: edgeInsets)
                    .disabled(purchasesRestored)
                    
                    Button(action: { openURL(URL(string: Storage.contactUsUrl.value()!)!)}) {
                        Label(title: { BodyFont(scaleFactor: storeHelper.fontScaleFactor) { Text("Contact Us")}.padding()},
                              icon:  { Image(systemName: "bubble.right").bodyImageNotRounded().frame(height: 24)})
                    }
                    .macOSStyle(padding: edgeInsets)
                }
                
                CaptionFont(scaleFactor: storeHelper.fontScaleFactor) { Text("Manually restoring previous purchases is not normally necessary. Click \"Restore Purchases\" only if this app does not correctly identify your previous purchases. You will be prompted to authenticate with the App Store. Note that this app does not have access to credentials used to sign-in to the App Store.")}
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
}


