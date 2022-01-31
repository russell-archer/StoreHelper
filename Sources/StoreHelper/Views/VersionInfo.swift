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
                    Text("Build \(buildInfo)").font(.subheadline).padding(insets)
                }
            }
            .padding()
        }
        .onAppear {
            // Read the app name, version and release build number from Info.plist.
            // For the app name we initially look for an entry with the CFBundleDisplayName. This allows the developer to override the
            // Xcode project name (CFBundleName) with a specific name for the app. If this key is missing we default to CFBundleName,
            // which should always be present.
            if let name = Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") { appName = "\(name as? String ?? "StoreHelper")" }
            else if let name = Bundle.main.object(forInfoDictionaryKey: "CFBundleName") { appName = "\(name as? String ?? "StoreHelper")" }
            
            if let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") { versionInfo = "\(version as? String ?? "Unknown")" }
            if let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") { buildInfo = "\(build as? String ?? "Unknown")" }
        }
    }
}
