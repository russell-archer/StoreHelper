//
//  ProductView-macos.swift
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
#if canImport(WidgetKit)
import WidgetKit
#endif

/// Displays a single row of product information for the main content List.
@available(iOS 15.0, macOS 12.0, *)
public struct ProductView: View {
    @EnvironmentObject var storeHelper: StoreHelper
    @State var purchaseState: PurchaseState = .unknown
    @State var notForSale: Bool = false
    @State var reasonProductIsNotForSale = ""
    private var productId: ProductId
    private var displayName: String
    private var description: String
    private var price: String
    private var productInfoCompletion: ((ProductId) -> Void)
    
    #if os(iOS) || os(tvOS) || os(visionOS)
    @Binding var showRefundSheet: Bool
    @Binding var refundRequestTransactionId: UInt64
    #endif
    
    #if os(iOS) || os(tvOS) || os(visionOS)
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
    #else
    public init(productId: ProductId,
                displayName: String,
                description: String,
                price: String,
                productInfoCompletion: @escaping ((ProductId) -> Void)) {
        
        self.productId = productId
        self.displayName = displayName
        self.description = description
        self.price = price
        self.productInfoCompletion = productInfoCompletion
    }
    #endif
    
    public var body: some View {
        VStack {
            LargeTitleFont(scaleFactor: storeHelper.fontScaleFactor) { Text(displayName)}.padding(5)
            SubHeadlineFont(scaleFactor: storeHelper.fontScaleFactor) { Text(description)}
                .padding(EdgeInsets(top: 0, leading: 5, bottom: 3, trailing: 5))
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .contentShape(Rectangle())
                .xPlatformOnTapGesture { productInfoCompletion(productId) }
            
            Image(productId)
                .resizable()
                .frame(maxWidth: 250, maxHeight: 250)
                .aspectRatio(contentMode: .fit)
                .cornerRadius(25)
                .contentShape(Rectangle())
                .xPlatformOnTapGesture { productInfoCompletion(productId) }
            
            if notForSale {
                SubHeadlineFont(scaleFactor: storeHelper.fontScaleFactor) {
                    Text(reasonProductIsNotForSale).foregroundColor(.red).padding() }}
            else { PurchaseButton(purchaseState: $purchaseState, productId: productId, price: price) }
            
            if purchaseState == .purchased {
                #if os(iOS) || os(tvOS) || os(visionOS)
                PurchaseInfoView(showRefundSheet: $showRefundSheet, refundRequestTransactionId: $refundRequestTransactionId, productId: productId)
                #else
                PurchaseInfoView(productId: productId)
                #endif
            } else {
                ProductInfoView(productId: productId, displayName: displayName, productInfoCompletion: productInfoCompletion)
            }
            
            Divider()
        }
        .task {
            await purchaseState(for: productId)
            notForSale = storeHelper.isProductForSale(productId)
            if notForSale { reasonProductIsNotForSale = storeHelper.reasonProductIsNotForSale(productId) ?? "" }
        }
        .onChange(of: storeHelper.purchasedProducts) { _ in
            Task.init {
                await purchaseState(for: productId)
                #if canImport(WidgetKit)
                WidgetCenter.shared.reloadAllTimelines()
                #endif
            }
        }
    }
    
    public func purchaseState(for productId: ProductId) async {
        let purchased = (try? await storeHelper.isPurchased(productId: productId)) ?? false
        purchaseState = purchased ? .purchased : .notPurchased
    }
}

