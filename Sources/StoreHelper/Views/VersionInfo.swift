//
//  VersionInfo.swift
//  StoreHelper
//
//  Created by Russell Archer on 18/11/2021.
//

import SwiftUI

public struct VersionInfo: View {
    @State private var versionInfo = ""
    @State private var buildInfo = ""
    @State private var useAppStoreIcon = false
    
    let insets = EdgeInsets(top: 0, leading: 2, bottom: 1, trailing: 1)
    
    public init() {}
    
    public var body: some View {
        VStack {
            Spacer()
            
            #if os(iOS)
            Divider()
            #endif
            
            HStack {
                if useAppStoreIcon { Image("AppStoreIcon").resizable().frame(width: 75, height: 75)}
                else { Image(packageResource: "store-helper-icon", ofType: "png").resizable().frame(width: 75, height: 75)}
                
                VStack {
                    Text("Version \(versionInfo)").font(.subheadline).padding(insets)
                    Text("Build number \(buildInfo)").font(.subheadline).padding(insets)
                }
            }
            .padding()
        }
        .onAppear {
            // Read the version and release build numbers from Info.plist. Also see if we have access to the host app's app store icon
            if let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") { versionInfo = "\(version as? String ?? "???")" }
            if let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") { buildInfo = "\(build as? String ?? "???")" }
            if Bundle.main.url(forResource: "AppStoreIcon", withExtension: "png") != nil { useAppStoreIcon = true }
        }
    }
}

