//
//  ProductListViewRow.swift
//  ProductListViewRow
//
//  Created by Russell Archer on 23/07/2021.
//

import SwiftUI
import StoreKit

struct ProductListViewRow: View {
    
    @EnvironmentObject var storeHelper: StoreHelper
    var products: [Product]
    var headerText: String
    
    var body: some View {
        Section(header: Text(headerText)) {
            if let p = products.first {
                if p.type == .consumable {
                    ForEach(products, id: \.id) { product in
                        ConsumableView(productId: product.id, displayName: product.displayName, description: product.description, price: product.displayPrice)
                    }
                } else {
                    ForEach(products, id: \.id) { product in
                        ProductView(productId: product.id, displayName: product.displayName, description: product.description, price: product.displayPrice)
                    }
                }
            }
        }
    }
}

