//
//  ProductListView.swift
//  ProductListView
//
//  Created by Russell Archer on 23/07/2021.
//

import SwiftUI

struct ProductListView: View {
    
    @EnvironmentObject var storeHelper: StoreHelper
    @Binding var showOptionsMenu: Bool
    
    var body: some View {
        
        if storeHelper.hasProducts {
            
            List {
                
                if let nonConsumables = storeHelper.nonConsumableProducts {
                    ProductListViewRow(products: nonConsumables, headerText: "Products")
                }
                
                if let consumables = storeHelper.consumableProducts {
                    ProductListViewRow(products: consumables, headerText: "VIP Services")
                }
                
                if let subscriptions = storeHelper.subscriptionProducts {
                    ProductListViewRow(products: subscriptions, headerText: "Subscriptions")
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

struct ProductListView_Previews: PreviewProvider {
    static var previews: some View {
        @StateObject var storeHelper = StoreHelper()
        return ProductListView(showOptionsMenu: .constant(false))
            .environmentObject(storeHelper)
    }
}
