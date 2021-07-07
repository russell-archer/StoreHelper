//
//  StoreHelper.swift
//  StoreHelper
//
//  Created by Russell Archer on 16/06/2021.
//

import StoreKit

public typealias ProductId = String

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
/// StoreHelper encapsulates StoreKit2 in-app purchase functionality and makes it easy to work with the App Store.
public class StoreHelper: ObservableObject {
    
    // MARK: - Public properties
    
    /// Array of `Product` retrieved from the App Store and available for purchase.
    @Published private(set) var products: [Product]?
    
    /// List of `ProductId` for products that have been purchased.
    @Published private(set) var purchasedProducts = Set<ProductId>()
    
    /// The state of a purchase. See `purchase(_:)` and `purchaseState`.
    public enum PurchaseState { case notStarted, inProgress, complete, pending, cancelled, failed, failedVerification, unknown }
    
    /// The current internal state of StoreHelper. If `purchaseState == inprogress` then an attempt to start
    /// a new purchase will result in a `purchaseInProgressException` being thrown by `purchase(_:)`.
    public private(set) var purchaseState: PurchaseState = .notStarted
    
    /// True if we have a list of `Product` returned to us by the App Store.
    public var hasProducts: Bool {
        guard products != nil else { return false }
        return products!.count > 0 ? true : false
    }
    
    /// Computed property that returns all the non-consumable products in the `products` array.
    public var nonConsumableProducts: [Product]? {
        guard products != nil else { return nil }
        return products!.filter { product in product.type == .nonConsumable }
    }
    
    /// Computed property that returns all the auto-renewing subscription products in the `products` array.
    public var subscriptionProducts: [Product]? {
        guard products != nil else { return nil }
        return products!.filter { product in product.type == .autoRenewable }
    }
    
    // MARK: - Private properties
    
    /// Handle for App Store transactions.
    private var transactionListener: Task.Handle<Void, Error>? = nil
    
    // MARK: - Initialization
    
    /// StoreHelper enables support for working with in-app purchases and StoreKit2 using the async/await pattern.
    ///
    /// During initialization StoreHelper will:
    /// - Read the Products.plist configuration file to get a list of `ProductId` that defines the set of products we'll request from the App Store.
    /// - Start listening for App Store transactions.
    /// - Request localized product info from the App Store.
    init() {
        
        // Listen for App Store transactions
        transactionListener = handleTransactions()

        // Read our list of product ids
        if let productIds = Configuration.readConfigFile() {

            // Get localized product info from the App Store
            StoreLog.event(.requestProductsStarted)
            async {

                products = await requestProductsFromAppStore(productIds: productIds)

                if products == nil, products?.count == 0 { StoreLog.event(.requestProductsFailure) } else {
                    StoreLog.event(.requestProductsSuccess)
                }
            }
        }
    }
    
    deinit { transactionListener?.cancel() }
    
    // MARK: - Public methods
    
    /// Request localized product info from the App Store for a set of ProductId.
    ///
    /// This method runs on the main thread because it will result in updates to the UI.
    /// - Parameter productIds: The product ids that you want localized information for.
    /// - Returns: Returns an array of `Product`, or nil if no product information is returned by the App Store.
    @MainActor public func requestProductsFromAppStore(productIds: Set<ProductId>) async -> [Product]? {
        
        return try? await Product.products(for: productIds)
    }
    
