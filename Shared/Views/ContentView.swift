//
//  ContentView.swift
//  Shared
//
//  Created by Russell Archer on 16/06/2021.
//

import SwiftUI

struct ContentView: View {
    
    @StateObject var storeHelper = StoreHelper()
    
    var body: some View {
        
        if storeHelper.hasProducts {
            
            List(storeHelper.products!) { product in
                ProductView(storeHelper: storeHelper,
                            productId: product.id,
                            displayName: product.displayName,
                            price: product.displayPrice)
            }
            .listStyle(.inset)
            
        } else {
            
            Text("No products")
                .font(.title)
                .foregroundColor(.red)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    
    static var previews: some View {
        ContentView()
    }
}


