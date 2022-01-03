//
//  SubscriptionListViewRow.swift
//  SubscriptionListViewRow
//
//  Created by Russell Archer on 07/08/2021.
//

import SwiftUI
import StoreKit
import OrderedCollections

struct SubscriptionListViewRow: View {
    
    @EnvironmentObject var storeHelper: StoreHelper
    @State private var subscriptionGroups: OrderedSet<String>?
    @State private var subscriptionInfo: OrderedSet<SubscriptionInfo>?
    @Binding var productInfoProductId: ProductId?
    var products: [Product]
    var headerText: String
    
    var body: some View {
        Section(header: Text(headerText)) {
            // For each product in the group, display as a row using SubscriptionView().
            // If the product is the highest subscription level then pass SubscriptionInfo to SubscriptionView().
            ForEach(products, id: \.id) { product in
                SubscriptionView(productId: product.id,
                                 displayName: product.displayName,
                                 description: product.description,
                                 price: product.displayPrice,
                                 subscriptionInfo: subscriptionInformation(for: product))
                    .contentShape(Rectangle())
                    .onTapGesture { productInfoProductId = product.id }
            }
        }
        .onAppear { getGroupSubscriptionInfo() }
        .onChange(of: storeHelper.purchasedProducts) { _ in getGroupSubscriptionInfo() }
    }
    
    /// Gets all the subscription groups from the list of subscription products.
    /// For each group, gets the highest subscription level product.
    func getGroupSubscriptionInfo() {
        subscriptionGroups = storeHelper.subscriptionHelper.groups()
        if let groups = subscriptionGroups {
            subscriptionInfo = OrderedSet<SubscriptionInfo>()
            if subscriptionInfo == nil { return }
            Task.init {
                for group in groups {
                    if let hslp = await storeHelper.subscriptionInfo(for: group) { subscriptionInfo!.append(hslp) }
                }
            }
        }
    }
    
    /// Gets `SubscriptionInfo` for a product.
    /// - Parameter product: The product.
    /// - Returns: Returns `SubscriptionInfo` for the product if it is the highest service level product
    /// in the group the user is subscribed to. If the user is not subscribed to the product, or it's
    /// not the highest service level product in the group then nil is returned.
    func subscriptionInformation(for product: Product) -> SubscriptionInfo? {
        if let subsInfo = subscriptionInfo {
            for subInfo in subsInfo {
                if let p = subInfo.product, p.id == product.id { return subInfo }
            }
        }
        
        return nil
    }
}