    /// Requests the most recent transaction for a product from the App Store and determines if it has been previously purchased.
    ///
    /// May throw an exception of type `StoreException.transactionVerificationFailed`.
    /// - Parameter productId: The `ProductId` of the product.
    /// - Returns: Returns true if the product has been purchased, false otherwise.
    public func isPurchased(productId: ProductId) async throws -> Bool {
        
        guard let currentEntitlement = await Transaction.currentEntitlement(for: productId) else {
            return false  // There's no transaction for the product, so it hasn't been purchased
        }
        
        // See if the transaction passed StoreKit's automatic verification
        let result = checkTransactionVerificationResult(result: currentEntitlement)
        if !result.verified {
            StoreLog.transaction(.transactionValidationFailure, productId: result.transaction.productID)
            throw StoreException.transactionVerificationFailed
        }
        
        // Make sure our internal set of purchase pids is in-sync with the App Store
        await updatePurchasedIdentifiers(result.transaction)
        
        // See if the App Store has revoked the users access to the product (e.g. because of a refund).
        // If this transaction represents a subscription, see if the user upgraded to a higher-level subscription.
        // To determine the service that the user is entitled to, we would need to check for another transaction
        // that has a subscription with a higher level of service.
        return result.transaction.revocationDate == nil && !result.transaction.isUpgraded
    }
    
    /// Requests the most recent transaction for a product from the App Store and determines if it has been previously purchased.
    ///
    /// May throw an exception of type `StoreException.transactionVerificationFailed`.
    /// - Parameter productId: The `ProductId` of the product.
    /// - Returns: Returns true if the product has been purchased, false otherwise.
    public func isPurchased(product: Product) async throws -> Bool {
        
        return try await isPurchased(productId: product.id)
    }
    
    /// Uses StoreKit's `Transaction.currentEntitlements` property to iterate over the sequence of `VerificationResult<Transaction>`
    /// representing all transactions for products the user is currently entitled to. That is, all currently-subscribed
    /// transactions and all purchased (and not refunded) non-consumables. Note that transactions for consumables are not
    /// in the receipt.
    /// - Returns: A verified `Set<ProductId>` for all products the user is entitled to have access to. The set will be empty if the
    /// user has not purchased anything previously.
    public func currentEntitlements() async -> Set<ProductId> {
        
        var entitledProductIds = Set<ProductId>()
        
        for await result in Transaction.currentEntitlements {
            
            if case .verified(let transaction) = result {
                entitledProductIds.insert(transaction.productID)  // Ignore unverified transactions
            }
        }
        
        return entitledProductIds
    }
    
