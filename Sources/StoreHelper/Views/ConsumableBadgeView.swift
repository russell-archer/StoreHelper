//
//  ConsumableBadgeView.swift
//  StoreHelper
//
//  Created by Russell Archer on 21/07/2021.
//

import SwiftUI

/// Shows a count badge with the number of times a consumable has been purchased.
public struct ConsumableBadgeView: View {
    
    @Binding var count : Int
    
    public var body: some View {
        
        ZStack {
            Capsule()
                .fill(Color.red)
                .frame(width: 30, height: 30, alignment: .topTrailing)
                .position(CGPoint(x: 70, y: 10))
            
            Text(String(count)).foregroundColor(.white)
                .font(Font.system(size: 20).bold()).position(CGPoint(x: 70, y: 10))
        }
    }
}


