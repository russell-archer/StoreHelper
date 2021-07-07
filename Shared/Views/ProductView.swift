//
//  ProductView.swift
//  StoreHelper
//
//  Created by Russell Archer on 21/06/2021.
//

import SwiftUI
import StoreKit

/// Displays a single row of product information for the main content List.
struct ProductView: View {
    
    // Access the storeHelper object that has been created by @StateObject in StoreHelperApp
    @EnvironmentObject var storeHelper: StoreHelper
    
    var productId: ProductId
    var displayName: String
    var price: String
    
    var body: some View {
        HStack {
            Image(productId)
                .resizable()
                .frame(width: 75, height: 80)
                .aspectRatio(contentMode: .fit)
                .cornerRadius(25)
            
            Text(displayName)
                .font(.title2)
                .padding()
                .lineLimit(2)
                .minimumScaleFactor(0.5)
            
            Spacer()
            
            PurchaseButton(productId: productId, price: price)
        }
        .padding()
    }
}

struct ProductView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        @StateObject var storeHelper = StoreHelper()
//        return ProductView(productId: "com.rarcher.nonconsumable.chocolates-small",
//                           displayName: "Large Flowers",
//                           price: "£0.99").environmentObject(storeHelper)
        
        return ProductView(
            productId: "com.rarcher.subscription.gold",
            displayName: "Gold. Weekly Home Visits",
            price: "4.99").environmentObject(storeHelper)
    }
}
