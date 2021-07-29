//
//  HamburgerMenu.swift
//  HamburgerMenu
//
//  Created by Russell Archer on 22/07/2021.
//

import SwiftUI

struct HamburgerMenu: View {
    
    @Binding var showOptionsMenu: Bool
    
    var body: some View {
        
        Button(action: {
            withAnimation { showOptionsMenu.toggle() }
            
        }) {
            Image(systemName: "line.horizontal.3")
                .imageScale(.large)
                .foregroundColor(.primary)
        }
    }
}

struct HamburgerMenu_Previews: PreviewProvider {
    static var previews: some View {
        HamburgerMenu(showOptionsMenu: .constant(true))
    }
}
