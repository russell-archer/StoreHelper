//
//  SheetBarView-ios.swift
//  StoreHelper
//
//  Created by Russell Archer on 01/02/2022.
//

import SwiftUI

#if os(iOS) || os(tvOS) || os(visionOS)
@available(iOS 15.0, tvOS 15.0, visionOS 1.0, *)
public struct SheetBarView: View {
    @State private var showXmark = false
    @Binding var showSheet: Bool
    private let title: String?
    private let sysImg: String?
    private let insetsTitle = EdgeInsets(top: 10, leading: 0, bottom: 0, trailing: 0)

    public init(showSheet: Binding<Bool>, title: String? = nil, sysImage: String? = nil) {
        self._showSheet = showSheet
        self.title = title
        self.sysImg = sysImage
    }
    
    public var body: some View {
        HStack {
            ZStack {
                if let img = sysImg { Label(title ?? "", systemImage: img).padding(insetsTitle)}
                else if let t = title { Text(t).padding(insetsTitle)}
                
                HStack {
                    Spacer()
                    #if os(tvOS)
                    Button {
                        withAnimation { showSheet.toggle() }
                    } label: {
                        Image(systemName: "xmark.circle")
                            .foregroundColor(.secondary)
                    }
                    #else
                    Image(systemName: "xmark.circle")
                        .foregroundColor(.secondary)
                        .padding(EdgeInsets(top: 10, leading: 10, bottom: 0, trailing: 10))
                        .xPlatformOnTapGesture { withAnimation { showSheet.toggle() }}
                    #endif
                }
            }
        }
        Divider()
        Spacer()
    }
}
#endif
