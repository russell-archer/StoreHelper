//
//  PriceView.swift
//  StoreHelper
//
//  Created by Russell Archer on 21/06/2021.
//

import SwiftUI
import StoreKit

/// Displays a product price and a button that enables purchasing.
public struct PriceView: View {
    @EnvironmentObject var storeHelper: StoreHelper
    @State private var canMakePayments: Bool = false
    @Binding var purchaseState: PurchaseState  // Propagates the result of a purchase back from `PriceViewModel`
    
    var productId: ProductId
    var price: String
    var product: Product
    
    public var body: some View {
        
        let priceViewModel = PriceViewModel(storeHelper: storeHelper, purchaseState: $purchaseState)
        
        HStack {
            
            #if os(iOS)
            Button(action: {
                withAnimation { purchaseState = .inProgress }
                Task.init { await priceViewModel.purchase(product: product) }
            }) {
                PriceButtonText(price: price, disabled: !canMakePayments)
            }
            .disabled(!canMakePayments)
            #elseif os(macOS)
            HStack { PriceButtonText(price: price, disabled: !canMakePayments)}
            .contentShape(Rectangle())
            .onTapGesture {
                guard canMakePayments else { return }
                withAnimation { purchaseState = .inProgress }
                Task.init { await priceViewModel.purchase(product: product) }
            }
            #endif
        }
        .onAppear { canMakePayments = AppStore.canMakePayments }
    }
}

public struct PriceButtonText: View {
    @EnvironmentObject var storeHelper: StoreHelper
    var price: String
    var disabled: Bool
    
    #if os(iOS)
    var frameWidth: CGFloat = 95
    #elseif os(macOS)
    var frameWidth: CGFloat = 100
    #endif
    
    public var body: some View {
        Text(disabled ? "Disabled" : price)  // Don't use scaled fonts for the price at it can lead to truncation
            .font(.body)
            .foregroundColor(.white)
            .padding()
            .frame(width: frameWidth, height: 40)
            .fixedSize()
            .background(Color.blue)
            .cornerRadius(25)
            .padding(.leading, 10)
    }
}

struct PriceView_Previews: PreviewProvider {

    static var previews: some View {
        HStack {
            Button(action: {}) {
                Text("£1.98")
                    .foregroundColor(.white)
                    .padding()
                    .frame(height: 40)
                    .background(Color.blue)
                    .cornerRadius(25)
            }
        }
        .padding()
    }
}

