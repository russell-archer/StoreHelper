//
//  BodyImage.swift
//  StoreHelper
//
//  Created by Russell Archer on 20/12/2021.
//

import SwiftUI

#if os(iOS)
@available(iOS 15.0, *)
public extension Image {
    func bodyImage() -> some View {
        self
            .resizable()
            .cornerRadius(15)
            .aspectRatio(contentMode: .fit)
    }
}
#endif
