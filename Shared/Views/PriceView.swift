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
    
    // Access the storeHelper object that has been created by @StateObject in StoreHelperApp
    @EnvironmentObject var storeHelper: StoreHelper
    
    @Binding var purchasing: Bool
    @Binding var cancelled: Bool
    @Binding var pending: Bool
    @Binding var failed: Bool
    @Binding var purchased: Bool
    
    var productId: ProductId
    var price: String
    var product: Product
    
    var body: some View {
        
        let priceViewModel = PriceViewModel(storeHelper: storeHelper,
                                            purchasing: $purchasing,
                                            cancelled: $cancelled,
                                            pending: $pending,
                                            failed: $failed,
                                            purchased: $purchased)
        
        HStack {
            
            if purchasing {
                ProgressView()
            }
            
            Spacer()
            
            Button(action: {
                purchasing = true
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
            ProgressView()
            Spacer()
            Button(action: {}) {
                Text("£1.99")
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

