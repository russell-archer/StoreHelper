//
//  ContentView.swift
//  Shared
//
//  Created by Russell Archer on 16/06/2021.
//

import SwiftUI

/// The main app View.
struct ContentView: View {
    
    @EnvironmentObject var storeHelper: StoreHelper
    @State var showOptionsMenu = false
    
    var body: some View {
        
        NavigationView {
            GeometryReader { geometry in
                ZStack(alignment: .topLeading) {
                    
                    ProductListView(showOptionsMenu: $showOptionsMenu)
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .offset(x: showOptionsMenu ? geometry.size.width-75 : 0)
                        .disabled(showOptionsMenu ? true : false)
                    
                    if showOptionsMenu {
                        OptionsView()
                            .frame(width: geometry.size.width-75)
                            .offset(y: 35)
                            .transition(.move(edge: .leading))
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .navigationBarTitle("Purchase", displayMode: .inline)
                .navigationBarItems(leading: HamburgerMenu(showOptionsMenu: $showOptionsMenu))
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        @StateObject var storeHelper = StoreHelper()
        
        return NavigationView {
            List {
                Section(header: Text("Products")) {
                    ProductView(
                        productId: "com.rarcher.nonconsumable.flowers-large",
                        displayName: "Large Flowers",
                        price: "4.99")
                    
                    ProductView(
                        productId: "com.rarcher.nonconsumable.flowers-small",
                        displayName: "Large Flowers",
                        price: "4.99")
                    
                    ProductView(
                        productId: "com.rarcher.nonconsumable.roses-large",
                        displayName: "Large Flowers",
                        price: "4.99")
                }
                
                Section(header: Text("VIP Services")) {
                    ProductView(
                        productId: "com.rarcher.consumable.plant-installation",
                        displayName: "Plant Installation",
                        price: "4.99")
                }
                
                Section(header: Text("Subscriptions")) {
                    ProductView(
                        productId: "com.rarcher.subscription.vip.gold",
                        displayName: "Gold. Weekly Home Visits",
                        price: "4.99")
                    
                    ProductView(
                        productId: "com.rarcher.subscription.vip.silver",
                        displayName: "Silver. Visits every 2 weeks",
                        price: "4.99")
                    
                    ProductView(
                        productId: "com.rarcher.subscription.vip.bronze",
                        displayName: "Bronze. Monthly home visits",
                        price: "4.99")
                }
            }
            .listStyle(.insetGrouped)
            .environmentObject(storeHelper)
            .navigationBarTitle("Purchase", displayMode: .inline)
            .navigationBarItems(leading: HamburgerMenu(showOptionsMenu: .constant(false)))
        }
    }
}


