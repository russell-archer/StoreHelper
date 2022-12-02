//
//  ProductListViewRow-ios.swift
//  StoreHelper
//
//  Created by Russell Archer on 23/07/2021.
//
// View hierachy:
// Non-Consumables: [Products].[ProductListView].[ProductListViewRow]......[ProductView]......[if purchased].[PurchaseInfoView].....[PurchaseInfoSheet]
// Consumables:     [Products].[ProductListView].[ProductListViewRow]......[ConsumableView]...[if purchased].[PurchaseInfoView].....[PurchaseInfoSheet]
// Subscriptions:   [Products].[ProductListView].[SubscriptionListViewRow].[SubscriptionView].[if purchased].[SubscriptionInfoView].[SubscriptionInfoSheet]

import SwiftUI
import StoreKit

#if os(iOS)
@available(iOS 15.0, *)
public struct ProductListViewRow: View {
    @EnvironmentObject var storeHelper: StoreHelper
    @Binding var showRefundSheet: Bool
    @Binding var refundRequestTransactionId: UInt64
    private var products: [Product]
    private var headerText: String
    private var productInfoCompletion: ((ProductId) -> Void)
    
    public init(showRefundSheet: Binding<Bool>,
                refundRequestTransactionId: Binding<UInt64>,
                products: [Product],
                headerText: String,
                productInfoCompletion: @escaping ((ProductId) -> Void)) {
        
        self._showRefundSheet = showRefundSheet
        self._refundRequestTransactionId = refundRequestTransactionId
        self.products = products
        self.headerText = headerText
        self.productInfoCompletion = productInfoCompletion
    }
    
    public var body: some View {
        Section(content: {
            if let p = products.first {
                if p.type == .consumable {
                    ForEach(products, id: \.id) { product in
                        ConsumableView(productId: product.id,
                                       displayName: product.displayName,
                                       description: product.description,
                                       price: product.displayPrice,
                                       productInfoCompletion: productInfoCompletion)
                        .contentShape(Rectangle())
                        .onTapGesture { productInfoCompletion(product.id)}
                    }
                } else {
                    ForEach(products, id: \.id) { product in
                        ProductView(showRefundSheet: $showRefundSheet,
                                    refundRequestTransactionId: $refundRequestTransactionId,
                                    productId: product.id,
                                    displayName: product.displayName,
                                    description: product.description,
                                    price: product.displayPrice,
                                    productInfoCompletion: productInfoCompletion)
                        .contentShape(Rectangle())
                        .onTapGesture { productInfoCompletion(product.id) }
                    }
                }
            }
        }, header: { BodyFont(scaleFactor: storeHelper.fontScaleFactor) { Text(headerText)}})
    }
}
#endif
