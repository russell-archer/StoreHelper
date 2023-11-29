//
//  Images.swift
//  StoreHelper
//
//  Created by hengyu on 2023/11/29.
//

import SwiftUI

public extension Image {
    // Read images from the Sources/Resources folder
    init(packageResource name: String, ofType type: String) {
        #if canImport(UIKit)
        guard let path = Bundle.module.path(forResource: name, ofType: type),
              let image = UIImage(contentsOfFile: path) else {
                  self.init(name)
                  return
              }

        self.init(uiImage: image)
        #elseif canImport(AppKit)
        guard let path = Bundle.module.path(forResource: name, ofType: type),
              let image = NSImage(contentsOfFile: path) else {
                  self.init(name)
                  return
              }
        self.init(nsImage: image)
        #else
        self.init(name)
        #endif
    }

    func bodyImageNotRounded() -> some View {
        resizable()
            .aspectRatio(contentMode: .fit)
    }
}
