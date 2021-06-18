//
//  Utils.swift
//  StoreHelper
//
//  Created by Russell Archer on 16/06/2021.
//

import Foundation

struct Utils {
    
    /// Detects if the app is running as a preview
    static var isRunningPreview: Bool { ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" }
}

