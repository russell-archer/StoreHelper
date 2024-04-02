//
//  SheetBarView-macos.swift
//  StoreHelper
//
//  Created by Russell Archer on 01/02/2022.
//

import SwiftUI

#if os(macOS)
@available(macOS 12.0, *)
public struct SheetBarView: View {
    @State private var showXmark = false
    @Binding var showSheet: Bool
    var title: String?
    var sysImg: String?
    
    private var insets = EdgeInsets(top: 13, leading: 20, bottom: 5, trailing: 0)
    private var insetsTitle = EdgeInsets(top: 13, leading: 0, bottom: 5, trailing: 0)
    
    public init(showSheet: Binding<Bool>, title: String? = nil, sysImage: String? = nil) {
        self._showSheet = showSheet
        self.title = title
        self.sysImg = sysImage
    }
    
    public var body: some View {
        HStack {
            ZStack {
                if let img = sysImg { Label(title ?? "", systemImage: img).padding(insetsTitle).font(.title)}
                else if let t = title { Text(t).font(.title).padding(insetsTitle)}
                
                HStack {
                    ZStack {
                        Image(systemName: "circle.fill")
                            .resizable()
                            .frame(width: 13, height: 13)
                            .foregroundColor(.red)
                            .padding(insets)
                            .onHover { action in showXmark = action }
                        
                        if showXmark { Image(systemName: "xmark")
                                .resizable()
                                .frame(width: 5, height: 5)
                                .foregroundColor(.black)
                            .padding(insets)}
                    }
                    .xPlatformOnTapGesture { withAnimation { showSheet.toggle() }}
                    Spacer()
                }
            }
        }
        Divider()
    }
}
#endif
