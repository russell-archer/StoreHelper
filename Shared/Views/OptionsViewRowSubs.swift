//
//  OptionsViewRowSubs.swift
//  OptionsViewRowSubs
//
//  Created by Russell Archer on 10/08/2021.
//

import SwiftUI

struct OptionsViewRowSubs: View {
    
    @Binding var showManageSubscriptions: Bool
    var imageName: String
    var text: String
    
    var body: some View {
        
        HStack {
            Button(action: {
                guard !Utils.isSimulator() else {
                    StoreLog.event("You cannot manage subscriptions from the simulator. You must use the sandbox environment.")
                    return
                }
                
                showManageSubscriptions = true
            }) {
                
                Image(systemName: imageName)
                    .resizable()
                    .frame(width: 30, height: 30)
                    .imageScale(.large)
                    .foregroundColor(.white)
                    .padding(.trailing)
                
                Text(text)
                    .font(.title2)
                    .foregroundColor(.white)
            }
            
            Spacer()
        }
        .padding()
    }
}
