//
//  StoreConstants.swift
//  StoreHelper
//
//  Created by Russell Archer on 16/06/2021.
//

import Foundation

/// Constants used in support of App Store operations.
public struct StoreConstants {
    
    /// Returns the name of the .plist configuration file that holds a list of `ProductId`.
    public static let ConfigFile = "Products"
    
    /// The UserDefaults key used to store the fallback list of purchased products.
    public static let PurchasedProductsFallbackKey = "PurchasedProductsFallback"
}

