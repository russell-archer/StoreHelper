//
//  BadgeView.swift
//  StoreHelper
//
//  Created by Russell Archer on 21/06/2021.
//

import SwiftUI

struct BadgeView: View {
    
    var purchaseState: StoreHelper.PurchaseState
    
    var body: some View {
        
        if let options = badgeOptions() {
            
            Image(systemName: options.badgeName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 25, height: 25)
                .foregroundColor(options.fgColor)
        }
    }
    
    func badgeOptions() -> (badgeName: String, fgColor: Color)? {
        switch purchaseState {
            case .notStarted:         return nil
            case .inProgress:         return nil
            case .complete:           return (badgeName: "checkmark", Color.green)
            case .pending:            return (badgeName: "hourglass", Color.orange)
            case .cancelled:          return (badgeName: "person.crop.circle.fill.badge.xmark", Color.blue)
            case .failed:             return (badgeName: "hand.raised.slash", Color.red)
            case .failedVerification: return (badgeName: "hand.thumbsdown.fill", Color.red)
            case .unknown:            return nil
        }
    }
}

struct PurchasedView_Previews: PreviewProvider {
    static var previews: some View {
        BadgeView(purchaseState: .complete)
    }
}