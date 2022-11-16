//
//  SwiftUIView.swift
//  
//
//  Created by Russell Archer on 16/11/2022.
//

import SwiftUI

/// Displays links for terms of service and privacy policy
@available(iOS 15.0, macOS 12.0, *)
public struct TermsOfServiceView: View {
    @State private var termsOfService: String? = nil
    @State private var privacyPolicy: String? = nil
    @State private var termsOfServiceUrl: URL?
    @State private var privacyPolicyUrl: URL?
    
    public var body: some View {
        HStack {
            if let termsOfServiceUrl { Link("Terms of Service", destination: termsOfServiceUrl) }
            if termsOfServiceUrl != nil, privacyPolicyUrl != nil { Text("and") }
            if let privacyPolicyUrl { Link("Privacy Policy", destination: privacyPolicyUrl) }
        }
        .onAppear {
            termsOfService = "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/"
            privacyPolicy = "https://russell-archer.github.io/privacy/"
            
            if let termsOfService, let tosUrl = URL(string: termsOfService) { termsOfServiceUrl = tosUrl }
            if let privacyPolicy, let ppUrl = URL(string: privacyPolicy) { privacyPolicyUrl =  ppUrl }
        }
    }
}

