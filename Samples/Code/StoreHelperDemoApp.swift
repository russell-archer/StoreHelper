//
//  StoreHelperDemoApp.swift
//  Shared
//
//  Created by Russell Archer on 24/01/2022.
//

import SwiftUI
import StoreHelper

@main
struct StoreHelperDemoApp: App {
    @StateObject var storeHelper = StoreHelper()
    
    #if os(macOS)
    let minScreenSize = CGSize(width: 600, height: 600)
    let defaultScreenSize = CGSize(width: 700, height: 700)
    #endif
    
    var body: some Scene {
        WindowGroup {
            MainView().environmentObject(storeHelper)
                #if os(macOS)
                .frame(minWidth: minScreenSize.width, idealWidth: defaultScreenSize.width, minHeight: minScreenSize.height, idealHeight: defaultScreenSize.height)
                .font(.title2)  // Default font
                #endif
        }
    }
}
