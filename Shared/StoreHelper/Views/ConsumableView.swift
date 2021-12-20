//
//  ConsumableView.swift
//  StoreHelper
//
//  Created by Russell Archer on 21/06/2021.
//

import SwiftUI
import StoreKit

/// Displays a single row of product information for the main content List.
struct ConsumableView: View {
    
    @EnvironmentObject var storeHelper: StoreHelper
    @State var purchaseState: PurchaseState = .unknown
    @State var count: Int = 0
    @Binding var productInfoProductId: ProductId?
    @Binding var showProductInfoSheet: Bool
    
    var productId: ProductId
    var displayName: String
    var description: String
    var price: String
    
    var body: some View {
        VStack {
            HStack {
                if count == 0 {
                    
                    Image(productId)
                        .resizable()
                        .frame(width: 150, height: 150)
                        .aspectRatio(contentMode: .fit)
                        .cornerRadius(25)
                        .contentShape(Rectangle())
                        #if !os(tvOS)
                        .onTapGesture {
                            productInfoProductId = productId
                            showProductInfoSheet = true
                        }
                        #endif
                    
                } else {
                    
                    Image(productId)
                        .resizable()
                        .frame(width: 150, height: 150)
                        .aspectRatio(contentMode: .fit)
                        .cornerRadius(25)
                        .overlay(ConsumableBadgeView(count: $count))
                        .contentShape(Rectangle())
                        #if !os(tvOS)
                        .onTapGesture {
                            productInfoProductId = productId
                            showProductInfoSheet = true
                        }
                        #endif
                }
                
                Text(displayName)
                    .font(.headline)
                    .padding()
                    .lineLimit(3)
                    .contentShape(Rectangle())
                    #if !os(tvOS)
                    .onTapGesture {
                        productInfoProductId = productId
                        showProductInfoSheet = true
                    }
                    #endif
                
                Spacer()
                
                PurchaseButton(purchaseState: $purchaseState, productId: productId, price: price)
            }
            
            Text(description)
                .font(.subheadline)
                .foregroundColor(.gray)
                .lineLimit(2)
                .contentShape(Rectangle())
                #if !os(tvOS)
                .onTapGesture {
                    productInfoProductId = productId
                    showProductInfoSheet = true
                }
                #endif
            
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
        
        return ConsumableView(productInfoProductId: .constant("com.rarcher.consumable.plant-installation"),
                              showProductInfoSheet: .constant(false),
                              productId: "com.rarcher.consumable.plant-installation",
                              displayName: "Plant Installation",
                              description: "Expert plant installation",
                              price: "£0.99")
            .environmentObject(storeHelper)
    }
}
