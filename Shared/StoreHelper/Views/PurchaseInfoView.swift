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
                #if os(iOS)
                .font(.footnote)
                #endif
                .foregroundColor(.blue)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
                #if os(iOS)
                .padding(1)
                #elseif os(macOS)
                .padding(EdgeInsets(top: 0, leading: 5, bottom: 0, trailing: 5))
                #endif
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
