//
//  PriceButtonText-macos.swift
//  StoreHelper
//
//  Created by Russell Archer on 26/11/2022.
//

import SwiftUI
import StoreKit

/// Displays text for the price of a consumable or non-consumable product.
@available(iOS 15.0, macOS 12.0, *)
public struct PriceButtonText: View {
    var price: String
    var disabled: Bool
    
    public var body: some View {
        Text(disabled ? "Disabled" : price)  // Don't use scaled fonts for the price at it can lead to truncation
            .font(.body)
            .foregroundColor(.white)
            .padding()
            .frame(height: 40)
            .fixedSize()
            .background(Color.blue)
            .cornerRadius(25)
    }
}
