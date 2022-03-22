//
//  StoreErrorView.swift
//  StoreHelper
//
//  Created by Russell Archer on 21/06/2021.
//

import SwiftUI

/// Displays an error.
public struct StoreErrorView: View {
    @EnvironmentObject var storeHelper: StoreHelper
    
    public var body: some View {
        Title2Font(scaleFactor: storeHelper.fontScaleFactor) { Text("Store Error")}
            .foregroundColor(.white)
            .padding()
            .frame(height: 40)
            .background(Color.red)
            .cornerRadius(25)
    }
}

struct StoreErrorView_Previews: PreviewProvider {
    static var previews: some View {
        StoreErrorView()
    }
}

