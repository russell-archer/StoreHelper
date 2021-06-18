//
//  StoreHelper.swift
//  StoreHelper
//
//  Created by Russell Archer on 16/06/2021.
//

import StoreKit

public typealias ProductId = String

/// StoreHelper encapsulates StoreKit2 in-app purchase functionality and makes it easy to work with the App Store.
@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
class StoreHelper: ObservableObject {
    
    // MARK: - Public properties
    
    /// List of `Product` retrieved from the App Store and available for purchase.
    @Published private(set) var products: [Product]?
    
    /// List of `ProductId` for products that have been purchased.
    @Published private(set) var purchasedProducts = Set<ProductId>()
    
    /// The state of a purchase. See `purchase(_:)`.
    public enum PurchaseState { case complete, pending, cancelled, failed, unknown }
    
    /// List of `ProductId` read from the Products.plist configuration file.
    public var configuredProductIdentifiers: Set<ProductId>?
    
    /// True if we have a list of `ProductId` read from Products.plist.
    public var hasConfiguredProductIdentifiers: Bool {
        guard configuredProductIdentifiers != nil else { return false }
        return configuredProductIdentifiers!.count > 0 ? true : false
    }
    
    /// True if we have a list of `Product` returned to us by the App Store.
    public var hasProducts: Bool {
        guard products != nil else { return false }
        return products!.count > 0 ? true : false
    }
    
    // MARK: - Internal properties
    
    /// Handle for App Store transactions.
    internal var transactionListener: Task.Handle<Void, Error>? = nil
    
    // MARK: - Initialization
    
    /// StoreHelper enables support for working with in-app purchases and StoreKit2 using the async/await pattern.
    ///
    /// During initialization StoreHelper will:
    /// - Read the Products.plist configuration file to get a list of `ProductId` that defines the set of products we'll request from the App Store.
    /// - Start listening for App Store transactions.
    /// - Request localized product info from the App Store.
    init() {
        
        readConfigFile()                                // Read our list of product ids
        transactionListener = handleTransactions()      // Listen for App Store transactions
        async { await requestProductsFromAppStore() }   // Get localized product info from the App Store
    }
    
    deinit {
        
        transactionListener?.cancel()
    }
    
    // MARK: - Public methods
    
    /// Request localized product info from the App Store using the set of `ProductID` defined in Products.plist.
    /// When the request is complete the `products` property will contain an array of `Product`, or nil if there's an error.
    ///
    /// This function runs on the main thread.
    @MainActor
    public func requestProductsFromAppStore() async {
        
        StoreLog.event(.requestProductsStarted)
        products = try? await Product.request(with: configuredProductIdentifiers!)
        
        if let p = products, p.count > 0 { StoreLog.event(.requestProductsSuccess) }
        else { StoreLog.event(.requestProductsFailure) }
    }
    
    /// Requests the most recent transaction for a product from the App Store and determines if it has been previously purchased.
    ///
    /// May throw an exception of type StoreException.transactionException.
    /// - Parameter productId: The `ProductId` of the product.
    /// - Returns: Returns true if the product has been purchased, false otherwise.
    public func isPurchased(productId: ProductId) async throws -> Bool {
        
        guard let mostRecentTransaction = await Transaction.latest(for: productId) else {
            return false  // There's no transaction for the product, so it hasn't been purchased
        }
        
        // See if the transaction passed StoreKit's automatic verification
        guard let validatedTransaction = checkTransactionVerificationResult(transactionVerificationResult: mostRecentTransaction) else {
            throw StoreException.transactionException
        }
        
        // See if the App Store has revoked the users access to the product (e.g. because of a refund).
        // If this transaction represents a subscription, see if the user upgraded to a higher-level subscription.
        // To determine the service that the user is entitled to, we would need to check for another transaction
        // that has a subscription with a higher level of service.
        return validatedTransaction.revocationDate == nil && !validatedTransaction.isUpgraded
    }
    
