//
//  StoreHelperApp.swift
//  Shared
//
//  Created by Russell Archer on 16/06/2021.
//

import SwiftUI

@main
struct StoreHelperApp: App {
    
    // Create the StoreHelper object that will be shared throughout the View hierarchy
    @StateObject var storeHelper = StoreHelper()
    
    #if os(macOS)
    let minScreenSize = CGSize(width: 600, height: 600)
    let defaultScreenSize = CGSize(width: 700, height: 700)
    #endif
    
    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(storeHelper)
                #if os(macOS)
                .frame(minWidth: minScreenSize.width, idealWidth: defaultScreenSize.width, minHeight: minScreenSize.height, idealHeight: defaultScreenSize.height)
                .font(.title2)  // Default font
                #endif
        }
    }
}
