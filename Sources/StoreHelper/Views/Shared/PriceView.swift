//
//  PriceView.swift
//  StoreHelper
//
//  Created by Russell Archer on 21/06/2021.
//

import SwiftUI
import StoreKit

/// Displays a consumable, non-consumable product's price on a button that enables purchasing. If the product is a subscription,
/// the price and renewal period is displayed on a button that enables purchasing. If a subscription has one or more eligible offers
/// then these are displayed in preference to the standard price and renewal period.
@available(iOS 15.0, macOS 12.0, *)
public struct PriceView: View {
    @EnvironmentObject var storeHelper: StoreHelper
    @State private var canMakePayments: Bool = false
    @State private var isSubscription = false
    @State private var isSubscribed = false
    @State private var prePurchaseSubInfo: PrePurchaseSubscriptionInfo?
    @State private var signedPromotionalOffer: Product.PurchaseOption?  // The signed promotional offer created by the app on request
    @State private var showPromoSigningError = false
    @Binding var purchaseState: PurchaseState  // Propagates the result of a purchase back from `PriceViewModel`
    private var productId: ProductId
    private var price: String
    private var product: Product
    private var signPromotionalOffer: ((ProductId, String) async -> Product.PurchaseOption?)?
    
    public init(purchaseState: Binding<PurchaseState>,
                productId: ProductId,
                price: String,
                product: Product,
                signPromotionalOffer: ((ProductId, String) async -> Product.PurchaseOption?)? = nil) {
        
        self._purchaseState = purchaseState
        self.productId = productId
        self.price = price
        self.product = product
        self.signPromotionalOffer = signPromotionalOffer
    }
    
    public var body: some View {
        let priceViewModel = PriceViewModel(storeHelper: storeHelper, purchaseState: $purchaseState)
        
        VStack {
            if isSubscription, !isSubscribed {
                // Show price(s)/renewal period(s) only if we're looking at a subscription and the user's not currently subscribed
                if let prePurchaseSubInfo, let purchasePriceForDisplay = prePurchaseSubInfo.purchasePriceForDisplay {
                    // Display all the promotional, introductory and standard offers (there can be multiple promotional offers)
                    ForEach(purchasePriceForDisplay) { priceForDisplay in
                        Button(action: {
                            guard canMakePayments else { return }
                            withAnimation { purchaseState = .inProgress }
                            
                            // Is it a promotional offer (an introductory or standard offer will have a promo id of nil)?
                            Task.init {
                                if let promoId = priceForDisplay.id {
                                    // If the host app has provided a promo signature closure, ask the app to sign the promotional offer
                                    if let signPromotionalOffer, let signedPromotionalOffer = await signPromotionalOffer(product.id, promoId) {
                                        // Complete the purchase with the signed promo offer
                                        await priceViewModel.purchase(product: product, options: [signedPromotionalOffer])
                                    } else {
                                        withAnimation { purchaseState = .cancelled }
                                        showPromoSigningError = true
                                    }
                                } else {
                                    // It's an introductory or standard price. The App Store will automatically apply the eligible introductory offer
                                    await priceViewModel.purchase(product: product)
                                }
                            }
                        }) {
                            PriceButtonTextSubscription(disabled: !canMakePayments, price: priceForDisplay.price)
                        }
                        .xPlatformButtonStyleBorderless()
                        .disabled(!canMakePayments)
                    }
                }
                
            } else {
                // Price for non-subscription product
                Button(action: {
                    withAnimation { purchaseState = .inProgress }
                    Task.init { await priceViewModel.purchase(product: product) }
                }) {
                    PriceButtonText(price: price, disabled: !canMakePayments)
                }
                .xPlatformButtonStyleBorderless()
                .disabled(!canMakePayments)
            }
        }
        .task {
            canMakePayments = AppStore.canMakePayments
            
            // Is the product a subscription? If it is, see if the user is already subscribed. If they're NOT subscribed,
            // get information on the subscription (including price and renewal period), plus any introductory and
            // promotional subscriptions offers that are available
            if product.type == .autoRenewable {
                isSubscription = true
                isSubscribed = purchaseState == .purchased

                if !isSubscribed {
                    prePurchaseSubInfo = await priceViewModel.getPrePurchaseSubscriptionInfo(productId: productId)
                }
            }
        }
        .alert("Unable to apply promotional offer pricing.", isPresented: $showPromoSigningError) {
            Button("OK") { showPromoSigningError.toggle() }
        }
    }
}

