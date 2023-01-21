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
    public static func isDebug() -> Bool { return self.debug }
    public static func isRelease() -> Bool { return !self.debug }
    public static func isSimulator() -> Bool { return self.simulator }
    
    public static func confirmGestureText() -> String {
        #if os(iOS)
        "Tap"
        #else
        "Click"
        #endif
    }
    
    #if DEBUG
    /// Simulate a lengthy async operation. Suspend the current task for the given duration. Doesn’t block the current thread.
    /// - Parameters:
    ///   - min: Minimum wait.
    ///   - max: Maximum wait.
    @MainActor public static func simulateRandomWait(min: Int = 0, max: Int = 5) async {
        let r = Int.random(in: min...max)
        guard r > 0 else { return }
        try? await Task.sleep(nanoseconds: UInt64(r * 1_000_000_000))
    }
    #endif
    
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
}

