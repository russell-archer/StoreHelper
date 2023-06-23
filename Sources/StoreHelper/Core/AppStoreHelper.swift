//
//  AppStoreHelper.swift
//  StoreHelper
//
//  Created by Russell Archer on 17/11/2021.
//

import StoreKit

/// Support for StoreKit1. Tells the observer that a user initiated an in-app purchase direct from the App Store,
/// rather than via the app itself. StoreKit2 does not (yet) provide support for direct purchases, so we need to
/// use StoreKit1. This is a requirement in order to promote in-app purchases on the App Store. If your app doesn't
/// have a class that implements `SKPaymentTransactionObserver` and the `paymentQueue(_:updatedTransactions:)` and
/// `paymentQueue(_:shouldAddStorePayment:for:)` delegate methods then you'll get an error when you submit the app
/// to the App Store and you have IAP promotions.
///
/// `AppStoreHelper` also handles subscription auto-renewal transactions that happen when the app's not running.
/// For whatever reason, these transactions are not handled by StoreKit2 so the `paymentQueue(_:updatedTransactions)`
/// method handles renewal transactions and passes them on to the StoreKit2-based `StoreHelper`.
///
/// Note that any IAPs made from **inside** the app are processed by StoreKit2 and do not involve this helper class.
@available(iOS 15.0, macOS 12.0, *)
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
    
    /// Delegate method for the StoreKit1 payment queue. This method handles subscription transactions (e.g. renewals)
    /// that happen when the app's not running. It also handles in-app purchases made directly from the App Store,
    ///
    /// Because our main StoreKit processing is done via StoreKit2 in StoreHelper, all we have to do here is signal to
    /// StoreKit1 to finish purchased, restored or failed transactions. StoreKit1 purchases are (in theory) immediately
    /// available to StoreKit2 (and vice versa), so any purchase will be picked up by StoreHelper as required.
    ///
    /// Note on subscription transactions: In Xcode StoreKit Testing and Sandbox Testing subscription renewal transactions
    /// that happen when the app's not running are NEVER picked up by StoreKit2. That is, the transactions don't appear
    /// in `StoreKit.Transaction.all` or `Transaction.currentEntitlement(for:)`. This seems to have been a known issue
    /// since the release of StoreKit2 and can lead to the situation where a user has paid to renew their subscription
    /// but StoreKit2 has no knowledge of it.
    ///
    /// **Note that production builds using the live App Store DO NOT appear to suffer from this issue**.
    ///
    /// As a workaround, `StoreHelper` maintains a `transactionUpdateCache` that keeps track of subscription renewals
    /// that happen when the app's not running.
    ///
    /// - Parameters:
    ///   - queue: StoreKit1 payment queue
    ///   - transactions: Collection of updated transactions (e.g. `purchased`)
    public func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            let transactionId = transaction.transactionIdentifier ?? "0"
            let productId = transaction.payment.productIdentifier
            
            switch (transaction.transactionState) {
                case .purchased:
                    SKPaymentQueue.default().finishTransaction(transaction)
                    
                    // Let the StoreKit2-based StoreHelper know about this purchase or subscription renewal
                    Task { @MainActor in
                        if let storeHelper {
                            storeHelper.productPurchased(productId, transactionId: transactionId)
                            await storeHelper.handleStoreKit1Transactions(productId: productId, date: Date(), status: .purchased, transaction: transaction)
                            if let handler = storeHelper.transactionNotification { handler(.purchaseSuccess, productId, transactionId) }
                        }
                    }

                case .restored:
                    SKPaymentQueue.default().finishTransaction(transaction)
                    
                case .failed:
                    SKPaymentQueue.default().finishTransaction(transaction)
                    Task { @MainActor in
                        if let handler = storeHelper?.transactionNotification { handler(.purchaseFailure, productId, transactionId) }
                    }

                default: break
            }
        }
    }
    
    /// Lets us know a user initiated an in-app purchase direct from the App Store, rather than via the app itself.
    /// There is currently no StoreKit2 support for this process, so we fallback to using a StoreKit1-based approach.
    ///
    /// Return `true` (the default) to continue the transaction. Return `false` to defer or cancel the purchase.
    /// This allows for custom purchase processing, such as the display of custom product information.
    /// If false is returned, you can continue the transaction at a later time by manually adding the `SKPayment`
    /// payment object to the `SKPaymentQueue` queue using `SKPaymentQueue.default().add(payment)`.
    ///
    /// If you need to implement custom purchase handling of direct App Store purchases of IAP promotions then
    /// define a closure for `StoreHelper.shouldAddStorePaymentHandler` as in the following example:
    ///
    /// ```
    /// struct StoreHelperDemoApp: App {
    ///     @StateObject var storeHelper = StoreHelper()
    ///
    ///     var body: some Scene {
    ///         WindowGroup {
    ///             MainView()
    ///                 .environmentObject(storeHelper)
    ///                 .task {
    ///                     storeHelper.start()  // Start listening for transactions
    ///
    ///                     // Custom handling of direct App Store purchases of IAP promotions
    ///                     storeHelper.shouldAddStorePaymentHandler = { payment, product in
    ///                         // Your custom handling code goes here
    ///                         return false
    ///                     }
    ///                 }
    ///         }
    ///     }
    /// }
    /// ```
    ///
    /// This method is required if you have in-app purchase promotions defined in App Store Connect.
    public func paymentQueue(_ queue: SKPaymentQueue, shouldAddStorePayment payment: SKPayment, for product: SKProduct) -> Bool {
        if let handler = storeHelper?.shouldAddStorePaymentHandler { return handler(payment, product) }
        return true
    }
}
