//
//  ProductView.swift
//  StoreHelper
//
//  Created by Russell Archer on 21/06/2021.
//

/*
 
 The arrangement of views is as follows:
 
 +---------------------------------------------------------------+
 | ContentView                                                   |
 |                                                               |
 | List {                                                        |
 |                                                               |
 | +----------------------------------------------------------+  |
 | | ProductView                                              |  |
 | |                                                          |  |
 | |    Product   Product  +-------------------------------+  |  |
 | |    Image      Name    | PurchaseButton                |  |  |
 | |                       |                               |  |  |
 | |                       | +-----------+  +------------+ |  |  |
 | |                       | | BadgeView |  | PriceView  | |  |  |
 | |                       | +-----------+  +------------+ |  |  |
 | |                       +-------------------------------+  |  |
 | |                                                          |  |
 | |    +--------------------------------------------------+  |  |
 | |    | PurchaseInfoView                                 |  |  |
 | |    +--------------------------------------------------+  |  |
 | |                                                          |  |
 | +----------------------------------------------------------+  |
 |                                                               |
 | }                                                             |
 +---------------------------------------------------------------+
 
 */

import SwiftUI
import StoreKit

/// Displays a single row of product information for the main content List.
struct ProductView: View {
    
    @EnvironmentObject var storeHelper: StoreHelper
    @State var purchaseState: PurchaseState = .unknown
    
    var productId: ProductId
    var displayName: String
    var price: String
    
    var body: some View {
        VStack(alignment: .leading) {
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
                
                PurchaseButton(purchaseState: $purchaseState, productId: productId, price: price)
            }
            
            if purchaseState == .purchased {
                PurchaseInfoView()
            }
        }
        .padding()
        .onAppear {
            Task.init { await purchaseState(for: productId) }
        }
        .onChange(of: storeHelper.purchasedProducts) { _ in
            Task.init { await purchaseState(for: productId) }
        }
    }
    
    func purchaseState(for productId: ProductId) async {
        let purchased = (try? await storeHelper.isPurchased(productId: productId)) ?? false
        purchaseState = purchased ? .purchased : .unknown
    }
}

struct ProductView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        @StateObject var storeHelper = StoreHelper()
        
        return ProductView(productId: "com.rarcher.nonconsumable.chocolates-small",
                           displayName: "Small Chocolates",
                           price: "£0.99").environmentObject(storeHelper)
    }
}
