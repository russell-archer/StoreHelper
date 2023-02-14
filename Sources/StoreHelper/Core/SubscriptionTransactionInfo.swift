//
//  SubscriptionTransactionInfo.swift
//  StoreHelper
//
//  Created by Russell Archer on 27/11/2022.
//

import StoreKit
import OrderedCollections
import SwiftUI

/// Holds information about a subscription transaction in an easy-to-use format.
@available(iOS 15.0, macOS 12.0, *)
public struct SubscriptionTransactionInfo: Hashable {
    /// Information on the result of unwrapping the raw transaction `VerificationResult`.
    public var unwrappedTransaction: UnwrappedVerificationResult<StoreKit.Transaction>
    
    /// The unique identifier for the transaction. Every transaction such as an in-app purchase, restore, or subscription renewal has a unique transaction identifier.
    public var transactionId: UInt64 { unwrappedTransaction.transaction.id }
    
    /// The date the user actually purchased the subscription in the app or App Store.
    public var originalPurchaseDate: Date { unwrappedTransaction.transaction.originalPurchaseDate}
    
    /// The date that App Store refunded the transaction or revoked it from family sharing.
    public var revocationDate: Date? { unwrappedTransaction.transaction.revocationDate}
    
    /// True if the transaction has been verified by StoreKit, false otherwise.
    public var isVerified: Bool { unwrappedTransaction.verified }
    
    /// The ProductId to which the transaction relates.
    public var productId: ProductId { unwrappedTransaction.transaction.productID }
    
    /// The date the subscription expired, or will expire in the future.
    public var expirationDate: Date? { unwrappedTransaction.transaction.expirationDate }
    
    /// True if the transaction has expired, false otherwise. If nil, the expiration date cannot be determined.
    public var hasExpired: Bool? {
        guard let expiration = expirationDate else { return nil }
        return expiration < Date.now
    }
    
    /// The introductory or promotional offer, if any, associated with this transaction. If nil, no offer is associated with this transaction.
    public var offerType: StoreKit.Transaction.OfferType? {
        guard let offerType = unwrappedTransaction.transaction.offerType else { return nil }
        return offerType
    }
    
    /// The identifier of the subscription group that the subscription belongs to.
    public var subscriptionGroupID: String? { unwrappedTransaction.transaction.subscriptionGroupID }
    
    /// The subscription group that the subscription belongs to.
    public var subscriptionGroup: String? { storeHelper.subscriptionHelper.groupName(from: productId) }
    
    /// Weak reference to StoreHelper
    weak private var storeHelper: StoreHelper!
    
    public init?(unwrappedTransaction: UnwrappedVerificationResult<StoreKit.Transaction>, storeHelper: StoreHelper) async {
        self.unwrappedTransaction = unwrappedTransaction
        self.storeHelper = storeHelper
        
        // Check that the transaction has been verified and that it's for a subscription. If not, fail initialization
        guard unwrappedTransaction.verified, unwrappedTransaction.transaction.productType == .autoRenewable else { return nil }
    }
    
    // MARK: - Hashable and Equatable protocol support
    
    public func hash(into hasher: inout Hasher) { hasher.combine(transactionId) }
    public static func == (lhs: SubscriptionTransactionInfo, rhs: SubscriptionTransactionInfo) -> Bool { lhs.transactionId == rhs.transactionId }
}
