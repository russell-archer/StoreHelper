//
//  ProductPurchaseInfo.swift
//  StoreHelper (iOS)
//
//  Created by Russell Archer on 16/01/2022.
//

import SwiftUI
import StoreKit

struct ProductPurchaseInfo: View {
    @EnvironmentObject var storeHelper: StoreHelper
    @Binding var productInfoProductId: ProductId?
    @State private var product: Product?
    
    var body: some View {
        VStack {
            HStack { Spacer() }
            ScrollView {
                VStack {
                        if let p = product {
                            Text(p.displayName).font(.largeTitle).foregroundColor(.blue)
                            Image(p.id)
                                .resizable()
                                .frame(maxWidth: 200, maxHeight: 200)
                                .aspectRatio(contentMode: .fit)
                                .cornerRadius(25)
                        }
                        
                        Text("This is a product information sheet.").font(.title2).padding().multilineTextAlignment(.center)
                        Text("Add text explaining your product here.").font(.title3).padding().multilineTextAlignment(.center)
                }
                .padding(.bottom)
            }
        }
        .onAppear {
            if let pid = productInfoProductId {
                product = storeHelper.product(from: pid)
            }
        }
    }
}
