//
//  PurchaseButton.swift
//  StoreHelper
//
//  Created by Russell Archer on 21/06/2021.
//

import SwiftUI
import StoreKit

struct PurchaseButton: View {
    
    @ObservedObject var storeHelper: StoreHelper
    
    @State var purchasing: Bool = false
    @State var cancelled: Bool = false
    @State var pending: Bool = false
    @State var failed: Bool = false
    @State var purchased: Bool = false
    
    var productId: ProductId
    var price: String
    
    var body: some View {
        
        let product = storeHelper.product(from: productId)
        if product == nil {
            
            StoreErrorView()
            
        } else {
            
            HStack {
                if purchased {
                    
                    BadgeView(purchaseState: .complete)
                    
                } else {
                    
                    if cancelled { BadgeView(purchaseState: .cancelled) }
                    if pending { BadgeView(purchaseState: .pending) }
                    
                    PriceView(storeHelper: storeHelper,
                              purchasing: $purchasing,
                              cancelled: $cancelled,
                              pending: $pending,
                              failed: $failed,
                              purchased: $purchased,
                              productId: productId,
                              price: price,
                              product: product!)
                }
            }
            .onAppear {
                async { await purchaseState(for: product!) }
            }
            .onChange(of: storeHelper.purchasedProducts) { _ in
                async { await purchaseState(for: product!) }
            }
            .alert(isPresented: $failed) {
                
                Alert(title: Text("Purchase Error"),
                      message: Text("Sorry, your purchase of \(product!.displayName) failed."),
                      dismissButton: .default(Text("OK")))
            }
        }
    }
    
    func purchaseState(for product: Product) async {
        purchased = (try? await storeHelper.isPurchased(product: product)) ?? false
    }
}

struct PurchaseButton_Previews: PreviewProvider {
    static var previews: some View {
        PurchaseButton(storeHelper: StoreHelper(), productId: "nonconsumable.flowers-large", price: "£1.99")
    }
}
