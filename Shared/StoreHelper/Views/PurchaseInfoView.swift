//
//  PurchaseInfoView.swift
//  PurchaseInfoView
//
//  Created by Russell Archer on 19/07/2021.
//

import SwiftUI
import StoreKit

/// Displays information on a consumable or non-consumable purchase.
struct PurchaseInfoView: View {
    
    @EnvironmentObject var storeHelper: StoreHelper
    @State var purchaseInfoText = ""
    var productId: ProductId
    
    var body: some View {
        
        let viewModel = PurchaseInfoViewModel(storeHelper: storeHelper, productId: productId)
        
        HStack(alignment: .center) {
            Text(purchaseInfoText)
                .font(.footnote)
                .foregroundColor(.blue)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
                .padding(1)
        }
        .onAppear {
            Task.init { purchaseInfoText = await viewModel.info(for: productId) }
        }
    }
}

struct PurchaseInfoView_Previews: PreviewProvider {
    static var previews: some View {
        
        @StateObject var storeHelper = StoreHelper()
        return PurchaseInfoView(productId: "com.rarcher.nonconsumable.chocolates-small")
            .environmentObject(storeHelper)
    }
}
