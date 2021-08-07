//
//  OptionsView.swift
//  OptionsView
//
//  Created by Russell Archer on 22/07/2021.
//

import SwiftUI

enum OptionCommand { case resetConsumables, requestRefund, restorePurchases }

struct OptionsView: View {
    
    @EnvironmentObject var storeHelper: StoreHelper
    
    var body: some View {
        VStack {
            
            OptionsViewRow(option: .resetConsumables, imageName: "trash", text: "Reset Consumables")
            OptionsViewRow(option: .requestRefund, imageName: "cart.circle", text: "Request Refund")
            OptionsViewRow(option: .restorePurchases, imageName: "purchased", text: "Restore Purchases")

            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(red: 32/255, green: 32/255, blue: 32/255))
        .edgesIgnoringSafeArea(.all)
    }
}

struct OptionsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            OptionsView()
                .navigationTitle("Purchase")
                .navigationBarTitleDisplayMode(.inline)
        }
    }
}
