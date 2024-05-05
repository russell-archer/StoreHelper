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
        
        var ppSubInfo = PrePurchaseSubscriptionInfo(
            product: product,
            subscriptionPeriod: subscription.subscriptionPeriod,
            introductoryOffer: processIntroductoryOffer(sub: subscription, for: product),
            promotionalOffers: processPromotionalOffers(sub: subscription, for: product)
        )
                
        ppSubInfo.promotionalOffersEligible = false
        ppSubInfo.introductoryOfferEligible = false
        // Are there one or more promotional offers, or an introductory offer available?
        if !ppSubInfo.promotionalOffers.isEmpty {
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
    
    private func processIntroductoryOffer(sub: Product.SubscriptionInfo, for product: Product) -> SubscriptionOfferInfo? {
        guard let introOffer                = sub.introductoryOffer else { return nil }  // Get the introductory offer for this particular subscription
        var introOfferInfo                  = SubscriptionOfferInfo(id: introOffer.id, productId: product.id)
        introOfferInfo.offerType            = introOffer.type
        introOfferInfo.paymentMode          = introOffer.paymentMode
        introOfferInfo.paymentModeDisplay   = paymentModeDisplay(mode: introOffer.paymentMode)
        introOfferInfo.offerPrice           = introOffer.displayPrice
        introOfferInfo.offerPeriodDisplay   = "\(introOffer.period.value) \(periodText(introOffer.period, product: product))"
        introOfferInfo.offerPeriodUnit      = introOffer.period.unit
        introOfferInfo.offerPeriodValue     = introOffer.period.value
        introOfferInfo.offerPeriodCount     = introOffer.periodCount
        introOfferInfo.offerDisplay         = createOfferDisplay(for: introOffer.paymentMode, product: product, price: introOffer.displayPrice, period: introOffer.period, periodCount: introOffer.periodCount, offerType: introOffer.type)

        return introOfferInfo
    }
    
    private func processPromotionalOffers(sub: Product.SubscriptionInfo, for product: Product) -> [SubscriptionOfferInfo] {
        let promoOffers = sub.promotionalOffers  // Gets all the promotional offers defined for this particular subscription
        var promoOfferInfoArray = [SubscriptionOfferInfo]()
        guard !promoOffers.isEmpty else { return promoOfferInfoArray }
        
        promoOffers.forEach { promoOffer in
            var promoOfferInfo                  = SubscriptionOfferInfo(id: promoOffer.id, productId: product.id)
            promoOfferInfo.offerType            = promoOffer.type
            promoOfferInfo.paymentMode          = promoOffer.paymentMode
            promoOfferInfo.paymentModeDisplay   = paymentModeDisplay(mode: promoOffer.paymentMode)
            promoOfferInfo.offerPrice           = promoOffer.displayPrice
            promoOfferInfo.offerPeriodDisplay   = "\(promoOffer.period.value) \(periodText(promoOffer.period, product: product))"
            promoOfferInfo.offerPeriodUnit      = promoOffer.period.unit
            promoOfferInfo.offerPeriodValue     = promoOffer.period.value
            promoOfferInfo.offerPeriodCount     = promoOffer.periodCount
            promoOfferInfo.offerDisplay         = createOfferDisplay(for: promoOffer.paymentMode, product: product, price: promoOffer.displayPrice, period: promoOffer.period, periodCount: promoOffer.periodCount, offerType: promoOffer.type)

            promoOfferInfoArray.append(promoOfferInfo)
        }
        
        return promoOfferInfoArray
    }

    private func createOfferDisplay(for paymentMode: Product.SubscriptionOffer.PaymentMode,
                                    product: Product,
                                    price: String,
                                    period: Product.SubscriptionPeriod,
                                    periodCount: Int,
                                    offerType: Product.SubscriptionOffer.OfferType) -> String? {

        switch paymentMode {
        case .payAsYouGo:
            return "\(periodCount) \(periodUnitText(period.unit, product: product)) at\n \(offerType == .introductory ? "an introductory" : "a promotional") price of\n \(price) per \(periodUnitText(period.unit, product: product))"
        case .payUpFront:
            return "\(periodText(period, product: product)) at\n \(offerType == .introductory ? "an introductory" : "a promotional") price of\n \(price)"
        case .freeTrial:
            return "\(periodText(period, product: product))\n\(offerType == .introductory ? "free trial" : "promotional period at no charge")"
        default:
            return nil
        }
    }

    private func periodUnitText(_ unit: Product.SubscriptionPeriod.Unit, product: Product) -> String {
        if #available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, visionOS 1.0, *) {
            let format = product.subscriptionPeriodUnitFormatStyle.locale(.current)
            return unit.formatted(format)
        } else if #available(iOS 15.4, macOS 12.3, tvOS 15.4, watchOS 8.6, *) {
            return unit.localizedDescription
        } else {
            switch unit {
            case .day:          return "day"
            case .week:         return "week"
            case .month:        return "month"
            case .year:         return "year"
            @unknown default:   return "unknown"
            }
        }
    }

    private func periodText(_ period: Product.SubscriptionPeriod, product: Product) -> String {
        var format = product.subscriptionPeriodFormatStyle
        format.style = .wide
        format.locale = .current
        return period.formatted(format)
    }
    
    private func paymentModeDisplay(mode: Product.SubscriptionOffer.PaymentMode) -> String {
        if #available(iOS 15.4, macOS 12.3, tvOS 15.4, watchOS 8.5, visionOS 1.0, *) {
            mode.localizedDescription
        } else {
            switch mode {
            case .freeTrial:    "Free trial"
            case .payAsYouGo:   "Pay as you go"
            case .payUpFront:   "Pay up front"
            default:            "Unknown"
            }
        }
    }
}
