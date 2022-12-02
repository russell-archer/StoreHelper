//
//  PriceViewModel.swift
//  StoreHelper
//
//  Created by Russell Archer on 23/06/2021.
//

import StoreKit
import SwiftUI

/// ViewModel for `PriceView`. Enables purchasing.
@available(iOS 15.0, macOS 12.0, *)
public struct PriceViewModel {
    @ObservedObject public var storeHelper: StoreHelper
    @Binding public var purchaseState: PurchaseState
    
    public init(storeHelper: StoreHelper, purchaseState: Binding<PurchaseState>) {
        self.storeHelper = storeHelper
        self._purchaseState = purchaseState
    }
    
    /// Purchase a product using StoreHelper and StoreKit2.
    /// - Parameter product: The `Product` to purchase.
    /// - Parameter options: An optional collection of purchase options related to promotional offers.
    @MainActor public func purchase(product: Product, options: Set<Product.PurchaseOption>? = nil) async {
        do {
            
            var purchaseResult: (transaction: StoreKit.Transaction?, purchaseState: PurchaseState)
            if let options { purchaseResult = try await storeHelper.purchase(product, options: options) }
            else { purchaseResult = try await storeHelper.purchase(product) }
            withAnimation { purchaseState = purchaseResult.purchaseState }

        } catch { purchaseState = .failed }  // The purchase or validation failed
    }
    
    /// Generates a `PrePurchaseSubscriptionInfo` object containing extended information on a subscription, including
    /// promotional and introductory offers, price and renewal period.
    /// - Parameter productId: The unique id of the product for which you want subscription information.
    /// - Returns: Returns a `PrePurchaseSubscriptionInfo` object containing extended information on a subscription,
    /// or nil if the product is not a subscription.
    @MainActor public func getPrePurchaseSubscriptionInfo(productId: ProductId) async -> PrePurchaseSubscriptionInfo? {
        guard let product = storeHelper.product(from: productId), let subscription = product.subscription else { return nil }
        
        var ppSubInfo = PrePurchaseSubscriptionInfo(productId: productId, name: product.displayName)
        ppSubInfo.purchasePrice = product.displayPrice
        ppSubInfo.renewalPeriod = "/ \(periodText(unit: subscription.subscriptionPeriod.unit, value: subscription.subscriptionPeriod.value))"  // e.g. "$1.99 / month"
        ppSubInfo.introductoryOffer = processIntroductoryOffer(sub: subscription, for: productId)
        ppSubInfo.promotionalOffers = processPromotionalOffers(sub: subscription, for: productId)
                
        // Are there one or more promotional offers, or an introductory offer available?
        ppSubInfo.promotionalOffersEligible = false
        ppSubInfo.introductoryOfferEligible = false
        
        if ppSubInfo.promotionalOffers != nil {
            // Promotional offers take precedence over introductory offers. There are promo offers available, but is this user eligible?
            if await storeHelper.subscriptionHelper.isLapsedSubscriber(to: product) {
                ppSubInfo.promotionalOffersEligible = true
            } else if await storeHelper.subscriptionHelper.hasLowerValueCurrentSubscription(than: product) {
                ppSubInfo.promotionalOffersEligible = true
            }
        }
        
        // There aren't any promotional offers. Is there an introductory offer available?
        if !ppSubInfo.promotionalOffersEligible, ppSubInfo.introductoryOffer != nil {
            // There is an introductory offer available. Is this user eligible?
            ppSubInfo.introductoryOfferEligible = await subscription.isEligibleForIntroOffer
        }
        
        return ppSubInfo
    }
    
    // MARK: - Private methods
    
