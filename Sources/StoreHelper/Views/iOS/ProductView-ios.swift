//
//  ProductView-ios.swift
//  StoreHelper
//
//  Created by Russell Archer on 21/06/2021.
//
// View hierachy:
// Non-Consumables: [Products].[ProductListView].[ProductListViewRow]......[ProductView]......[if purchased].[PurchaseInfoView].....[PurchaseInfoSheet]
// Consumables:     [Products].[ProductListView].[ProductListViewRow]......[ConsumableView]...[if purchased].[PurchaseInfoView].....[PurchaseInfoSheet]
// Subscriptions:   [Products].[ProductListView].[SubscriptionListViewRow].[SubscriptionView].[if purchased].[SubscriptionInfoView].[SubscriptionInfoSheet]

import SwiftUI
import StoreKit
import WidgetKit

/// Displays a single row of product information for the main content List.
#if os(iOS)
@available(iOS 15.0, *)
public struct ProductView: View {
    @EnvironmentObject var storeHelper: StoreHelper
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @State var purchaseState: PurchaseState = .unknown
    @Binding var showRefundSheet: Bool
    @Binding var refundRequestTransactionId: UInt64
    private var productId: ProductId
    private var displayName: String
    private var description: String
    private var price: String
    private var productInfoCompletion: ((ProductId) -> Void)
    
    public init(showRefundSheet: Binding<Bool>,
                refundRequestTransactionId: Binding<UInt64>,
                productId: ProductId,
                displayName: String,
                description: String,
                price: String,
                productInfoCompletion: @escaping ((ProductId) -> Void)) {
        
        self._showRefundSheet = showRefundSheet
        self._refundRequestTransactionId = refundRequestTransactionId
        self.productId = productId
        self.displayName = displayName
        self.description = description
        self.price = price
        self.productInfoCompletion = productInfoCompletion
    }
    
    public var body: some View {
        VStack {
            LargeTitleFont(scaleFactor: storeHelper.fontScaleFactor) { Text(displayName)}.padding(.bottom, 1)
            SubHeadlineFont(scaleFactor: storeHelper.fontScaleFactor) { Text(description)}
                .padding(EdgeInsets(top: 0, leading: 5, bottom: 3, trailing: 5))
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .contentShape(Rectangle())
                .onTapGesture { productInfoCompletion(productId) }
            
            if horizontalSizeClass == .compact {
                VStack {
                    Image(productId)
                        .resizable()
                        .frame(maxWidth: 250, maxHeight: 250)
                        .aspectRatio(contentMode: .fit)
                        .cornerRadius(25)
                        .contentShape(Rectangle())
                        .onTapGesture { productInfoCompletion(productId) }
                    
                    PurchaseButton(purchaseState: $purchaseState, productId: productId, price: price)
                }
            } else {
                HStack {
                    Image(productId)
                        .resizable()
                        .frame(maxWidth: 250, maxHeight: 250)
                        .aspectRatio(contentMode: .fit)
                        .cornerRadius(25)
                        .contentShape(Rectangle())
                        .onTapGesture { productInfoCompletion(productId) }
                    
                    Spacer()
                    PurchaseButton(purchaseState: $purchaseState, productId: productId, price: price)
                }
            }
            
            if purchaseState == .purchased {
                PurchaseInfoView(showRefundSheet: $showRefundSheet, refundRequestTransactionId: $refundRequestTransactionId, productId: productId)
            }
            else {
                ProductInfoView(productId: productId, displayName: displayName, productInfoCompletion: productInfoCompletion)
            }
            
            Divider()
        }
        .padding()
        .task { await purchaseState(for: productId)}
        .onChange(of: storeHelper.purchasedProducts) { _ in
            Task.init {
                await purchaseState(for: productId)
                WidgetCenter.shared.reloadAllTimelines()
            }
        }
    }
    
    public func purchaseState(for productId: ProductId) async {
        let purchased = (try? await storeHelper.isPurchased(productId: productId)) ?? false
        purchaseState = purchased ? .purchased : .unknown
    }
}
#endif
