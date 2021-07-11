//
//  ContentView.swift
//  Shared
//
//  Created by Russell Archer on 16/06/2021.
//

import SwiftUI

/// The main app View.
struct ContentView: View {
    
    // Access the storeHelper object that has been created by @StateObject in StoreHelperApp
    @EnvironmentObject var storeHelper: StoreHelper
    
    var body: some View {
        
        if storeHelper.hasProducts {
            
            List {
                
                if let nonConsumables = storeHelper.nonConsumableProducts {
                    Section(header: Text("Products")) {
                        ForEach(nonConsumables, id: \.id) { product in
                            ProductView(productId: product.id, displayName: product.displayName, price: product.displayPrice)
                        }
                    }
                }
                
                if let consumables = storeHelper.consumableProducts {
                    Section(header: Text("VIP Services")) {
                        ForEach(consumables, id: \.id) { product in
                            ConsumableView(productId: product.id, displayName: product.displayName, price: product.displayPrice)
                        }
                    }
                }
                
                if let subscriptions = storeHelper.subscriptionProducts {
                    Section(header: Text("Subscriptions")) {
                        ForEach(subscriptions, id: \.id) { product in
                            ProductView(productId: product.id, displayName: product.displayName, price: product.displayPrice)
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            
        } else {
            
            Text("No products available")
                .font(.title)
                .foregroundColor(.red)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        @StateObject var storeHelper = StoreHelper()
        return List {
            Section(header: Text("Products")) {
                ProductView(
                    productId: "com.rarcher.nonconsumable.flowers-large",
                    displayName: "Large Flowers",
                    price: "4.99")
                
                ProductView(
                    productId: "com.rarcher.nonconsumable.flowers-small",
                    displayName: "Large Flowers",
                    price: "4.99")
                
                ProductView(
                    productId: "com.rarcher.nonconsumable.roses-large",
                    displayName: "Large Flowers",
                    price: "4.99")
            }
            
            Section(header: Text("VIP Services")) {
                ProductView(
                    productId: "com.rarcher.consumable.plant-installation",
                    displayName: "Plant Installation",
                    price: "4.99")
            }
            
            Section(header: Text("Subscriptions")) {
                ProductView(
                    productId: "com.rarcher.subscription.gold",
                    displayName: "Gold. Weekly Home Visits",
                    price: "4.99")
                
                ProductView(
                    productId: "com.rarcher.subscription.silver",
                    displayName: "Silver. Visits every 2 weeks",
                    price: "4.99")
                
                ProductView(
                    productId: "com.rarcher.subscription.bronze",
                    displayName: "Bronze. Monthly home visits",
                    price: "4.99")
            }
        }
        .listStyle(.insetGrouped)
        .environmentObject(storeHelper)
    }
}


