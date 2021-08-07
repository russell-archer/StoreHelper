//
//  OptionsViewRow.swift
//  OptionsViewRow
//
//  Created by Russell Archer on 23/07/2021.
//

import SwiftUI

struct OptionsViewRow: View {
    
    @EnvironmentObject var storeHelper: StoreHelper
    
    var option: OptionCommand
    var imageName: String
    var text: String
    
    var body: some View {
        
        let optionsViewModel = OptionsViewModel(storeHelper: storeHelper)
        
        HStack {
            Button(action: {
                
                optionsViewModel.command(cmd: option)
                
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

struct OptionsViewRow_Previews: PreviewProvider {
    static var previews: some View {
        OptionsViewRow(option: .resetConsumables, imageName: "trash", text: "test")
            .preferredColorScheme(.dark)
    }
}
