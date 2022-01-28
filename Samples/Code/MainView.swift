//
//  MainView.swift
//  StoreHelperDemo
//
//  Created by Russell Archer on 25/01/2022.
//

import SwiftUI

struct MainView: View {
    let largeFlowersId = "com.rarcher.nonconsumable.flowers-large"
    let smallFlowersId = "com.rarcher.nonconsumable.flowers-small"
    
    var body: some View {
        NavigationView {
            List {
                NavigationLink(destination: ContentView()) { Text("Product List").font(.largeTitle).padding()}
                NavigationLink(destination: ProductView(productId: largeFlowersId)) { Text("Large Flowers").font(.largeTitle).padding()}
                NavigationLink(destination: ProductView(productId: smallFlowersId)) { Text("Small Flowers").font(.largeTitle).padding()}
            }
        }
        #if os(iOS)
        .navigationViewStyle(.stack)
        .navigationBarTitle(Text("StoreHelperDemo"), displayMode: .large)
        #endif
    }
}
