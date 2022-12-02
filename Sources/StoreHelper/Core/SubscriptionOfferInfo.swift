//
//  SubscriptionOfferInfo.swift
//  StoreHelper
//
//  Created by Russell Archer on 22/11/2022.
//

import StoreKit
import SwiftUI

/// Information about a subscription offer
@available(iOS 15.0, macOS 12.0, *)
public struct SubscriptionOfferInfo: Hashable, Identifiable {
    /// The offer's unique id, set in App Store Connect. Will be nil if the offer is an introductory offer.
    public var id: String?
    
    /// The product's unique id.
    public var productId: ProductId
    
    /// One of .promotional or .introductory. If nil the user isn't eligible for the offer.
    public var offerType: Product.SubscriptionOffer.OfferType?
    
    /// payAsYouGo, payUpFront, free.
    public var paymentMode: Product.SubscriptionOffer.PaymentMode?
    
    /// Takes the form of "Pay up front", etc.
    public var paymentModeDisplay: String?
    
    /// Localized offer price for display, e.g. "$2.99".
    public var offerPrice: String?
    
    /// Takes the form "day, "days", "month", "months", etc.
    public var offerPeriodDisplay: String?
    
    /// Day, week, month, etc. The duration of one subscription period is defined by: `unit * value` (`3 * month`).
    public var offerPeriodUnit: Product.SubscriptionPeriod.Unit?
    
    /// The number of period units the offer lasts (e.g. 3 months).
    public var offerPeriodValue: Int?
    
    /// The number of periods the subscription offer renews. Meaning depends on paymentMode: payAsYouGo: the number of
    /// periods the subscription renews at the offer price; freeTrial and payUpFront: period count is always 1 (i.e. not significant).
    public var offerPeriodCount: Int?
    
    /// Takes the form "3 months at an introductory price of $1.99 per month", "2 months at a promotional price of $1.99 per month", etc.
    public var offerDisplay: String?
}
