//
//  Purchases.swift
//  StoreHelper (iOS)
//
//  Created by Russell Archer on 20/12/2021.
//

import SwiftUI
import StoreKit

struct Purchases: View {
    @State private var showManageSubscriptions = false
    @State private var showProductInfoSheet = false
    @State private var productInfoProductId: ProductId? = nil
    @State private var canMakePayments: Bool = false
    @State private var purchasesRestored: Bool = false
    
    @ViewBuilder var body: some View {
        
        VStack {
            ProductListView(productInfoProductId: $productInfoProductId, showProductInfoSheet: $showProductInfoSheet)
            
            Button(purchasesRestored ? "Purchases Restored" : "Restore Purchases") {
                Task.init {
                    try? await AppStore.sync()
                    purchasesRestored = true
                }
            }
            .buttonStyle(.borderedProminent).padding()
            .disabled(purchasesRestored)
            
            if !canMakePayments {
                Spacer()
                Text("Purchases are not permitted on your device.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .navigationBarTitle("Purchases", displayMode: .inline)
        //        .toolbar { HamburgerMenu(showManageSubscriptions: $showManageSubscriptions) }  // TODO. Disabled because of Mac issues
        //        .manageSubscriptionsSheet(isPresented: $showManageSubscriptions)  // TODO. Disabled because of Mac issues
        .sheet(isPresented: $showProductInfoSheet) {
            VStack {
                HStack {
                    Spacer()
                    Button(action: { showProductInfoSheet = false }) {
                        Image(systemName: "xmark.circle")
                            .foregroundColor(.secondary)
                    }
                    .padding(EdgeInsets(top: 10, leading: 10, bottom: 0, trailing: 10))
                }
                Spacer()
                
                switch productInfoProductId {
                        // TODO: Add views here that show product info
                    default: Text("Unknown product. You should add views that provide an overview of the in-app purchase. See `Purchases.swift`")
                }
            }
        }
        .onAppear { canMakePayments = AppStore.canMakePayments }
        .onChange(of: productInfoProductId) { _ in showProductInfoSheet = true }
        
        VersionInfo()
    }
}

struct Purchases_Previews: PreviewProvider {
    static var previews: some View {
        Purchases()
    }
}
