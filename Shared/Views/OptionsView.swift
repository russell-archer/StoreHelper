//
//  OptionsView.swift
//  OptionsView
//
//  Created by Russell Archer on 22/07/2021.
//

import SwiftUI

enum OptionCommand { case requestRefund, resetConsumables, restorePurchases }

struct OptionsView: View {
    
    @EnvironmentObject var storeHelper: StoreHelper
    @State private var showManageSubscriptions = false
    
    var body: some View {
        VStack {
            OptionsViewRowSubs(showManageSubscriptions: $showManageSubscriptions, imageName: "rectangle.stack.fill.badge.person.crop", text: "Manage Subscriptions")
            OptionsViewRow(option: .requestRefund, imageName: "tray.and.arrow.down", text: "Request Refund")
            OptionsViewRow(option: .resetConsumables, imageName: "trash", text: "Reset Consumables")
            OptionsViewRow(option: .restorePurchases, imageName: "purchased", text: "Restore Purchases")

            Spacer()
        }
        .manageSubscriptionsSheet(isPresented: $showManageSubscriptions)  // *** NOTE THAT THIS DOESN'T WORK WITH XCODE STOREKIT TESTING. MUST USE SANDBOX ***
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(red: 32/255, green: 32/255, blue: 32/255))
        .edgesIgnoringSafeArea(.all)
    }
}

