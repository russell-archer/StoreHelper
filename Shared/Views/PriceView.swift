//
//  PriceView.swift
//  StoreHelper
//
//  Created by Russell Archer on 21/06/2021.
//

import SwiftUI
import StoreKit

/// Displays a product price and a button that enables purchasing.
struct PriceView: View {
    
    @EnvironmentObject var storeHelper: StoreHelper
    @Binding var purchaseState: PurchaseState
    
    var productId: ProductId
    var price: String
    var product: Product
    
    var body: some View {
        
        let priceViewModel = PriceViewModel(storeHelper: storeHelper, purchaseState: $purchaseState)
        
        HStack {
            
            Button(action: {
                purchaseState = .inProgress
                Task.init { await priceViewModel.purchase(product: product) }
                
            }) {
                Text(price)
                    .font(.body)
                    .foregroundColor(.white)
                    .padding()
                    .frame(height: 40)
                    .background(Color.blue)
                    .cornerRadius(25)
            }
        }
    }
}

struct PriceView_Previews: PreviewProvider {

    static var previews: some View {
        HStack {
            Button(action: {}) {
                Text("£1.98")
                    .font(.title2)
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