    /// Purchase a `Product` previously returned from the App Store following a call to `requestProductsFromAppStore()`.
    ///
    /// May throw an exception of type `PurchaseError`, `StoreKitError` or `StoreException.transactionException`.
    /// - Parameter product: The `Product` to purchase.
    /// - Returns: Returns a tuple consisting of a transaction object that represents the purchase and a `PurchaseState`
    /// describing the state of the purchase.
    public func purchase(_ product: Product) async throws -> (transaction: Transaction?, purchaseState: PurchaseState)  {
        
        StoreLog.event(.purchaseInProgress(productId: product.id))
        
        // Start a purchase transaction
        let result = try await product.purchase()
        
        // Every time an app receives a transaction from StoreKit 2, the transaction has already passed through a
        // verification process to confirm whether the payload is signed by the App Store for my app for this device.
        // That is, Storekit2 does transaction (receipt) verification for you! No more OpenSSL or needing to send
        // a receipt to an Apple server for verification!
        //
        // You can also associate a purchase with a particular account/user in your system.
        // When you set the app account token in the purchase options, the App Store returns the same app account
        // token value in the resulting transaction, in appAccountToken. This allows you to keep track of a user's
        // purchases.
        //
        // let myId = UUID()
        // let result = try await product.purchase(options: [.appAccountToken(myId)])
        
        // We now have a PurchaseResult value. See if the purchase suceeded, failed, was cancelled or is pending.
        switch result {
            case .success(let verificationResult):
                
                // The purchase succeeded. We now need to check the VerificationResult<Transaction>
                // to see if the transaction passed the App Store's validation process (equivalent to
                // receipt validation).
                //
                /*
                 verificationResult: (VerificationResult<Transaction>)
                 A type that describes the result of a StoreKit verification.
                 StoreKit automatically verifies the Transaction and Product.SubscriptionInfo.RenewalInfo values.
                 To access the wrapped values, check whether the values are verified or unverified.
                 */
                
                // The verification describes the result of StoreKit's verification process.
                // StoreKit verifys a transaction for you.
                // A transaction represents a successful in-app purchase.
                /*
                 
                 StoreKit automatically validates the transaction information, returning it wrapped in a VerificationResult.
                 If you get a transaction through VerificationResult.verified(_:), the information passed validation.
                 If you get it through VerificationResult.unverified(_:), the transaction information didn’t pass StoreKit’s
                 automatic validation.
                 
                 If required, you can perform your own validation directly on the transaction’s jws string, or use the
                 provided convenience properties such as headerData, payloadData, signatureData.
                 */
                
                // Did the transaction pass StoreKit’s automatic validation?
                guard let validatedTransaction = checkTransactionVerificationResult(transactionVerificationResult: verificationResult) else {
                    throw StoreException.transactionException
                }
                
                // Update the list of purchased ids. Because it's is a @Published var this will cause the UI
                // showing the list of products to update
                await updatePurchasedIdentifiers(validatedTransaction)
                
                // Tell the App Store we delivered the purchased content to the user
                await validatedTransaction.finish()
                
                // Let the caller know the purchase succeeded
                StoreLog.event(.purchaseSuccess(productId: product.id))
                return (transaction: validatedTransaction, purchaseState: .complete)
                
            case .userCancelled:
                StoreLog.event(.purchaseCancelled(productId: product.id))
                return (transaction: nil, .cancelled)
                
            case .pending:
                StoreLog.event(.purchasePending(productId: product.id))
                return (transaction: nil, .pending)
                
            default:
                StoreLog.event(.purchaseFailure(productId: product.id))
                return (transaction: nil, .unknown)
        }
    }
    
    public func product(from productId: ProductId) -> Product? {
        
        guard products != nil else { return nil }
        
        let matchingProduct = products!.filter { product in
            product.id == productId
        }
        
        guard matchingProduct.count == 1 else { return nil }
        return matchingProduct.first
    }
    
    // MARK: - Internal methods
    
    /// Read the contents of the ProductId property list and updates `configuredProductIdentifiers`.
    /// - Returns: Returns true if list was read and `configuredProductIdentifiers` updated, false otherwise.
    internal func readConfigFile() {
        
        // Read our configuration file that contains the list of ProductIds that are available on the App Store.
        configuredProductIdentifiers = nil
        
        guard let result = Configuration.readPropertyFile(filename: StoreConstants.ConfigFile) else {
            StoreLog.event(.configurationNotFound)
            StoreLog.event(.configurationFailure)
            return
        }
        
        guard result.count > 0 else {
            StoreLog.event(.configurationEmpty)
            StoreLog.event(.configurationFailure)
            return
        }
        
        guard let values = result[StoreConstants.ConfigFile] as? [String] else {
            StoreLog.event(.configurationEmpty)
            StoreLog.event(.configurationFailure)
            return
        }
        
        configuredProductIdentifiers = Set<ProductId>(values.compactMap { $0 })
        StoreLog.event(.configurationSuccess)
    }
    
    /// This is an infinite async sequence (loop). It will continue waiting for transactions until it is explicitly
    /// canceled by calling the Task.Handle.cancel() method. See `transactionListener`.
    /// - Returns: Returns a handle for the transaction handling loop task.
    internal func handleTransactions() -> Task.Handle<Void, Error> {
        
        return detach {
            
            for await verificationResult in Transaction.listener {
                
                // Did StoreKit validate the transaction?
                if let validatedTransaction = self.checkTransactionVerificationResult(transactionVerificationResult: verificationResult) {

                    // The transaction was validated so updated the list of products the user has access to
                    await self.updatePurchasedIdentifiers(validatedTransaction)
                    await validatedTransaction.finish()
                    
                    StoreLog.event(.transactionSuccess(productId: validatedTransaction.productID))
                    
                } else {
                    
                    // StoreKit's attempts to validate the transaction failed. Don't deliver content to the user.
                    StoreLog.event(.transactionFailure)
                }
            }
        }
    }
    
    @MainActor
    /// Update our list of purchase product identifiers (see `purchasedProducts`).
    ///
    /// This function runs on the main thread because it will result in updates to the UI.
    /// - Parameter transaction: The `Transaction` that will result in changes to `purchasedProducts`.
    internal func updatePurchasedIdentifiers(_ transaction: Transaction) async {
        
        if transaction.revocationDate == nil {
            
            // The transaction hasn't been revoked by the App Store so add the ProductId to the list of `purchasedProducts`
            purchasedProducts.insert(transaction.productID)
            
        } else {
            
            // The App Store revoked this transaction (e.g. a refund), meaning the user should not have access to it.
            // Remove the product from the list of `purchasedProducts`
            purchasedProducts.remove(transaction.productID)
        }
    }
    
    /// Check if StoreKit was able to automatically verify a transaction.
    /// - Parameter transactionVerificationResult: The transaction VerificationResult to check.
    /// - Returns: The verified `Transaction`, or nil if the transaction result was unverified.
    internal func checkTransactionVerificationResult(transactionVerificationResult: VerificationResult<Transaction>) -> Transaction? {
        switch transactionVerificationResult {
            case .unverified(let unverifiedTransaction):
                StoreLog.event(.transactionValidationFailure(productId: unverifiedTransaction.productID))
                return nil
                
            case .verified(let verifiedTransaction):
                StoreLog.event(.transactionValidationSuccess(productId: verifiedTransaction.productID))
                return verifiedTransaction
        }
    }
}
