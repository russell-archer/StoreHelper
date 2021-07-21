//
//  PurchaseInfoView.swift
//  PurchaseInfoView
//
//  Created by Russell Archer on 19/07/2021.
//

import SwiftUI
import StoreKit

/// Displays purchase or subscription information.
struct PurchaseInfoView: View {
    
    @ObservedObject var storeHelper: StoreHelper
    @State var purchaseInfoText = ""
    var productId: ProductId
    
    var body: some View {
        
        let viewModel = PurchaseInfoViewModel(storeHelper: storeHelper, productId: productId)
        
        VStack(alignment: .leading) {
            Text(purchaseInfoText)
                .font(.footnote)
                .foregroundColor(.blue)
                .padding(.leading)
        }
        .onAppear {
            Task.init { purchaseInfoText = await viewModel.info(for: productId) }
        }
    }
}

struct PurchaseInfoView_Previews: PreviewProvider {
    static var previews: some View {
        
        @StateObject var storeHelper = StoreHelper()
        return PurchaseInfoView(storeHelper: storeHelper, productId: "com.rarcher.nonconsumable.chocolates-small")
            .environmentObject(storeHelper)
    }
}
