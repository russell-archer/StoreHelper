//
//  PriceView.swift
//  StoreHelper
//
//  Created by Russell Archer on 21/06/2021.
//

import SwiftUI
import StoreKit

/// Displays a product price and a button that enables purchasing.
#if os(macOS)
@available(macOS 12.0, *)
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
            HStack { PriceButtonText(price: price, disabled: !canMakePayments)}
            .contentShape(Rectangle())
            .onTapGesture {
                guard canMakePayments else { return }
                withAnimation { purchaseState = .inProgress }
                Task.init { await priceViewModel.purchase(product: product) }
            }
        }
        .onAppear { canMakePayments = AppStore.canMakePayments }
    }
}

@available(macOS 12.0, *)
public struct PriceButtonText: View {
    @EnvironmentObject var storeHelper: StoreHelper
    var price: String
    var disabled: Bool
    
    public var body: some View {
        Text(disabled ? "Disabled" : price)  // Don't use scaled fonts for the price at it can lead to truncation
            .font(.body)
            .foregroundColor(.white)
            .padding()
            .frame(height: 40)
            .fixedSize()
            .background(Color.blue)
            .cornerRadius(25)
    }
}

@available(iOS 15.0, macOS 12.0, *)
struct PriceView_Previews: PreviewProvider {

    static var previews: some View {
        HStack {
            Button(action: {}) {
                Text("USD $1.98")
                    .font(.body)
                    .foregroundColor(.white)
                    .padding()
                    .frame(height: 40)
                    .padding(.leading, 0)
                    .fixedSize()
                    .background(Color.blue)
                    .cornerRadius(25)
            }
        }
        .padding()
    }
}
#endif
