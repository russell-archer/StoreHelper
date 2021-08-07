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
    
    @EnvironmentObject var storeHelper: StoreHelper
    @State var purchaseState: PurchaseState = .unknown
    
    var productId: ProductId
    var displayName: String
    var description: String
    var price: String
    
    var body: some View {
        VStack {
            HStack {
                Image(productId)
                    .resizable()
                    .frame(width: 75, height: 80)
                    .aspectRatio(contentMode: .fit)
                    .cornerRadius(25)
                
                Text(displayName)
                    .font(.headline)
                    .padding()
                
                Spacer()
                
                PurchaseButton(purchaseState: $purchaseState, productId: productId, price: price)
            }
            
            Text(description)
                .font(.subheadline)
                .foregroundColor(.gray)
                .lineLimit(2)
            
            if purchaseState == .purchased {
                PurchaseInfoView(productId: productId)
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
        
        VStack {
            HStack {
                Image("com.rarcher.nonconsumable.chocolates-small")
                    .resizable()
                    .frame(width: 75, height: 80)
                    .aspectRatio(contentMode: .fit)
                    .cornerRadius(25)
                
                Text("Small Chocolates")
                    .font(.title2)
                    .padding()
                    .lineLimit(1)
                
                Spacer()
                
                HStack {
                    Text("£1.99")
                        .font(.body)
                        .foregroundColor(.white)
                        .padding()
                        .frame(height: 40)
                        .background(Color.blue)
                        .cornerRadius(25)
                }
            }
            
            Text("Weekly home visits by an expert")
                .font(.subheadline)
                .foregroundColor(.gray)
                .lineLimit(2)
            
            HStack(alignment: .center) {
                Text("Purchased on 10-12-2021")
                    .font(.footnote)
                    .foregroundColor(.blue)
                    .padding(1)
            }
        }
        .padding()
    }
}
