//
//  Products-macos.swift
//  StoreHelper
//
//  Created by Russell Archer on 10/09/2021.
//
// View hierachy:
// Non-Consumables: [Products].[ProductListView].[ProductListViewRow]......[ProductView]......[if purchased].[PurchaseInfoView].....[PurchaseInfoSheet]
// Consumables:     [Products].[ProductListView].[ProductListViewRow]......[ConsumableView]...[if purchased].[PurchaseInfoView].....[PurchaseInfoSheet]
// Subscriptions:   [Products].[ProductListView].[SubscriptionListViewRow].[SubscriptionView].[if purchased].[SubscriptionInfoView].[SubscriptionInfoSheet]

import SwiftUI
import StoreKit

#if os(macOS)
/// Initializes the `Products` view, which is responsible for displaying a list of available products, along with purchase buttons and a button
/// to enable users to manually restore previous purchases.
///
/// For notes on signing promotional subscription offers see the section on **"Introductory and Promotional Subscription Offers"** in the
/// [StoreHelper Guide](https://github.com/russell-archer/StoreHelper/blob/main/Documentation/guide.md).
///
@available(macOS 12.0, *)
public struct Products: View {
    @EnvironmentObject var storeHelper: StoreHelper
    @State private var showManageSubscriptions = false
    @State private var showRefundSheet = false
    @State private var refundRequestTransactionId: UInt64 = UInt64.min
    @State private var canMakePayments: Bool = false
    @State private var purchasesRestored: Bool = false
    @State private var showRefundAlert: Bool = false
    @State private var refundAlertText: String = ""
    @State private var showManagePurchases = false
    
    /// An app must sign any request to purchase a subscription using a promotional offer. This is an Apple-mandated requirement.
    /// StoreHelper can't do this locally because it needs access to IAP keys defined by the host app in App Store Connect.
    /// Also, neither `StoreKit1` or `StoreKit2` provide a secure local mechanism for signing promotional offers.
    /// StoreHelper passes-off the signature request to the app using the `signPromotionalOffer` closure. This closure
    /// is passed down the view hirearch so it can be called just before attempting a purchase with a promotional offer.
    /// The closure receives a productId and the offerId, returns the signature.
    private var signPromotionalOffer: ((ProductId, String) async -> Product.PurchaseOption?)?
    
    /// A closure that receives a `ProductId` when the user taps on a product's image or information button for additional information
    /// about that product. The closure should trigger the presentation of a sheet that shows information to the user on why they
    /// should purchase the product.
    private var productInfoCompletion: ((ProductId) -> Void)
    
    /// Initializes the `Products` view, which is responsible for displaying a list of available products, along with purchase buttons and a button
    /// to enable users to manually restore previous purchases.
    ///
    /// For notes on signing promotional subscription offers see the section on **"Introductory and Promotional Subscription Offers"** in the
    /// [StoreHelper Guide](https://github.com/russell-archer/StoreHelper/blob/main/Documentation/guide.md).
    ///
    /// - Parameters:
    ///   - signPromotionalOffer: A closure that receives a `ProductId` and promotional offer id, and returns a signed promotional offer in
    ///   the form of a `Product.PurchaseOption`.
    ///   - productInfoCompletion: A closure that receives a `ProductId` when the user taps on a product's image or information button for
    ///   additional information about that product. The closure should trigger the presentation of a sheet that shows information to the user
    ///   on why they should purchase the product.
    public init(signPromotionalOffer: ((ProductId, String) async -> Product.PurchaseOption?)? = nil, productInfoCompletion: @escaping ((ProductId) -> Void)) {
        self.signPromotionalOffer = signPromotionalOffer
        self.productInfoCompletion = productInfoCompletion
    }
    
    @ViewBuilder public var body: some View {
        ScrollView {
            VStack {
                ProductListView(signPromotionalOffer: signPromotionalOffer, productInfoCompletion: productInfoCompletion)
                TermsOfServiceAndPrivacyPolicyView()
                
                if Configuration.restorePurchasesButtonText.stringValue(storeHelper: storeHelper) != nil {
                    DisclosureGroup(isExpanded: $showManagePurchases, content: {
                        PurchaseManagement() },
                                    label: { Label("Manage Purchases", systemImage: "creditcard.circle")})
                    .onTapGesture { withAnimation { showManagePurchases.toggle()}}
                    .padding(EdgeInsets(top: 0, leading: 20, bottom: 5, trailing: 20))
                }
                
                if !canMakePayments {
                    Spacer()
                    SubHeadlineFont(scaleFactor: storeHelper.fontScaleFactor) { Text("Purchases are not permitted on your device.")}.foregroundColor(.secondary)
                }
            }
            .alert(refundAlertText, isPresented: $showRefundAlert) { Button("OK") { showRefundAlert.toggle()}}
            .onAppear { canMakePayments = AppStore.canMakePayments }
            
            VersionInfo()
        }
        .refreshable { storeHelper.refreshProductsFromAppStore() }
    }
}
#endif

