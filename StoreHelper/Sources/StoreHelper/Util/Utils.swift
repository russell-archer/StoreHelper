//
//  Utils.swift
//  StoreHelper
//
//  Created by Russell Archer on 16/06/2021.
//

import Foundation

/// Various utility methods.
public struct Utils {
    
    /// Detects if the app is running as a preview
    public static var isRunningPreview: Bool { ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" }
    
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
    
    public static func isDebug() -> Bool { return self.debug }
    public static func isRelease() -> Bool { return !self.debug }
    public static func isSimulator() -> Bool { return self.simulator }
}

