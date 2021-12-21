//
//  HamburgerMenu.swift
//  HamburgerMenu
//
//  Created by Russell Archer on 22/07/2021.
//

import SwiftUI
import StoreKit

/*
 
 Menu structure:
 
 Manage Subscriptions        􀏺
 Restore Previous Purchases  􀚐
 Contact Us                  􀌨
 
 */

#if !os(tvOS)
struct HamburgerMenu: View {
    @Environment(\.openURL) var openURL
    @EnvironmentObject var storeHelper: StoreHelper
    @Binding var showManageSubscriptions: Bool
    @State private var disableWiCRefund = true
    @State private var disableAYoPRefund = true
    @State private var disableMycRefund = true
    
    var body: some View {
        
        Menu {
            Button(action: {
                guard !Utils.isSimulator() else {
                    StoreLog.event("You cannot manage subscriptions from the simulator. You must use the sandbox environment.")
                    return
                }
                
                showManageSubscriptions.toggle()
                
            }, label: {
                Label("Manage Subscriptions", systemImage: "rectangle.stack.fill.badge.person.crop")
            })
                .disabled(storeHelper.subscriptionProducts == nil)  // Disable menu item if app has no subscriptions
            
            Button(action: {
                restorePurchases()
            }, label: {
                Label("Restore Previous Purchases", systemImage: "purchased")
            })
            
            Button(action: {
                guard let sUrl = StorageKey.contactUsUrl.value(), let url = URL(string: sUrl) else { return }
                openURL(url)
            }, label: {
                Label("Contact Us", systemImage: "bubble.right")
            })
            
        } label: {
            Label("", systemImage: "line.3.horizontal").labelStyle(.iconOnly)
        }
    }
    
    /// Presents the refund request sheet for a transaction in a window scene.
    ///
    /// Note that this will not work in the Xcode StoreKit Testing environment:
    /// you must use the sandbox environment.
    /// - Parameter productId: The `ProductId` for which the user wants to request a refund.
#if os(iOS)
    func requestRefund(productId: ProductId) {
        
        guard !Utils.isSimulator() else {
            StoreLog.event("You cannot request refunds from the simulator. You must use the sandbox environment.")
            return
        }
        
        // This convoluted nonsense attempts to get the current UIWindowScene that's required by beginRefundRequest(in:) 🙄
        guard let keyWindow = UIApplication.shared.connectedScenes
                .filter({$0.activationState == .foregroundActive})
                .map({$0 as? UIWindowScene})
                .compactMap({$0})
                .first?.windows
                .filter({$0.isKeyWindow}).first,
              let scene = keyWindow.windowScene else { return }
        
        // Allow the user to request a refund for an in-app purchase. Displays a refund sheet with the user’s purchase
        // details and a list of reason codes for why the refund is required.
        Task.init {
            if let result = await Transaction.latest(for: productId) {
                let verificationResult = storeHelper.checkVerificationResult(result: result)
                if verificationResult.verified {
                    if let status = try? await verificationResult.transaction.beginRefundRequest(in: scene), status == .success {
                        StoreLog.event(.transactionRefundRequested)
                    } else {
                        StoreLog.event(.transactionRefundFailed)
                    }
                }
            }
        }
    }
#endif
    
    /// Restores previous user purchases. With StoreKit2 this is normally not necessary and should only be
    /// done in response to explicit user action. Will result in the user having to authenticate with the
    /// App Store.
    func restorePurchases() {
        Task.init { try? await AppStore.sync() }
    }
}
#endif


