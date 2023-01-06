//
//  RestorePurchasesView.swift
//  StoreHelper
//
//  Created by Russell Archer on 02/12/2022.
//

import SwiftUI
import StoreKit

#if os(iOS)
@available(iOS 15.0, *)
public struct RestorePurchasesView: View {
    @EnvironmentObject var storeHelper: StoreHelper
    @Binding private var purchasesRestored: Bool
    
    public init(purchasesRestored: Binding<Bool>) {
        self._purchasesRestored = purchasesRestored
    }
    
    public var body: some View {
        if let restorePurchasesButtonText = Configuration.restorePurchasesButtonText.stringValue(storeHelper: storeHelper) {
            Button(action: {
                Task.init {
                    try? await AppStore.sync()
                    purchasesRestored = true
                }
            }) { BodyFont(scaleFactor: storeHelper.fontScaleFactor) { Text(purchasesRestored ? "Purchases Restored" : restorePurchasesButtonText)}.padding()}
                .xPlatformButtonStyleBorderedProminent()
                .padding()
                .disabled(purchasesRestored)
            
            Caption2Font(scaleFactor: storeHelper.fontScaleFactor) { Text("Manually restoring previous purchases is not normally necessary. Tap \"\(restorePurchasesButtonText)\" only if this app does not correctly identify your previous purchases. You will be prompted to authenticate with the App Store. Note that this app does not have access to credentials used to sign-in to the App Store.")}
                .multilineTextAlignment(.center)
                .padding(EdgeInsets(top: 0, leading: 10, bottom: 10, trailing: 10))
                .foregroundColor(.secondary)
        }
    }
}
#endif

