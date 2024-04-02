//
//  TapGesture.swift
//  StoreHelper
//
//  Created by hengyu on 2024/3/30.
//

import SwiftUI

extension View {

    @ViewBuilder func xPlatformOnTapGesture(perform: @escaping () -> Void) -> some View {
        #if os(tvOS)
        if #available(tvOS 16.0, *) {
            onTapGesture(perform: perform)
        } else {
            onLongPressGesture(minimumDuration: 0.2, perform: perform)
        }
        #else
        onTapGesture(perform: perform)
        #endif
    }
}
