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
    
    var body: some Scene {
        WindowGroup {
            MainView().environmentObject(storeHelper)
                #if os(macOS)
                .frame(minWidth: 700, idealWidth: 700, minHeight: 700, idealHeight: 700)
                .font(.title2)
                #endif
        }
    }
}
