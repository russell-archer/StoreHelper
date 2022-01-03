//
//  ProductView.swift
//  StoreHelper
//
//  Created by Russell Archer on 21/06/2021.
//

import SwiftUI
import StoreKit
import WidgetKit

/// Displays a single row of product information for the main content List.
struct ProductView: View {
    #if os(iOS)
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    #endif
    
    @EnvironmentObject var storeHelper: StoreHelper
    @State var purchaseState: PurchaseState = .unknown
    @Binding var productInfoProductId: ProductId?
    @Binding var showProductInfoSheet: Bool
    
    var productId: ProductId
    var displayName: String
    var description: String
    var price: String
    
    #if os(iOS)
    var body: some View {
        VStack {
            Text(displayName).font(.largeTitle)
            
            if horizontalSizeClass == .compact {
                HStack {
                    Image(productId)
                        .resizable()
                        .frame(width: 150, height: 150)
                        .aspectRatio(contentMode: .fit)
                        .cornerRadius(25)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            productInfoProductId = productId
                            showProductInfoSheet = true
                        }
                    
                    Spacer()
                    PurchaseButton(purchaseState: $purchaseState, productId: productId, price: price)
                }
            } else {
                HStack {
                    Image(productId)
                        .resizable()
                        .frame(width: 250, height: 250)
                        .aspectRatio(contentMode: .fit)
                        .cornerRadius(25)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            productInfoProductId = productId
                            showProductInfoSheet = true
                        }
                    
                    Spacer()
                    PurchaseButton(purchaseState: $purchaseState, productId: productId, price: price)
                }
                .frame(width: 500)
            }
            
            Button(action: {
                productInfoProductId = productId
                showProductInfoSheet = true
            }) {
                VStack {
                    Image(systemName: "info.circle")
                        .resizable()
                        .frame(width: 40, height: 40)
                        .aspectRatio(contentMode: .fit)
                    Text("More Info").font(.subheadline)
                }
            }
            
            Text(description)
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .padding()
                .foregroundColor(.gray)
                .lineLimit(2)
                .contentShape(Rectangle())
                .onTapGesture {
                    productInfoProductId = productId
                    showProductInfoSheet = true
                }
            
            if purchaseState == .purchased {
                PurchaseInfoView(productId: productId)
            }
            
            Divider()
        }
        .padding()
        .onAppear {
            Task.init { await purchaseState(for: productId) }
        }
        .onChange(of: storeHelper.purchasedProducts) { _ in
            Task.init {
                await purchaseState(for: productId)
                WidgetCenter.shared.reloadAllTimelines()
            }
        }
    }
    #endif
    
    #if os(macOS)
    var body: some View {
        VStack {
            Text(displayName).font(.largeTitle)
            HStack {
                Image(productId)
                    .resizable()
                    .frame(width: 250, height: 250)
                    .aspectRatio(contentMode: .fit)
                    .cornerRadius(25)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        productInfoProductId = productId
                        showProductInfoSheet = true
                    }
                
                Spacer()
                PurchaseButton(purchaseState: $purchaseState, productId: productId, price: price)
            }
            .frame(width: 500)
            
            Button(action: {
                productInfoProductId = productId
                showProductInfoSheet = true
            }) {
                VStack {
                    Image(systemName: "info.circle")
                        .resizable()
                        .frame(width: 40, height: 40)
                        .aspectRatio(contentMode: .fit)
                    Text("More Info").font(.subheadline)
                }
            }
            .macOSStyle()
            
            Text(description)
                .multilineTextAlignment(.center)
                .padding(EdgeInsets(top: 5, leading: 5, bottom: 1, trailing: 5))
                .foregroundColor(.gray)
                .lineLimit(2)
                .contentShape(Rectangle())
                .onTapGesture {
                    productInfoProductId = productId
                    showProductInfoSheet = true
                }
            
            if purchaseState == .purchased {
                PurchaseInfoView(productId: productId)
            }
            
            Divider()
        }
        .padding()
        .onAppear {
            Task.init { await purchaseState(for: productId) }
        }
        .onChange(of: storeHelper.purchasedProducts) { _ in
            Task.init {
                await purchaseState(for: productId)
                WidgetCenter.shared.reloadAllTimelines()
            }
        }
    }
    #endif
    
    func purchaseState(for productId: ProductId) async {
        let purchased = (try? await storeHelper.isPurchased(productId: productId)) ?? false
        purchaseState = purchased ? .purchased : .unknown
    }
}

