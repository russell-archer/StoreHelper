//
//  PrePurchaseSubscriptionInfo.swift
//  StoreHelper
//
//  Created by Russell Archer on 22/11/2022.
//

import StoreKit
import SwiftUI

/// An optional promo id and localized purchase price and renewal period in a format that may be displayed to the user.
@available(iOS 15.0, macOS 12.0, *)
public struct PurchasePriceForDisplay: Hashable, Identifiable {
    /// The offer's unique id, set in App Store Connect. Will be nil if the offer is an introductory or standard offer.
    public var id: String?
    
    /// Localized purchase price and renewal period in a format that may be displayed to the user.
    public var price: String
}

/// Information about a subscription product before it's been purchased, including introductory and promotional offers.
@available(iOS 15.0, macOS 12.0, *)
public struct PrePurchaseSubscriptionInfo: Hashable {
    
    /// The product's unique id.
    public var productId: ProductId
    
    /// The product's display name.
    public var name: String
    
    /// Localized standard (non-offer) price (e.g. "$1.99").
    public var purchasePrice: String?
    
    /// The standard (non-offer) renewal period (e.g. "/ month").
    public var renewalPeriod: String?
    
    /// Info on the introductory offer, if any.
    public var introductoryOffer: SubscriptionOfferInfo?
    
    /// Info on any promotional offers. Should only be presented as an upgrade to users with a current subscription, or lapsed subscribers.
    public var promotionalOffers: [SubscriptionOfferInfo]?

    /// True if the `introductoryOffer` property may be presented to the user, false otherwise.
    public var introductoryOfferEligible = false
    
    /// True if the `promotionalOffers` property contains eligible offers for the user, false otherwise.
    public var promotionalOffersEligible = false
    
    /// An array of promo ids and localized purchase prices and renewal periods in a format that may be displayed to the user.
    /// Displays the correct price and renewal period for either the standard price, an eligible promotional price, or an
    /// eligible introductory price. Use this property in preference to other price and renewal period values as it will return
    /// the most relevant standard, introductory or promotional offers in a format suitable for displaying directly to the user.
    /// - If there are promotional offers available, the value of this property will be an array of promo ids and displayble
    /// prices/renewal periods. All promotional offers should be displayed to the user.
    /// - If there are no promotional offers but there is an introductory offer, the value of this property will be an array with a
    /// single element with the promo id (which will be nil) and price/period for the offer.
    /// - If there are no offers, the value of this property will be an array with a single element with the standard price/period.
    public var purchasePriceForDisplay: [PurchasePriceForDisplay]? {
        if promotionalOffersEligible, let promotionalOffers, promotionalOffers.count > 0 {
            var offersDisplay = [PurchasePriceForDisplay]()
            promotionalOffers.forEach { offer in
                if let offerDisplay = offer.offerDisplay {
                    offersDisplay.append(PurchasePriceForDisplay(id: offer.id, price: offerDisplay))
                }
            }
            
            return offersDisplay  // Promotional offers
            
        } else if introductoryOfferEligible, let introductoryOffer, let offerDisplay = introductoryOffer.offerDisplay {
            return [PurchasePriceForDisplay(id: nil, price: offerDisplay)]  // Introductory offers always have nil ids
        }
        else {
            return [PurchasePriceForDisplay(id: nil, price: "\(purchasePrice ?? "?? price") \(renewalPeriod ?? "?? period")")]  // Standard price
        }
    }
}

