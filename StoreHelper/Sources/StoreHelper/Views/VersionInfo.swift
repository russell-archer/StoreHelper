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
    
    public var body: some View {
        VStack {
            Spacer()
            
            #if os(iOS)
            Divider()
            #endif
            
            HStack {
                #if os(iOS)
                Image("ios-icon").bodyImage().frame(width: 75)
                VStack {
                    Text("Version \(versionInfo)").font(.subheadline).foregroundColor(Color("GroupBoxText")).padding(1)
                    Text("Build \(buildInfo)").font(.subheadline).foregroundColor(Color("GroupBoxText")).padding(1)
                }
                #elseif os(macOS)
                Image("mac-icon").bodyImageConstrainedNoPadding(width: 64, height: 64)
                VStack {
                    Text("Version \(versionInfo)")
                        .font(.subheadline)
                        .foregroundColor(Color("GroupBoxText"))
                        .padding(EdgeInsets(top: 0, leading: 2, bottom: 1, trailing: 1))
                    Text("Build number \(buildInfo)")
                        .font(.subheadline)
                        .foregroundColor(Color("GroupBoxText"))
                        .padding(EdgeInsets(top: 0, leading: 2, bottom: 1, trailing: 1))
                }
                #endif
            }
            .padding()
        }
        .onAppear {

            // Read the version and release build numbers from Info.plist
            if let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") {
                versionInfo = "\(version as? String ?? "???")"
            }
            
            if let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") {
                buildInfo = "\(build as? String ?? "???")"
            }
        }
    }
}

struct VersionInfo_Previews: PreviewProvider {
    static var previews: some View {
        VersionInfo()
        
        VersionInfo()
            .preferredColorScheme(.dark)

    }
}
