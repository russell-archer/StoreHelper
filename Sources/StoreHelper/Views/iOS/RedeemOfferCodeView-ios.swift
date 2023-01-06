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
                }) { BodyFont(scaleFactor: storeHelper.fontScaleFactor) { Text(redeemOfferCodeButtonText)}.padding()}
                    .xPlatformButtonStyleBorderedProminent()
                    .padding()
                    .offerCodeRedemption(isPresented: $showRedeemOfferCodeButton) { result in
                        switch result {
                            case .failure(_): showRedeemOfferCodeError = true
                            case .success(): break
                        }
                    }
            }
        } else {
            EmptyView()
        }
    }
}
#endif

