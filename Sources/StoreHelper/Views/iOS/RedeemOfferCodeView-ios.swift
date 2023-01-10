//
//  RedeemOfferCodeView.swift
//  
//
//  Created by Russell Archer on 02/12/2022.
//

import SwiftUI
import StoreKit

#if os(iOS)
@available(iOS 15.0, *)
public struct RedeemOfferCodeView: View {
    @EnvironmentObject var storeHelper: StoreHelper
    @Binding var showRedeemOfferCodeButton: Bool
    @Binding var showRedeemOfferCodeError: Bool
    
    public init(showRedeemOfferCodeButton: Binding<Bool>, showRedeemOfferCodeError: Binding<Bool>) {
        self._showRedeemOfferCodeButton = showRedeemOfferCodeButton
        self._showRedeemOfferCodeError = showRedeemOfferCodeError
    }
    public var body: some View {
        if #available(iOS 16.0, *) {
            if let redeemOfferCodeButtonText = Configuration.redeemOfferCodeButtonText.stringValue(storeHelper: storeHelper) {
                Button(action: {
                    showRedeemOfferCodeButton = true
                }) {
                    Label(title: { BodyFont(scaleFactor: storeHelper.fontScaleFactor) { Text(redeemOfferCodeButtonText).padding([.top, .bottom, .trailing])}},
                          icon:  { Image(systemName: "giftcard").bodyImageNotRounded().frame(height: 24).padding(.leading)})
                }
                .xPlatformButtonStyleBorderless()
                .padding([.top, .leading, .trailing])
                .offerCodeRedemption(isPresented: $showRedeemOfferCodeButton) { result in
                    switch result {
                        case .failure(_): showRedeemOfferCodeError = true
                        case .success(): break
                    }
                }
                
                Caption2Font(scaleFactor: storeHelper.fontScaleFactor) { Text("Have an offer code for Writerly? Tap \"\(redeemOfferCodeButtonText)\" to redeem your code and get instant access to the associated product.")}
                    .multilineTextAlignment(.center)
                    .padding(EdgeInsets(top: 0, leading: 10, bottom: 10, trailing: 10))
                    .foregroundColor(.secondary)
            }
        } else {
            EmptyView()
        }
    }
}
#endif

