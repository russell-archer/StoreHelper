//
//  Configuration.swift
//  StoreHelper
//
//  Created by Russell Archer on 16/06/2021.
//

import Foundation

/// Provides static methods for reading plist configuration files.
public struct Configuration {
    
    /// Read a plist property file and return a dictionary of values
    public static func readPropertyFile(filename: String) -> [String : AnyObject]? {
        if let path = Bundle.main.path(forResource: filename, ofType: "plist") {
            if let contents = NSDictionary(contentsOfFile: path) as? [String : AnyObject] {
                return contents
            }
        }

        return nil  // [:]
    }
}
