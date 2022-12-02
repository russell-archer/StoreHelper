//
//  SubscriptionView.swift
//  StoreHelperDemo
//
//  Created by Russell Archer on 26/03/2022.
//

import SwiftUI
import StoreHelper

@available(iOS 15.0, macOS 12.0, *)
struct SubscriptionView: View {
    @EnvironmentObject var storeHelper: StoreHelper
    @State private var productIds: [ProductId]?
    
    var body: some View {
        VStack {
            if let pids = productIds {
                ForEach(pids, id: \.self) { pid in
                    SubscriptionRow(productId: pid)
                    Divider()
                }
                
                Spacer()
            } else {
                Text("You don't have any subscription products")
                    .font(.title)
                    .foregroundColor(.red)
            }
        }
        .padding()
        .onAppear { productIds = storeHelper.subscriptionProductIds }
    }
}

@available(iOS 15.0, macOS 12.0, *)
struct SubscriptionRow: View {
    @EnvironmentObject var storeHelper: StoreHelper
    @State private var isSubscribed = false
    @State private var detailedSubscriptionInfo: ExtendedSubscriptionInfo?
    var productId: ProductId
    
    var body: some View {
        VStack {
            HStack {
                Text("You are \(isSubscribed ? "" : "not") subscribed to \(productId)")
                    .foregroundColor(isSubscribed ? .green : .red)
                    .multilineTextAlignment(.center)
                    .padding()
            }
        }
        .task {
            isSubscribed = await subscribed(to: productId)
            if isSubscribed {
                if let subscriptionInfo = await getSubscriptionInfo() {
                    detailedSubscriptionInfo = await getDetailedSubscriptionInfo(for: subscriptionInfo)
                }
            }
        }
    }
    
    private func subscribed(to productId: ProductId) async -> Bool {
        let currentlySubscribed = try? await storeHelper.isSubscribed(productId: productId)
        return currentlySubscribed ?? false
    }
    
    private func getSubscriptionInfo() async -> SubscriptionInfo? {
        var subInfo: SubscriptionInfo?
        
        // Get info on all subscription groups (this demo only has one group called "VIP")
        let subscriptionGroupInfo = await storeHelper.subscriptionHelper.groupSubscriptionInfo()
        if let vipGroup = subscriptionGroupInfo?.first, let product = vipGroup.product {
            // Get subscription info for the subscribed product
            subInfo = storeHelper.subscriptionHelper.subscriptionInformation(for: product, in: subscriptionGroupInfo)
        }
        
        return subInfo
    }
    
    private func getDetailedSubscriptionInfo(for subInfo: SubscriptionInfo) async -> ExtendedSubscriptionInfo? {
        let viewModel = SubscriptionInfoViewModel(storeHelper: storeHelper, subscriptionInfo: subInfo)
        return await viewModel.extendedSubscriptionInfo()
    }
}
