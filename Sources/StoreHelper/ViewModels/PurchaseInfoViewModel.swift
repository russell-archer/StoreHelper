//
//  PurchaseInfoViewModel.swift
//  StoreHelper
//
//  Created by Russell Archer on 21/07/2021.
//

import StoreKit
import SwiftUI

@available(iOS 15.0, macOS 12.0, *)
public struct ExtendedPurchaseInfo: Hashable {
    public var productId: ProductId                                      // The product's unique id
    public var name: String                                              // The product's display name
    public var isPurchased: Bool                                         // true if the product has been purchased
    public var productType: Product.ProductType                          // Consumable, non-consumable, subscription, etc.
    public var transactionId: UInt64?                                    // The transactionid for the purchase. UInt64.min if not purchased
    public var purchasePrice: String?                                    // Localized price paid when purchased
    public var purchaseDate: Date?                                       // Date of purchase
    public var purchaseDateFormatted: String?                            // Date of purchase formatted as "d MMM y" (e.g. "28 Dec 2021")
    public var revocationDate: Date?                                     // Date the app revoked the purchase (e.g. because of a refund, etc.)
    public var revocationDateFormatted: String?                          // Date of revocation formatted as "d MMM y"
    public var revocationReason: StoreKit.Transaction.RevocationReason?  // Why the purchase was revoked (.developerIssue or .other)
    public var ownershipType: StoreKit.Transaction.OwnershipType?        // Either .purchased or .familyShared

    public init(productId: ProductId,
                name: String,
                isPurchased: Bool,
                productType: Product.ProductType,
                transactionId: UInt64?  = nil,
                purchasePrice: String? = nil,
                purchaseDate: Date? = nil,
                purchaseDateFormatted: String? = nil,
                revocationDate: Date? = nil,
                revocationDateFormatted: String? = nil,
                revocationReason: StoreKit.Transaction.RevocationReason? = nil,
                ownershipType: StoreKit.Transaction.OwnershipType? = nil) {
        
        self.productId = productId
        self.name = name
        self.isPurchased = isPurchased
        self.productType = productType
        self.transactionId = transactionId
        self.purchasePrice = purchasePrice
        self.purchaseDate = purchaseDate
        self.purchaseDateFormatted = purchaseDateFormatted
        self.revocationDate = revocationDate
        self.revocationDateFormatted = revocationDateFormatted
        self.revocationReason = revocationReason
        self.ownershipType = ownershipType
    }
}

/// ViewModel for `PurchaseInfoView`. Enables gathering of purchase or subscription information.
@available(iOS 15.0, macOS 12.0, *)
public struct PurchaseInfoViewModel {
    
    @ObservedObject public var storeHelper: StoreHelper
    public var productId: ProductId
    
    /// Provides text information on the purchase of a non-consumable product or auto-renewing subscription.
    /// - Parameter productId: The `ProductId` of the product or subscription.
    /// - Returns: Returns text information on the purchase of a non-consumable product or auto-renewing subscription.
    @MainActor public func info(for productId: ProductId) async -> String {
        
        guard let product = storeHelper.product(from: productId) else { return "No purchase info available" }
        guard product.type != .nonRenewable else { return "No info available on non-renewable subscription" }
        
        // Are we dealing with a consumable? If so, the only data we have is if the product was purchased or not.
        // Currently, StoreHelper simply keeps a count for each purchased made of a particular consumable product.
        // We do not store the date of the purchase, etc. In a production system that supports consumable products you
        // would need to store more complete information on each purchase. Note that StoreKit does not store data
        // on consumable product purchases in the receipt.
        if product.type == .consumable {
            if let consumablePurchased = try? await storeHelper.isPurchased(product: product) {
                return consumablePurchased ? "Purchased" : "Not purchased"
            }
            
            return "No purchase data"
        }
        
        // We're dealing with a non-consumable product or subscription.
        // Get detail purchase/subscription info on the product.
        guard let info = await storeHelper.purchaseInfo(for: product) else { return "" }
        
        var text = ""
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d MMM y"
        
        if info.product.type == .nonConsumable {
            guard let transaction = info.latestVerifiedTransaction else { return "" }
            
            text = "Purchased \(dateFormatter.string(from: transaction.purchaseDate))"
            if let revocationDate = transaction.revocationDate {
                text += " (revoked \(dateFormatter.string(from: revocationDate)))"
            }
        }
        
        return text
    }
    
    /// Provides extended information on the purchase of a non-consumable product.
    /// - Parameter productId: The `ProductId` of the product or subscription.
    /// - Returns: Returns `ProductPurchaseInfo` on the purchase of a non-consumable product or auto-renewing subscription,
    /// or nil of the product has not been purchased.
    @MainActor public func extendedPurchaseInfo(for nonConsumableProductId: ProductId) async -> ExtendedPurchaseInfo? {
        guard let product = storeHelper.product(from: productId) else { return nil }
        
        var epi =  ExtendedPurchaseInfo(productId: product.id, name: product.displayName, isPurchased: false, productType: product.type, purchasePrice: product.displayPrice)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d MMM y"
        
        epi.isPurchased = (try? await storeHelper.isPurchased(productId: product.id)) ?? false
        guard epi.isPurchased else { return epi }
        guard let transaction = await storeHelper.mostRecentTransaction(for: product.id) else { return epi }

        epi.transactionId = transaction.id
        epi.purchaseDate = transaction.purchaseDate
        epi.purchaseDateFormatted = dateFormatter.string(from: transaction.purchaseDate)
        epi.revocationDate = transaction.revocationDate
        epi.revocationDateFormatted = transaction.revocationDate == nil ? nil : dateFormatter.string(from: transaction.revocationDate!)
        epi.revocationReason = transaction.revocationReason
        epi.ownershipType = transaction.ownershipType
        
        return epi
    }
    
    /// Determines if a product has been previously purchased. Works for all product types (consumable, non-consumable and subscription).
    /// - Parameter productId: The `ProductId` of the product.
    /// - Returns: Returns true if the product has been purchased, false otherwise.
    @MainActor public func isPurchased(productId: ProductId) async -> Bool { (try? await storeHelper.isPurchased(productId: productId)) ?? false }
}