    /// Purchase a `Product` previously returned from the App Store following a call to `requestProductsFromAppStore()`.
    ///
    /// May throw an exception of type:
    /// - `StoreException.purchaseException` if the App Store itself throws an exception
    /// - `StoreException.purchaseInProgressException` if a purchase is already in progress
    /// - `StoreException.transactionVerificationFailed` if the purchase transaction failed verification
    ///
    /// - Parameter product: The `Product` to purchase.
    /// - Returns: Returns a tuple consisting of a transaction object that represents the purchase and a `PurchaseState`
    /// describing the state of the purchase.
    public func purchase(_ product: Product) async throws -> (transaction: Transaction?, purchaseState: PurchaseState)  {
        
        guard purchaseState != .inProgress else {
            StoreLog.exception(.purchaseInProgressException, productId: product.id)
            throw StoreException.purchaseInProgressException
        }
        
        // Start a purchase transaction
        purchaseState = .inProgress
        StoreLog.event(.purchaseInProgress, productId: product.id)
        
        guard let result = try? await product.purchase() else {
            purchaseState = .failed
            StoreLog.event(.purchaseFailure, productId: product.id)
            throw StoreException.purchaseException
        }
        
        // Every time an app receives a transaction from StoreKit 2, the transaction has already passed through a
        // verification process to confirm whether the payload is signed by the App Store for my app for this device.
        // That is, Storekit2 does transaction (receipt) verification for you (no more OpenSSL or needing to send
        // a receipt to an Apple server for verification).
        
        // We now have a PurchaseResult value. See if the purchase suceeded, failed, was cancelled or is pending.
        switch result {
            case .success(let verificationResult):
                
                // The purchase seems to have succeeded. StoreKit has already automatically attempted to validate
                // the transaction, returning the result of this validation wrapped in a `VerificationResult`.
                // We now need to check the `VerificationResult<Transaction>` to see if the transaction passed the
                // App Store's validation process. This is equivalent to receipt validation in StoreKit1.
                
                // Did the transaction pass StoreKit’s automatic validation?
                let checkResult = checkTransactionVerificationResult(result: verificationResult)
                if !checkResult.verified {
                    purchaseState = .failedVerification
                    StoreLog.transaction(.transactionValidationFailure, productId: checkResult.transaction.productID)
                    throw StoreException.transactionVerificationFailed
                }
                
                // The transaction was successfully validated.
                let validatedTransaction = checkResult.transaction
                
                // Update the list of purchased ids. Because it's is a @Published var this will cause the UI
                // showing the list of products to update
                await updatePurchasedIdentifiers(validatedTransaction)
                
                // Tell the App Store we delivered the purchased content to the user
                await validatedTransaction.finish()
                
                // Let the caller know the purchase succeeded and that the user should be given access to the product
                purchaseState = .complete
                StoreLog.event(.purchaseSuccess, productId: product.id)
                return (transaction: validatedTransaction, purchaseState: .complete)
                
            case .userCancelled:
                purchaseState = .cancelled
                StoreLog.event(.purchaseCancelled, productId: product.id)
                return (transaction: nil, .cancelled)
                
            case .pending:
                purchaseState = .pending
                StoreLog.event(.purchasePending, productId: product.id)
                return (transaction: nil, .pending)
                
            default:
                purchaseState = .unknown
                StoreLog.event(.purchaseFailure, productId: product.id)
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
    
    // MARK: - Private methods
    
    /// This is an infinite async sequence (loop). It will continue waiting for transactions until it is explicitly
    /// canceled by calling the Task.Handle.cancel() method. See `transactionListener`.
    /// - Returns: Returns a handle for the transaction handling loop task.
    private func handleTransactions() -> Task.Handle<Void, Error> {
        
        return detach {
            
            for await verificationResult in Transaction.updates {
                
                // See if StoreKit validated the transaction
                let checkResult = self.checkTransactionVerificationResult(result: verificationResult)
                StoreLog.transaction(.transactionReceived, productId: checkResult.transaction.productID)
                
                if checkResult.verified {
                    
                    let validatedTransaction = checkResult.transaction
                    
                    // The transaction was validated so update the list of products the user has access to
                    await self.updatePurchasedIdentifiers(validatedTransaction)
                    await validatedTransaction.finish()
                    
                } else {
                    
                    // StoreKit's attempts to validate the transaction failed. Don't deliver content to the user.
                    StoreLog.transaction(.transactionFailure, productId: checkResult.transaction.productID)
                }
            }
        }
    }
    
    /// Update our list of purchased product identifiers (see `purchasedProducts`).
    ///
    /// This method runs on the main thread because it will result in updates to the UI.
    /// - Parameter transaction: The `Transaction` that will result in changes to `purchasedProducts`.
    @MainActor private func updatePurchasedIdentifiers(_ transaction: Transaction) async {
        
        if transaction.revocationDate == nil {
            
            // The transaction has NOT been revoked by the App Store so this product has been purchase.
            // Add the ProductId to the list of `purchasedProducts` (it's a Set so it won't add if already there).
            purchasedProducts.insert(transaction.productID)
            
        } else {
            
            // The App Store revoked this transaction (e.g. a refund), meaning the user should not have access to it.
            // Remove the product from the list of `purchasedProducts`.
            purchasedProducts.remove(transaction.productID)
        }
    }
    
    /// Check if StoreKit was able to automatically verify a transaction by inspecting the verification result.
    ///
    /// - Parameter result: The transaction VerificationResult to check.
    /// - Returns: The verified `Transaction`, or nil if the transaction result was unverified.
    private func checkTransactionVerificationResult(result: VerificationResult<Transaction>) -> (transaction: Transaction, verified: Bool) {
        
        switch result {
            case .unverified(let unverifiedTransaction):
                return (transaction: unverifiedTransaction, verified: false)  // StoreKit failed to automatically validate the transaction
                
            case .verified(let verifiedTransaction):
                return (transaction: verifiedTransaction, verified: true)  // StoreKit successfully automatically validated the transaction
        }
    }
}
