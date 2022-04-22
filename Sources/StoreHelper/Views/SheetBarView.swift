//
//  SheetBarView.swift
//  
//
//  Created by Russell Archer on 01/02/2022.
//

import SwiftUI

@available(tvOS 15.0, *)
public struct SheetBarView: View {
    @State private var showXmark = false
    @Binding var showSheet: Bool
    
    var title: String?
    var sysImg: String?
    
    #if os(iOS)
    private var insets = EdgeInsets(top: 10, leading: 10, bottom: 0, trailing: 10)
    private var insetsTitle = EdgeInsets(top: 10, leading: 0, bottom: 0, trailing: 0)
    #elseif os(macOS)
    private var insets = EdgeInsets(top: 13, leading: 20, bottom: 5, trailing: 0)
    private var insetsTitle = EdgeInsets(top: 13, leading: 0, bottom: 5, trailing: 0)
    #endif
    
    public init(showSheet: Binding<Bool>, title: String? = nil, sysImage: String? = nil) {
        self._showSheet = showSheet
        self.title = title
        self.sysImg = sysImage
    }
    
    public var body: some View {
        #if os(iOS)
        HStack {
            ZStack {
                if let img = sysImg { Label(title ?? "", systemImage: img).padding(insetsTitle)}
                else if let t = title { Text(t).padding(insetsTitle)}
                
                HStack {
                    Spacer()
                    Image(systemName: "xmark.circle")
                        .foregroundColor(.secondary)
                        .padding(insets)
                        .onTapGesture { withAnimation { showSheet.toggle() }}
                }
            }
        }
        Divider()
        Spacer()
        #elseif os(macOS)
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
                    .onTapGesture { withAnimation { showSheet.toggle() }}
                    Spacer()
                }
            }
        }
        Divider()
        #endif
    }
}
