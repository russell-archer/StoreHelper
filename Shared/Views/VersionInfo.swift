//
//  VersionInfo.swift
//
//  Created by Russell Archer on 18/11/2021.
//

import SwiftUI

struct VersionInfo: View {
    @State private var versionInfo = ""
    @State private var buildInfo = ""
    
    var body: some View {
        VStack {
            Spacer()
            Divider()
            
            HStack {
                Image("AppStoreIcon").bodyImage().frame(width: 75)
                VStack {
                    Text(versionInfo).font(.subheadline).foregroundColor(Color("GroupBoxText")).padding(1)
                    Text(buildInfo).font(.subheadline).foregroundColor(Color("GroupBoxText")).padding(1)
                }.padding()
            }
            .padding()
        }
        .onAppear {

            // Read the version and release build numbers from Info.plist
            if let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") {
                versionInfo = "Version \(version as? String ?? "???")"
            }
            
            if let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") {
                buildInfo = "Build number \(build as? String ?? "???")"
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
