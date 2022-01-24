//
//  AppStoreHelper.swift
//  StoreHelper
//
//  Created by Russell Archer on 17/11/2021.
//

import StoreKit

/// Support for StoreKit1. Tells the observer that a user initiated an in-app purchase direct from the App Store,
/// rather than via the app itself. StoreKit2 does not (yet) provide support for this feature so we need to use
/// StoreKit1. This is a requirement in order to promote in-app purchases on the App Store. If your app doesn't
/// have a class that implements `SKPaymentTransactionObserver` and the `paymentQueue(_:updatedTransactions:)`
/// and `paymentQueue(_:shouldAddStorePayment:for:)` delegate methods then you'll get an error when you submit
/// the app to the App Store and you have IAP promotions.
///
/// Note that any IAPs made from **inside** the app are processed by StoreKit2 and do not involve this helper class.
public class AppStoreHelper: NSObject, SKPaymentTransactionObserver {

    private weak var storeHelper: StoreHelper?
    
    public convenience init(storeHelper: StoreHelper) {
        self.init()
        self.storeHelper = storeHelper
    }
    
    public override init() {
        super.init()
        
        // Add ourselves as an observer of the StoreKit payments queue. This allows us to receive
        // notifications for when payments are successful, fail, are restored, etc.
        SKPaymentQueue.default().add(self)
    }
    
    /// Delegate method for the StoreKit1 payment queue. Note that because our main StoreKit processing is done
    /// via StoreKit2 in StoreHelper, all we have to do here is signal to StoreKit1 to finish purchased, restored
    /// or failed transactions. StoreKit1 purchases are immediately available to StoreKit2 (and vice versa), so
    /// any purchase will be picked up by StoreHelper as required.
    /// - Parameters:
    ///   - queue: StoreKit1 payment queue
    ///   - transactions: Collection of updated transactions (e.g. `purchased`)
    public func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch (transaction.transactionState) {
                case .purchased:
                    SKPaymentQueue.default().finishTransaction(transaction)
                    Task.init { await storeHelper?.productPurchased(transaction.payment.productIdentifier) }  // Tell StoreKit2-based StoreHelper about purchase
                case .restored: fallthrough
                case .failed: SKPaymentQueue.default().finishTransaction(transaction)
                default: break
            }
        }
    }
    
    /// Lets us know a user initiated an in-app purchase direct from the App Store, rather than via the app itself.
    /// This method is required if you have IAP promotions.
    public func paymentQueue(_ queue: SKPaymentQueue, shouldAddStorePayment payment: SKPayment, for product: SKProduct) -> Bool {
        // Return true to continue the transaction. If this IAP has been previously purchased it'll be picked up
        // by StoreKit1 and re-purchase prevented
        return true
    }
}

