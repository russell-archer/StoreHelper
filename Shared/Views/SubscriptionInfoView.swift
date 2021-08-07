//
//  SubscriptionInfoView.swift
//  SubscriptionInfoView
//
//  Created by Russell Archer on 07/08/2021.
//

import SwiftUI
import StoreKit

struct SubscriptionInfoView: View {
    
    @EnvironmentObject var storeHelper: StoreHelper
    @State var subscriptionInfoText = ""
    var subscriptionInfo: SubscriptionInfo
    
    var body: some View {
        
        let viewModel = SubscriptionInfoViewModel(storeHelper: storeHelper, subscriptionInfo: subscriptionInfo)
        
        HStack(alignment: .center) {
            Text(subscriptionInfoText)
                .font(.footnote)
                .foregroundColor(.blue)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
                .padding(1)
        }
        .onAppear {
            Task.init { subscriptionInfoText = await viewModel.info() }
        }
    }
}

