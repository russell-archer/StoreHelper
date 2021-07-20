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
    
    @State var purchased: Bool = true
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
                PurchaseButton(productId: productId, price: price)
            }
            
            if purchased {
                PurchaseInfoView()
            }
        }
        .onAppear {
            Task.init { await purchaseState(for: productId) }
        }
        .onChange(of: storeHelper.purchasedProducts) { _ in
            Task.init { await purchaseState(for: productId) }
        }
        .padding()
    }
    
    func purchaseState(for productId: ProductId) async {
        purchased = (try? await storeHelper.isPurchased(productId: productId)) ?? false
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
