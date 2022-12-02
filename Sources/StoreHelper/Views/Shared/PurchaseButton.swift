//
//  PurchaseButton.swift
//  StoreHelper
//
//  Created by Russell Archer on 21/06/2021.
//

import SwiftUI
import StoreKit

/// Provides a button that enables the user to purchase a product.
/// The product's price is also displayed in the localized currency.
@available(iOS 15.0, macOS 12.0, *)
public struct PurchaseButton: View {
    @EnvironmentObject var storeHelper: StoreHelper
    @Binding var purchaseState: PurchaseState
    private var productId: ProductId
    private var price: String
    private var signPromotionalOffer: ((ProductId, String) async -> Product.PurchaseOption?)?
    
    public init(purchaseState: Binding<PurchaseState>,
                productId: ProductId,
                price: String,
                signPromotionalOffer: ((ProductId, String) async -> Product.PurchaseOption?)? = nil) {
        
        self._purchaseState = purchaseState
        self.productId = productId
        self.price = price
        self.signPromotionalOffer = signPromotionalOffer
    }
    
    public var body: some View {
        
        let product = storeHelper.product(from: productId)
        if product == nil {
            
            StoreErrorView()
            
        } else {
            
            VStack {
                
                if product!.type == .consumable {
                    
                    if purchaseState != .purchased { withAnimation { BadgeView(purchaseState: $purchaseState) }}
                    PriceView(purchaseState: $purchaseState, productId: productId, price: price, product: product!)
                    
                } else {
                    
                    withAnimation { BadgeView(purchaseState: $purchaseState) }
                    if purchaseState != .purchased {
                        PriceView(purchaseState: $purchaseState, productId: productId, price: price, product: product!, signPromotionalOffer: signPromotionalOffer)
                    }
                }
            }
        }
    }
}

@available(iOS 15.0, macOS 12.0, *)
struct PurchaseButton_Previews: PreviewProvider {
    static var previews: some View {

        @StateObject var storeHelper = StoreHelper()
        @State var purchaseState: PurchaseState = .inProgress

        return PurchaseButton(purchaseState: $purchaseState,
                              productId: "nonconsumable.flowers-large",
                              price: "£1.99")
            .environmentObject(storeHelper)
    }
}
