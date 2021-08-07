//
//  OptionsViewModel.swift
//  OptionsViewModel
//
//  Created by Russell Archer on 31/07/2021.
//

import SwiftUI

struct OptionsViewModel {
    
    @ObservedObject var storeHelper: StoreHelper
    
    func command(cmd: OptionCommand, id: ProductId? = nil) {
        switch cmd {
                
            case .resetConsumables: resetConsumables()
            case .requestRefund: requestRefund()
            case .restorePurchases: restorePurchases()
        }
    }
    
    func resetConsumables() {
        print("Resetting consumables count....")
    }
    
    func requestRefund() {
        print("Requesting refund....")
    }
    
    func restorePurchases() {
        print("Restoring purchases....")
    }
}
