//
//  StoreErrorView.swift
//  StoreHelper
//
//  Created by Russell Archer on 21/06/2021.
//

import SwiftUI

/// Displays an error.
@available(iOS 15.0, macOS 12.0, *)
public struct StoreErrorView: View {
    @EnvironmentObject var storeHelper: StoreHelper
    
    public init() {}
    
    public var body: some View {
        Title2Font(scaleFactor: storeHelper.fontScaleFactor) { Text("Store Error")}
            .foregroundColor(.white)
            .padding()
            .frame(height: 40)
            .background(Color.red)
            .cornerRadius(25)
    }
}

@available(iOS 15.0, macOS 12.0, *)
struct StoreErrorView_Previews: PreviewProvider {
    static var previews: some View {
        StoreErrorView()
    }
}

