//
//  RedeemOfferCodeView.swift
//  
//
//  Created by Russell Archer on 02/12/2022.
//

import SwiftUI
import StoreKit

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
            if let redeemOfferCodeButtonText = Configuration.redeemOfferCodeButtonText.value(storeHelper: storeHelper) {
                Button(action: {
                    showRedeemOfferCodeButton = true
                }) { BodyFont(scaleFactor: storeHelper.fontScaleFactor) { Text(redeemOfferCodeButtonText)}.padding()}
                    .buttonStyle(.borderedProminent).padding()
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
