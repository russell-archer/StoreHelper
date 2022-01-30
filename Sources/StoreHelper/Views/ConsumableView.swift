//
//  ConsumableView.swift
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
public struct ConsumableView: View {
    @EnvironmentObject var storeHelper: StoreHelper
    @State var purchaseState: PurchaseState = .unknown
    @State var count: Int = 0
    
    var productId: ProductId
    var displayName: String
    var description: String
    var price: String
    var productInfoCompletion: ((ProductId) -> Void)
    
    public var body: some View {
        VStack {
            Text(displayName).font(.largeTitle).padding(.bottom, 1)
            Text(description)
                #if os(iOS)
                .font(.subheadline)
                #endif
                .padding(EdgeInsets(top: 0, leading: 5, bottom: 3, trailing: 5))
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .contentShape(Rectangle())
                .onTapGesture { productInfoCompletion(productId) }
            
            HStack {
                if count == 0 {
                    
                    Image(productId)
                        .resizable()
                        .frame(maxWidth: 250, maxHeight: 250)
                        .aspectRatio(contentMode: .fit)
                        .cornerRadius(25)
                        .contentShape(Rectangle())
                        .onTapGesture { productInfoCompletion(productId) }
                    
                } else {
                    
                    Image(productId)
                        .resizable()
                        .frame(maxWidth: 250, maxHeight: 250)
                        .aspectRatio(contentMode: .fit)
                        .cornerRadius(25)
                        .overlay(ConsumableBadgeView(count: $count))
                        .contentShape(Rectangle())
                        .onTapGesture { productInfoCompletion(productId) }
                }
                
                Spacer()
                PurchaseButton(purchaseState: $purchaseState, productId: productId, price: price)
            }
            #if os(macOS)
            .frame(width: 500)
            #endif
            .padding()

            if purchaseState == .purchased {
                #if os(iOS)
                PurchaseInfoView(showRefundSheet: .constant(false), refundRequestTransactionId: .constant(UInt64.min), productId: productId)
                #elseif os(macOS)
                PurchaseInfoView(productId: productId)
                #endif
            }
            else {
                ProductInfoView(productId: productId, displayName: displayName, productInfoCompletion: productInfoCompletion)
            }
            
            Divider()
        }
        .padding()
        .onAppear {
            Task.init { await purchaseState(for: productId) }
            count = KeychainHelper.count(for: productId)
        }
        .onChange(of: storeHelper.purchasedProducts) { _ in
            Task.init { await purchaseState(for: productId) }
            count = KeychainHelper.count(for: productId)
            WidgetCenter.shared.reloadAllTimelines()
        }
    }
    
    func purchaseState(for productId: ProductId) async {
        let purchased = (try? await storeHelper.isPurchased(productId: productId)) ?? false
        purchaseState = purchased ? .purchased : .unknown
    }
}

struct ConsumableView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        @StateObject var storeHelper = StoreHelper()
        
        return ConsumableView(productId: "com.rarcher.consumable.plant-installation",
                              displayName: "Plant Installation",
                              description: "Expert plant installation",
                              price: "£0.99") { pid in }
            .environmentObject(storeHelper)
    }
}
