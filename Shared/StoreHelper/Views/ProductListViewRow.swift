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
    @Binding var productInfoProductId: ProductId?
    @Binding var showProductInfoSheet: Bool
    var products: [Product]
    var headerText: String
    
    var body: some View {
        Section(header: Text(headerText)) {
            if let p = products.first {
                if p.type == .consumable {
                    ForEach(products, id: \.id) { product in
                        ConsumableView(productInfoProductId: $productInfoProductId, showProductInfoSheet: $showProductInfoSheet, productId: product.id, displayName: product.displayName, description: product.description, price: product.displayPrice)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                productInfoProductId = product.id
                                showProductInfoSheet = true
                            }
                    }
                } else {
                    ForEach(products, id: \.id) { product in
                        ProductView(productInfoProductId: $productInfoProductId, showProductInfoSheet: $showProductInfoSheet, productId: product.id, displayName: product.displayName, description: product.description, price: product.displayPrice)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                productInfoProductId = product.id
                                showProductInfoSheet = true
                            }
                    }
                }
            }
        }
    }
}

