//
//  BodyImage.swift
//  StoreHelper
//
//  Created by Russell Archer on 20/12/2021.
//

import SwiftUI

#if os(macOS)
@available(macOS 12.0, *)
public extension Image {
    func bodyImage() -> some View {
        self
            .resizable()
            .cornerRadius(15)
            .aspectRatio(contentMode: .fit)
            .frame(maxWidth: 1200)
            .padding(EdgeInsets(top: 10, leading: 0, bottom: 20, trailing: 10))
    }
    
    func bodyImageConstrained(width: CGFloat? = nil, height: CGFloat? = nil) -> some View {
        self
            .resizable()
            .cornerRadius(15)
            .aspectRatio(contentMode: .fit)
            .frame(maxWidth: width ?? 1200, maxHeight: height ?? .infinity)
            .padding()
    }
    
    func bodyImageConstrainedNoPadding(width: CGFloat? = nil, height: CGFloat? = nil) -> some View {
        self
            .resizable()
            .cornerRadius(15)
            .aspectRatio(contentMode: .fit)
            .frame(maxWidth: width ?? 1200, maxHeight: height ?? .infinity)
    }
    
    func bodyImageConstrainedNoPaddingNoCorner(width: CGFloat? = nil, height: CGFloat? = nil) -> some View {
        self
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(maxWidth: width ?? 1200, maxHeight: height ?? .infinity)
    }
}
#endif
