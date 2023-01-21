//
//  RestorePurchasesView.swift
//  StoreHelper
//
//  Created by Russell Archer on 02/12/2022.
//

import SwiftUI
import StoreKit

@available(iOS 15.0, macOS 12.0, *)
public struct RestorePurchasesView: View {
    @EnvironmentObject var storeHelper: StoreHelper
    
    public init() {}
    
    public var body: some View {
        if let restorePurchasesButtonText = Configuration.restorePurchasesButtonText.stringValue(storeHelper: storeHelper) {
            
            Button(action: {
                Task.init { try? await AppStore.sync() }
            }) {
                Label(title: { BodyFont(scaleFactor: storeHelper.fontScaleFactor) { Text(restorePurchasesButtonText)}.padding([.top, .bottom, .trailing])},
                      icon:  { Image(systemName: "purchased").bodyImageNotRounded().frame(height: 24).padding(.leading)})
            }
            #if os(iOS)
            .xPlatformButtonStyleBorderless()
            #else
            .xPlatformButtonStyleBorderedProminent()
            #endif
            .padding([.top, .leading, .trailing])
            
            CaptionFont(scaleFactor: storeHelper.fontScaleFactor) { Text("Manually restoring previous purchases is not normally necessary. \(Utils.confirmGestureText()) \"\(restorePurchasesButtonText)\" only if this app does not correctly identify your previous purchases. You will be prompted to authenticate with the App Store. Note that this app does not have access to credentials used to sign-in to the App Store.")}
                .multilineTextAlignment(.center)
                .padding(EdgeInsets(top: 0, leading: 10, bottom: 10, trailing: 10))
                .foregroundColor(.secondary)
        }
    }
}