    private func processIntroductoryOffer(sub: Product.SubscriptionInfo, for productId: ProductId) -> SubscriptionOfferInfo? {
        guard let introOffer                = sub.introductoryOffer else { return nil }  // Get the introductory offer for this particular subscription
        var introOfferInfo                  = SubscriptionOfferInfo(id: introOffer.id, productId: productId)
        introOfferInfo.offerType            = introOffer.type
        introOfferInfo.paymentMode          = introOffer.paymentMode
        introOfferInfo.paymentModeDisplay   = paymentModeDisplay(mode: introOffer.paymentMode)
        introOfferInfo.offerPrice           = introOffer.displayPrice
        introOfferInfo.offerPeriodDisplay   = "\(introOffer.period.value) \(periodText(unit: introOffer.period.unit, value: introOffer.period.value))"
        introOfferInfo.offerPeriodUnit      = introOffer.period.unit
        introOfferInfo.offerPeriodValue     = introOffer.period.value
        introOfferInfo.offerPeriodCount     = introOffer.periodCount
        introOfferInfo.offerDisplay         = createOfferDisplay(for: introOffer.paymentMode, price: introOffer.displayPrice, periodUnit: introOffer.period.unit, periodValue: introOffer.period.value, periodCount: introOffer.periodCount, offerType: introOffer.type)
        
        return introOfferInfo
    }
    
    private func processPromotionalOffers(sub: Product.SubscriptionInfo, for productId: ProductId) -> [SubscriptionOfferInfo] {
        let promoOffers = sub.promotionalOffers  // Gets all the promotional offers defined for this particular subscription
        var promoOfferInfoArray = [SubscriptionOfferInfo]()
        guard !promoOffers.isEmpty else { return promoOfferInfoArray }
        
        promoOffers.forEach { promoOffer in
            var promoOfferInfo                  = SubscriptionOfferInfo(id: promoOffer.id, productId: productId)
            promoOfferInfo.offerType            = promoOffer.type
            promoOfferInfo.paymentMode          = promoOffer.paymentMode
            promoOfferInfo.paymentModeDisplay   = paymentModeDisplay(mode: promoOffer.paymentMode)
            promoOfferInfo.offerPrice           = promoOffer.displayPrice
            promoOfferInfo.offerPeriodDisplay   = "\(promoOffer.period.value) \(periodText(unit: promoOffer.period.unit, value: promoOffer.period.value))"
            promoOfferInfo.offerPeriodUnit      = promoOffer.period.unit
            promoOfferInfo.offerPeriodValue     = promoOffer.period.value
            promoOfferInfo.offerPeriodCount     = promoOffer.periodCount
            promoOfferInfo.offerDisplay         = createOfferDisplay(for: promoOffer.paymentMode, price: promoOffer.displayPrice, periodUnit: promoOffer.period.unit, periodValue: promoOffer.period.value, periodCount: promoOffer.periodCount, offerType: promoOffer.type)
            
            promoOfferInfoArray.append(promoOfferInfo)
        }
        
        return promoOfferInfoArray
    }
    
    private func createOfferDisplay(for paymentMode: Product.SubscriptionOffer.PaymentMode,
                                    price: String,
                                    periodUnit: Product.SubscriptionPeriod.Unit,
                                    periodValue: Int,
                                    periodCount: Int,
                                    offerType: Product.SubscriptionOffer.OfferType) -> String? {
        
        switch paymentMode {
            case .payAsYouGo: return "\(periodCount) \(periodText(unit: periodUnit, value: periodCount)) at\n \(offerType == .introductory ? "an introductory" : "a promotional") price of\n \(price) per \(periodText(unit: periodUnit, value: 1))"
            case .payUpFront: return "\(periodValue) \(periodText(unit: periodUnit, value: periodValue)) at\n \(offerType == .introductory ? "an introductory" : "a promotional") price of\n \(price)"
            case .freeTrial:  return "\(periodValue) \(periodText(unit: periodUnit, value: periodValue))\n\(offerType == .introductory ? "free trial" : "promotional period at no charge")"
            default: return nil
        }
    }
    
    private func periodText(unit: Product.SubscriptionPeriod.Unit, value: Int) -> String {
        switch unit {
            case .day:          return value > 1 ? "days"   : "day"
            case .week:         return value > 1 ? "weeks"  : "week"
            case .month:        return value > 1 ? "months" : "month"
            case .year:         return value > 1 ? "years"  : "year"
            @unknown default:   return value > 1 ? "months" : "month"
        }
    }
    
    private func paymentModeDisplay(mode: Product.SubscriptionOffer.PaymentMode) -> String {
        switch mode {
            case .freeTrial:    return "Free trial"
            case .payAsYouGo:   return "Pay as you go"
            case .payUpFront:   return "Pay up front"
            default:            return "Unknown"
        }
    }
}
