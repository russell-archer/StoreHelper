//
//  PriceButtonTextSubscription-macos.swift
//  StoreHelper
//
//  Created by Russell Archer on 26/11/2022.
//

import SwiftUI
import StoreKit

/// Displays either the standard purchase price and renewal period for a subscription, or available introductory
/// or promotional offers.
///
/// The following rules (in order of precedence) determine which price or offers are displayed:
///
/// - An available promotional offer will be displayed if the user is:
///     - a current subscriber to a *lower-value* subscription in the subscription group, OR
///     - a lapsed subscriber to this subscription
///
/// - An available introductory offer will be displayed if the user is:
///     - not a current subscriber to this subscription, AND
///     - not a lapsed subscriber to this or any other subscription in the subscription group
///
/// - If none of the above rules apply, the standard price and renewal period are displayed (e.g. "$9.99 / month").
///
/// Note that although you can create an introductory offer for each subscription product in App Store Connect,
/// each user is only eligible to redeem ONE introductory offer per subscription group.
/// See https://help.apple.com/app-store-connect/#/deve1d49254f for details.
///
@available(iOS 15.0, macOS 12.0, *)
public struct PriceButtonTextSubscription: View {
    @EnvironmentObject var storeHelper: StoreHelper
    var disabled: Bool
    var price: String
    
    public var body: some View {
        VStack {
            Text(disabled ? "Disabled" : price)  // Don't use scaled fonts for the price at it can lead to truncation
                .font(.body)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .lineSpacing(5)
                .padding()
                .background(Color.blue)
                .cornerRadius(25)
        }
    }
}


