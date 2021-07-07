//
//  StoreHelperApp.swift
//  Shared
//
//  Created by Russell Archer on 16/06/2021.
//

import SwiftUI

@main
struct StoreHelperApp: App {
    
    // Create the StoreHelper object that will be shared throughout the View hierarchy...
    @StateObject var storeHelper = StoreHelper()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(storeHelper)  // ...and add it to the ContentView hierarchy
        }
    }
}
