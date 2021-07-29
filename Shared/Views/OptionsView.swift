//
//  OptionsView.swift
//  OptionsView
//
//  Created by Russell Archer on 22/07/2021.
//

import SwiftUI

struct OptionsView: View {
    
    var body: some View {
        VStack {
            OptionsViewRow(imageName: "trash",          text: "Reset Consumables")
            OptionsViewRow(imageName: "cart.circle",    text: "Request Refund")
            OptionsViewRow(imageName: "purchased",      text: "Restore Purchases")
            
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
