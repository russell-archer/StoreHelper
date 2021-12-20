//
//  BodyImage.swift
//  StoreHelper (iOS)
//
//  Created by Russell Archer on 20/12/2021.
//

import SwiftUI

extension Image {
    func bodyImage() -> some View {
        self
            .resizable()
            .cornerRadius(15)
            .aspectRatio(contentMode: .fit)
    }
    
    func bodyImageNotRounded() -> some View {
        self
            .resizable()
            .aspectRatio(contentMode: .fit)
    }
}
