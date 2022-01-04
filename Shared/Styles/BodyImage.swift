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
        #if os(macOS)
            .frame(maxWidth: 1000)
            .padding(EdgeInsets(top: 10, leading: 0, bottom: 20, trailing: 10))
        #endif
    }
    
    func bodyImageNotRounded() -> some View {
        self
            .resizable()
            .aspectRatio(contentMode: .fit)
    }
    
    #if os(macOS)
    func bodyImageConstrained(width: CGFloat? = nil, height: CGFloat? = nil) -> some View {
        self
            .resizable()
            .cornerRadius(15)
            .aspectRatio(contentMode: .fit)
            .frame(maxWidth: width ?? 1000, maxHeight: height ?? .infinity)
            .padding()
    }
    
    func bodyImageConstrainedNoPadding(width: CGFloat? = nil, height: CGFloat? = nil) -> some View {
        self
            .resizable()
            .cornerRadius(15)
            .aspectRatio(contentMode: .fit)
            .frame(maxWidth: width ?? 1000, maxHeight: height ?? .infinity)
    }
    #endif
}

