//
//  RefreshProductsView.swift
//  StoreHelper
//
//  Created by Russell Archer on 02/12/2022.
//

import SwiftUI
import StoreKit

/// Allows the user to trigger a complete refresh of the product list and rebuild the purchase cache. The same action
/// may be triggered using the "pull-to-refresh" gesture on the product list.
@available(iOS 15.0, macOS 12.0, *)
public struct RefreshProductsView: View {
    @EnvironmentObject var storeHelper: StoreHelper
    
    public init() {}
    
    public var body: some View {
        if let refreshProductsButtonText = Configuration.refreshProductsButtonText.stringValue(storeHelper: storeHelper) {
            Button(action: {
                Task.init {
                    storeHelper.refreshProductsFromAppStore(rebuildCaches: true)
                }
            }) {
                Label(title: { BodyFont(scaleFactor: storeHelper.fontScaleFactor) { Text(refreshProductsButtonText)}.padding([.top, .bottom, .trailing])},
                      icon:  { Image(systemName: "arrow.triangle.2.circlepath.circle").bodyImageNotRounded().frame(height: 24).padding(.leading)})
            }
            #if os(iOS)
            .xPlatformButtonStyleBorderless()
            #else
            .xPlatformButtonStyleBorderedProminent()
            #endif
            .padding([.top, .leading, .trailing])
            
            CaptionFont(scaleFactor: storeHelper.fontScaleFactor) { Text("Manually refreshing the product list is not normally necessary. \(Utils.confirmGestureText()) \"\(refreshProductsButtonText)\" if you believe this app is not correctly listing your products.")}
                .multilineTextAlignment(.center)
                .padding(EdgeInsets(top: 0, leading: 10, bottom: 10, trailing: 10))
                .foregroundColor(.secondary)
        }
    }
}

