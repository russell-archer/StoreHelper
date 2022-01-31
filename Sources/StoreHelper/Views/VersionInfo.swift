//
//  VersionInfo.swift
//  StoreHelper
//
//  Created by Russell Archer on 18/11/2021.
//

import SwiftUI

public struct VersionInfo: View {
    @State private var appName = ""
    @State private var versionInfo = ""
    @State private var buildInfo = ""
    
    let insets = EdgeInsets(top: 0, leading: 2, bottom: 1, trailing: 1)
    
    public init() {}
    
    public var body: some View {
        VStack {
            Spacer()
            
            #if os(iOS)
            Divider()
            #endif
            
            HStack {
                // StoreHelper will look for an image named "AppStoreIcon" in your asset catalog
                Image("AppStoreIcon").resizable().frame(width: 75, height: 75)
                
                VStack {
                    Text("\(appName) version \(versionInfo)").font(.subheadline).padding(insets)
                    Text("Build number \(buildInfo)").font(.subheadline).padding(insets)
                }
            }
            .padding()
        }
        .onAppear {
            // Read the app name, version and release build number from Info.plist
            if let name = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") { appName = "\(name as? String ?? "StoreHelper")" }
            if let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") { versionInfo = "\(version as? String ?? "Unknown")" }
            if let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") { buildInfo = "\(build as? String ?? "Unknown")" }
        }
    }
}
