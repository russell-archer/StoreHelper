//
//  Utils.swift
//  StoreHelper
//
//  Created by Russell Archer on 16/06/2021.
//

import Foundation

/// Various utility methods.
struct Utils {
    
    /// Detects if the app is running as a preview
    static var isRunningPreview: Bool { ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" }
    
    private static let debug: Bool = {
        #if DEBUG
        return true
        #else
        return false
        #endif
    }()
    
    private static let simulator: Bool = {
        #if targetEnvironment(simulator)
        return true
        #else
        return false
        #endif
    }()
    
    static func isDebug() -> Bool { return self.debug }
    static func isRelease() -> Bool { return !self.debug }
    static func isSimulator() -> Bool { return self.simulator }
}

