//
//  ProductView.swift
//  StoreHelper
//
//  Created by Russell Archer on 21/06/2021.
//

import SwiftUI
import StoreKit

struct ProductView: View {
    
    @ObservedObject var storeHelper: StoreHelper
    
    var productId: ProductId
    var displayName: String
    var price: String
    
    var body: some View {
        HStack {
            Image(productId)
                .resizable()
                .frame(width: 75, height: 75)
                .aspectRatio(contentMode: .fit)
                .cornerRadius(25)
            
            Text(displayName)
                .font(.title2)
                .padding()
            
            Spacer()
            
            PurchaseButton(storeHelper: storeHelper, productId: productId, price: price)
        }
        .padding()
    }
}

struct ProductView_Previews: PreviewProvider {
    
    static var previews: some View {
        ProductView(storeHelper: StoreHelper(),
                    productId: "nonconsumable.flowers-large",
                    displayName: "flowers-large",
                    price: "£0.99")
    }
}
