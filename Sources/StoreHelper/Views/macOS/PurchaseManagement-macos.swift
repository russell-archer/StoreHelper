//
//  PurchaseManagement-macos.swift
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
#if os(macOS)
@available(macOS 12.0, *)
public struct PurchaseManagement: View {
    @Environment(\.openURL) var openURL
    @EnvironmentObject var storeHelper: StoreHelper
    @State private var purchasesRestored: Bool = false
    
    public init() {}
    
    public var body: some View {
        if  storeHelper.hasProducts,
            let restorePurchasesTxt = Configuration.restorePurchasesButtonText.value(storeHelper: storeHelper),
            let sContactUrl = Configuration.contactUsUrl.value(storeHelper: storeHelper),
            let contactUrl = URL(string: sContactUrl) {
            
            let edgeInsets = EdgeInsets(top: 10, leading: 3, bottom: 10, trailing: 3)
            VStack {
                HStack {
                    Button(action: { restorePurchases()}) {
                        Label(title: { BodyFont(scaleFactor: storeHelper.fontScaleFactor) { Text(restorePurchasesTxt)}.padding()},
                              icon:  { Image(systemName: "purchased").bodyImageNotRounded().frame(height: 24)})
                    }
                    .macOSStyle(padding: edgeInsets)
                    .disabled(purchasesRestored)
                    
                    Button(action: { openURL(contactUrl)}) {
                        Label(title: { BodyFont(scaleFactor: storeHelper.fontScaleFactor) { Text("Contact Us")}.padding()},
                              icon:  { Image(systemName: "bubble.right").bodyImageNotRounded().frame(height: 24)})
                    }
                    .macOSStyle(padding: edgeInsets)
                }
                
                CaptionFont(scaleFactor: storeHelper.fontScaleFactor) { Text("Manually restoring previous purchases is not normally necessary. Click \"\(restorePurchasesTxt)\" only if this app does not correctly identify your previous purchases. You will be prompted to authenticate with the App Store. Note that this app does not have access to credentials used to sign-in to the App Store.")}
                    .multilineTextAlignment(.center)
                    .padding(EdgeInsets(top: 0, leading: 10, bottom: 10, trailing: 10))
                    .foregroundColor(.secondary)
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
