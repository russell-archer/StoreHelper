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
        NavigationView {
            ScrollView {
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
                    
            Text("Manually restoring previous purchases is not normally necessary. Tap \"Restore Purchases\" only if this app does not correctly identify your previous purchases. You will be prompted to authenticate with the App Store. Note that this app does not have access to credentials used to sign-in to the App Store.")
                .font(.caption2)
                .multilineTextAlignment(.center)
                .padding(EdgeInsets(top: 0, leading: 10, bottom: 10, trailing: 10))
                .foregroundColor(.secondary)
                    if !canMakePayments {
                        Spacer()
                        Text("Purchases are not permitted on your device.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .navigationBarTitle("Purchases", displayMode: .inline)
                #if os(iOS)
                .toolbar { HamburgerMenu(showManageSubscriptions: $showManageSubscriptions) }
                .manageSubscriptionsSheet(isPresented: $showManageSubscriptions)
                #endif
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
                            default: Text("This is the in-app purchase info page for the product \"\(productInfoProductId ?? "unknown product")\". You should add a view that provides an overview of the in-app purchase. See `Purchases.swift`")
                        }
                    }
                }
                .onAppear { canMakePayments = AppStore.canMakePayments }
                .onChange(of: productInfoProductId) { _ in showProductInfoSheet = true }
                VersionInfo()
            }
            .padding()
        }
    }
}

struct Purchases_Previews: PreviewProvider {
    static var previews: some View {
        Purchases()
    }
}
