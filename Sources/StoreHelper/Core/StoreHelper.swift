//
//  StoreHelper.swift
//  StoreHelper
//
//  Created by Russell Archer on 16/06/2021.
//

import StoreKit
import Collections

public typealias ProductId = String
public typealias ShouldAddStorePaymentHandler = (_ payment: SKPayment, _ product: SKProduct) -> Bool
public typealias TransactionNotification = (_ notification: StoreNotification, _ productId: ProductId, _ transactionId: String) -> Void

/// The state of a purchase.
public enum PurchaseState {
    case notStarted, userCannotMakePayments, inProgress, purchased, pending, cancelled, failed, failedVerification, unknown, notPurchased
    
    public func shortDescription() -> String {
        switch self {
            case .notStarted:               return "Purchase has not started"
            case .userCannotMakePayments:   return "User cannot make payments"
            case .inProgress:               return "Purchase in-progress"
            case .purchased:                return "Purchased"
            case .pending:                  return "Purchase pending"
            case .cancelled:                return "Purchase cancelled"
            case .failed:                   return "Purchase failed"
            case .failedVerification:       return "Purchase failed verification"
            case .unknown:                  return "Purchase status unknown"
            case .notPurchased:             return "Not purchased"
        }
    }
}

/// Information on the result of unwrapping a transaction `VerificationResult`.
@available(iOS 15.0, macOS 12.0, *)
public struct UnwrappedVerificationResult<T> {
    /// The verified or unverified transaction.
    public let transaction: T
    
    /// True if the transaction was successfully verified by StoreKit.
    public let verified: Bool
    
    /// If `verified` is false then `verificationError` will hold the verification error, nil otherwise.
    public let verificationError: VerificationResult<T>.VerificationError?
}

/// StoreHelper encapsulates StoreKit2 in-app purchase functionality and makes it easy to work with the App Store.
@available(iOS 15.0, macOS 12.0, *)
public class StoreHelper: ObservableObject {
    
    // MARK: - Public properties
    
    /// Array of `Product` retrieved from the App Store and available for purchase.
    @Published public private(set) var products: [Product]?
    
    /// Array of `ProductId` for products that have been purchased. Each purchased non-consumable or subscription
    /// product will appear exactly once. Consumable products can appear more than once.
    ///
    /// This array is primarily used to trigger updates in the UI. It is not persisted but re-built as required
    /// whenever a purchase successfully completes, or when a call is made to `isPurchased(product:)`.
    ///
    /// - Call `isPurchased(product:)` to see if any type of product has been purchased and validated against the receipt.
    /// - Call `StoreHelper.count(for:)` to see how many times a consumable product has been purchased.
    @Published public private(set) var purchasedProducts = [ProductId]()
    
    /// List of purchased product ids. This list is used as a cache and when the App Store in unavailable. Products of
    /// all types are added to this list. Each `ProductId` can appear exactly once.
    public private(set) var purchasedProductsFallback = [ProductId]()
    
    /// A non-persisted cache of transactions used as a fallback.
    ///
    /// In Xcode StoreKit Testing and Sandbox Testing subscription renewal transactions that happen when the app's not running
    /// are NEVER picked up by StoreKit2. That is, the transactions don't appear in `StoreKit.Transaction.all` or
    /// `Transaction.currentEntitlement(for:)`. This seems to have been a known issue since the release of StoreKit2 and can lead
    /// to the situation where a user has paid to renew their subscription but StoreKit2 has no knowledge of it.
    ///
    /// **Note that production builds using the live App Store DO NOT appear to suffer from this issue**.
    ///
    /// As a workaround, we maintain `transactionUpdateCache` to keep track of subscription renewals that happen when the app's
    /// not running.
    public private(set) var transactionUpdateCache = [TransactionUpdate]()
        
    /// `OrderedSet` of `ProductId` that have been read from the Product.plist configuration file. The order in which
    /// product ids are defined in the property list file is maintained in the set.
    public private(set) var productIds: OrderedSet<ProductId>?
    
    /// Set to true if we successfully retrieve a list of available products from the App Store.
    public private(set) var isAppStoreAvailable = false
    
    /// Subscription-related helper methods.
    public var subscriptionHelper: SubscriptionHelper!
    
    /// True if StoreHelper has been initialized correctly by calling start().
    public var hasStarted: Bool { transactionListener != nil && isAppStoreAvailable }

    /// Optional support for overriding dynamic font size.
    public var fontScaleFactor: Double {
        get { _fontScaleFactor ?? FontUtil.baseDynamicTypeSize(for: .large)}
        set { _fontScaleFactor = newValue }
    }
    
    /// Optional support for overriding handling of direct App Store purchases of in-app purchase promotions.
    /// See `AppStoreHelper.paymentQueue(_:shouldAddStorePayment:for:)`.
    public var shouldAddStorePaymentHandler: ShouldAddStorePaymentHandler?
    
    /// Optional support for receiving transaction notifications. The following `StoreNotification` notifications
    /// are supported:
    /// - .purchaseSuccess               The purchase successfully completed
    /// - .purchaseFailure               The purchase failed
    /// - .purchaseCancelled             The user cancelled the purchase before it completed
    /// - .purchasePending               The purchase is pending (e.g. awaiting parental permission)
    /// - .transactionFailure            StoreKit failed to validate the transaction
    /// - .transactionReceived           The transaction was successfully validated by StoreKit
    /// - .transactionRevoked            The user's access to the product has been revoked by the App Store (e.g. a refund, etc.)
    /// - .transactionExpired            The user's subscription has expired
    /// - .transactionUpgraded           The transaction has been superceeded by an active, higher-value subscription
    /// - .transactionSuccess            The transaction completed successfully
    ///
    /// Example usage:
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
    ///                     // Optional custom handling of transaction notifications
    ///                     storeHelper.transactionNotification = { notification, productId, transactionId in
    ///                         if notification == .purchaseSuccess {
    ///                             print("Purchase success for \(productId)")
    ///                         }
    ///                     }
    ///                 }
    ///         }
    ///     }
    /// }
    /// ```
    public var transactionNotification: TransactionNotification?
    
    /// Set to true if you want StoreHelper to use the cache of purchased products, rather than performing a full
    /// transaction check and verification. If true, the cache will always be used for non-consumables, but not
    /// for consumables and subscriptions unless there's a problem accessing the App Store.
    public var doUsePurchasedProductsFallbackCache = true
    
    /// Set to true if we're currently waiting for a refreshed list of localized products from the App Store.
    public private(set) var isRefreshingProducts = false
    
    /// Optional dictionary of configuration values that may be used to override StoreHelper defaults.
    /// Add a property list file to your project to override StoreHelper defaults.
    /// See `https://github.com/russell-archer/StoreHelperDemo` Configuration.plist for an example.
    public private(set) var configurationOverride: [String : AnyObject]?
    
    // MARK: - Public helper properties
    
    public var consumableProducts:            [Product]?   { products?.filter { $0.type == .consumable }}
    public var nonConsumableProducts:         [Product]?   { products?.filter { $0.type == .nonConsumable }}
    public var subscriptionProducts:          [Product]?   { products?.filter { $0.type == .autoRenewable }}
    public var nonSubscriptionProducts:       [Product]?   { products?.filter { $0.type == .nonRenewable }}
    public var consumableProductIds:          [ProductId]? { products?.filter { $0.type == .consumable }.map { $0.id }}
    public var nonConsumableProductIds:       [ProductId]? { products?.filter { $0.type == .nonConsumable }.map { $0.id }}
    public var subscriptionProductIds:        [ProductId]? { products?.filter { $0.type == .autoRenewable }.map { $0.id }}
    public var nonSubscriptionProductIds:     [ProductId]? { products?.filter { $0.type == .nonRenewable }.map { $0.id }}
    public var hasProducts:                   Bool         { products?.count ?? 0 > 0 ? true : false }
    public var hasConsumableProducts:         Bool         { consumableProducts?.count ?? 0 > 0 ? true : false }
    public var hasNonConsumableProducts:      Bool         { nonConsumableProducts?.count ?? 0 > 0 ? true : false }
    public var hasSubscriptionProducts:       Bool         { subscriptionProducts?.count ?? 0 > 0 ? true : false }
    public var hasNonSubscriptionProducts:    Bool         { nonSubscriptionProducts?.count ?? 0 > 0 ? true : false }
    public var hasConsumableProductIds:       Bool         { consumableProductIds?.count ?? 0 > 0 ? true : false }
    public var hasNonConsumableProductIds:    Bool         { nonConsumableProductIds?.count ?? 0 > 0 ? true : false }
    public var hasSubscriptionProductIds:     Bool         { subscriptionProductIds?.count ?? 0 > 0 ? true : false }
    public var hasNonSubscriptionProductIds:  Bool         { nonSubscriptionProducts?.count ?? 0 > 0 ? true : false }

    // MARK: - Private properties
    
    /// Handle for App Store transactions.
    private var transactionListener: Task<Void, Error>? = nil
    
    /// The current internal state of StoreHelper. If `purchaseState == inProgress` then an attempt to start
    /// a new purchase will result in a `purchaseInProgressException` being thrown by `purchase(_:)`.
    private var purchaseState: PurchaseState = .unknown
    
    /// Support for App Store IAP promotions and StoreKit1. Only used for purchase of IAPs direct from the App Store.
    private var appStoreHelper: AppStoreHelper?
    
    /// Support for overriding dynamic font scale.
    private var _fontScaleFactor: Double? = nil
    
    /// A non-persisted list of products that have had their purchase status checked against the App Store receipt.
    /// If a product is not in the `purchasedProductsFallback` cache we need to know if this is because it is
    /// unpurchased, or becuase the cache is in an invalid state because the app is newly installed, etc.
    /// If a `ProductId` is contained in the `transactionCheck` collection then we know we can safely use the
    /// `purchasedProductsFallback` cache to check it's purchased status.
    private var transactionCheck = [ProductId]()
    
    /// Used to read the Products.plist configuration file for products and subscriptions
    private var storeConfiguration = StoreConfiguration()
    
    // MARK: - Initialization
    
    /// StoreHelper enables support for working with in-app purchases and StoreKit2 using the async/await pattern.
    /// This initializer will start support for direct purchases from the app store (IAP promotions) and read the
    /// Products.plist configuration file to get a list of `ProductId` that defines the set of products we'll request
    /// from the App Store. Your app must call `StoreHelper.start()` as soon as possible after StoreHelper has
    /// been initialized.
    public init() {
        
        // Add a helper for StoreKit1-based direct purchases from the app store (IAP promotions)
        appStoreHelper = AppStoreHelper(storeHelper: self)
        
        // Initialize our subscription helper
        subscriptionHelper = SubscriptionHelper(storeHelper: self)
        
        // Read our list of product ids
        productIds = storeConfiguration.readConfigFile()
        
        // Read the hosts Configuration.plist file that overrides our default values
        configurationOverride = readConfigurationOverride()
        
        // Get the fallback list of purchased products in case the App Store's not available
        purchasedProductsFallback = readPurchasedProductsFallbackList()
    }
    
    deinit { transactionListener?.cancel() }
    
    // MARK: - Public methods
    
    /// Call this method as soon as possible after your app starts and StoreHelper has been initialized.
    /// Failure to call` start()` or `startAsync()` may result in transactions being missed.
    /// This method starts listening for App Store transactions and requests localized product info from the App Store.
    @MainActor public func start() {
        guard !hasStarted else { return }

        // Listen for App Store transactions
        transactionListener = handleTransactions()

        // Get localized product info from the App Store
        refreshProductsFromAppStore()
    }
    
    /// Call this method as soon as possible after your app starts and StoreHelper has been initialized.
    /// Failure to call` start()` or `startAsync()` may result in transactions being missed.
    /// This method starts listening for App Store transactions and requests localized product info from the App Store.
    @MainActor public func startAsync() async {
        guard !hasStarted else { return }
        
        // Listen for App Store transactions
        transactionListener = handleTransactions()
        
        // Get localized product info from the App Store
        guard let productIds else { return }
        products = await requestProductsFromAppStore(productIds: productIds)
        
        StoreLog.event(.requestPurchaseStatusStarted)
        guard let products else {
            StoreLog.event(.requestPurchaseStatusFailure)
            return
        }
        
        for product in products { let _ = try? await isPurchased(productId: product.id) }
        StoreLog.event(.requestPurchaseStatusSucess)
    }
    
    /// Request refreshed localized product info from the App Store. In general, use this method
    /// in preference to `requestProductsFromAppStore(productIds:)` as you don't need to supply
    /// an ordered set of App Store-defined product ids.
    /// This method runs on the main thread because it may result in updates to the UI.
    @MainActor public func refreshProductsFromAppStore(rebuildCaches: Bool = false) {
        Task.init {
            guard let productIds else { return }
            
            if rebuildCaches {
                purchasedProducts.removeAll()
                transactionCheck.removeAll()
            }
                      
            products = await requestProductsFromAppStore(productIds: productIds)
            
            StoreLog.event(.requestPurchaseStatusStarted)
            guard let products else {
                StoreLog.event(.requestPurchaseStatusFailure)
                return
            }
            
            for product in products { let _ = try? await isPurchased(productId: product.id) }
            StoreLog.event(.requestPurchaseStatusSucess)
        }
    }
    
    /// Request localized product info from the App Store for a set of ProductId.
    ///
    /// This method runs on the main thread because it may result in updates to the UI.
    /// - Parameter productIds: The product ids that you want localized information for.
    /// - Returns: Returns an array of `Product`, or nil if no product information is returned by the App Store.
    @MainActor public func requestProductsFromAppStore(productIds: OrderedSet<ProductId>) async -> [Product]? {
        defer { isRefreshingProducts = false }
        
        StoreLog.event(.requestProductsStarted)
        isAppStoreAvailable = false
        isRefreshingProducts = true
        
        guard let localizedProducts = try? await Product.products(for: productIds) else {
            StoreLog.event(.requestProductsFailure)
            return nil
        }
        
        isAppStoreAvailable = true
        StoreLog.event(.requestProductsSuccess)
        return localizedProducts
    }
    
    /// Requests the most recent transaction for a product from the App Store and determines if it has been previously purchased.
    /// Non-consumable products may have their purchase status checked against the `purchasedProductsFallback` cache.
    /// May throw an exception of type `StoreException.transactionVerificationFailed` or `StoreException.productTypeNotSupported`.
    /// - Parameter productId: The `ProductId` of the product.
    /// - Returns: Returns true if the product has been purchased, false otherwise.
    @MainActor public func isPurchased(productId: ProductId) async throws -> Bool {
        var purchased = false
        
        // For non-consumables, it's always safe to use the cache of purchased products as they're added to the cache
        // when purchased and will be removed (see handleTransactions()) if access to the product is revoked by the App Store.
        // We only use the cache if a product has previously had its purchase status checked against the App Store receipt.
        if isNonConsumable(productId: productId), doUsePurchasedProductsFallbackCache, transactionCheck.contains(productId) {
            purchased = purchasedProductsFallback.contains(productId)
            StoreLog.event(purchased ? .productIsPurchasedFromCache : .productIsNotPurchased, productId: productId)
            updatePurchasedProducts(for: productId, purchased: purchased, updateFallbackList: false, updateTransactionCheck: false)
            return purchased
        }
        
        // Make sure we're listening for transactions, the App Store is available, we have a list of localized products
        // and that we can create a `Product` from the `ProductId`. If not, we have to rely on the cache of purchased products
        guard hasStarted, isAppStoreAvailable, hasProducts, let product = product(from: productId) else {
            StoreLog.event(.appStoreNotAvailable)
            purchased = purchasedProductsFallback.contains(productId)
            StoreLog.event(purchased ? .productIsPurchasedFromCache : .productIsNotPurchased, productId: productId)
            return purchased
        }

        // Is this a consumable product? We need to treat consumables differently because their transactions are NOT stored in the receipt
        if product.type == .consumable {
            purchased = KeychainHelper.count(for: productId) > 0
            StoreLog.event(purchased ? .productIsPurchased : .productIsNotPurchased, productId: productId)
            updatePurchasedProducts(for: productId, purchased: purchased)
            return purchased
        }

        // Perform a full transaction check and verification
        guard let currentEntitlement = await Transaction.currentEntitlement(for: productId) else {
            // There's no transaction for the product, so it hasn't been purchased. However, the App Store does sometimes return nil,
            // even if the user is entitled to access the product. For this reason we don't update the fallback cache and transaction
            // check list for a negative response
            
            // If this is a subscription product, before giving up see if it was renewed while the app was offline and the
            // transaction hasn't yet been sent to us
            if product.type == .autoRenewable, let mruStatus = subscriptionHelper.mostRecentSubscriptionUpdate(for: productId) {
                if mruStatus == .purchased || mruStatus == .subscribed || mruStatus == .inGracePeriod || mruStatus == .inBillingRetryPeriod {
                    StoreLog.event(.productIsPurchasedFromCache, productId: productId)
                    return true
                }
            }
            
            StoreLog.event(.productIsNotPurchasedNoEntitlement, productId: productId)
            return false
        }

        // See if the transaction passed StoreKit's automatic verification
        let result = checkVerificationResult(result: currentEntitlement)
        if !result.verified {
            StoreLog.transaction(.transactionValidationFailure, productId: result.transaction.productID, transactionId: String(result.transaction.id))
            throw StoreException.transactionVerificationFailed
        }

        // See if the App Store has revoked the user's access to the product (e.g. because of a refund).
        // If this transaction represents a subscription, see if the user upgraded to a higher-level subscription.
        switch product.type {
            case .autoRenewable: purchased = result.transaction.revocationDate == nil && !result.transaction.isUpgraded
            case .nonConsumable: purchased = result.transaction.revocationDate == nil
            default:             throw StoreException.productTypeNotSupported
        }
        
        StoreLog.event(purchased ? .productIsPurchasedFromTransaction : .productIsNotPurchased, productId: productId, transactionId: String(result.transaction.id))
        updatePurchasedProducts(for: productId, purchased: purchased)
        return purchased
    }
    
    /// Requests the most recent transaction for a product from the App Store and determines if it has been previously purchased.
    ///
    /// May throw an exception of type `StoreException.transactionVerificationFailed`.
    /// - Parameter productId: The `ProductId` of the product.
    /// - Returns: Returns true if the product has been purchased, false otherwise.
    @MainActor public func isPurchased(product: Product) async throws -> Bool { try await isPurchased(productId: product.id) }
    
    /// Determines if a product is currently subscribed to.
    ///
    /// May throw an exception of type `StoreException.transactionVerificationFailed`.
    /// - Parameter product: The `Product` representing the subscription product.
    /// - Returns: Returns true if the product is currently subscribed to, false otherwise.
    @MainActor public func isSubscribed(product: Product) async throws -> Bool { try await isPurchased(productId: product.id) }
    
    /// Determines if the product is currently subscribed to.
    ///
    /// May throw an exception of type `StoreException.transactionVerificationFailed`.
    /// - Parameter productId: The `ProductId` of the subscription product.
    /// - Returns: Returns true if the product is currently subscribed to, false otherwise.
    @MainActor public func isSubscribed(productId: ProductId) async throws -> Bool { try await isPurchased(productId: productId) }
    
    /// Returns true if the product uniquely identified by `productId` is a subscription.
    /// - Parameter productId: `ProductId` that uniquely identifies a product available in the App Store.
    /// - Returns: Returns true if the product uniquely identified by `productId` is a subscription, false otherwise.
    public func isSubscription(productId: ProductId) -> Bool { subscriptionProductIds == nil ? false : subscriptionProductIds!.contains { pid in pid == productId }}
    
    /// Returns true if the product is a subscription.
    /// - Parameter product: `Product` that uniquely identifies a product available in the App Store.
    /// - Returns: Returns true if the product is a subscription, false otherwise.
    public func isSubscription(product: Product) -> Bool { return isSubscription(productId: product.id) }
    
    /// Returns true if the product uniquely identified by `productId` is a consumable.
    /// - Parameter productId: `ProductId` that uniquely identifies a product available in the App Store.
    /// - Returns: Returns true if the product uniquely identified by `productId` is a consumable, false otherwise.
    public func isConsumable(productId: ProductId) -> Bool { consumableProductIds == nil ? false : consumableProductIds!.contains { pid in pid == productId }}
    
    /// Returns true if the product is a consumable.
    /// - Parameter product: `Product` that uniquely identifies a product available in the App Store.
    /// - Returns: Returns true if the product is a consumable, false otherwise.
    public func isConsumable(product: Product) -> Bool { return isConsumable(productId: product.id) }
    
    /// Returns true if the product uniquely identified by `productId` is a non-consumable.
    /// - Parameter productId: `ProductId` that uniquely identifies a product available in the App Store.
    /// - Returns: Returns true if the product uniquely identified by `productId` is a non-consumable, false otherwise.
    public func isNonConsumable(productId: ProductId) -> Bool { nonConsumableProductIds == nil ? false : nonConsumableProductIds!.contains { pid in pid == productId }}
    
    /// Returns true if the product is a non-consumable.
    /// - Parameter product: `Product` that uniquely identifies a product available in the App Store.
    /// - Returns: Returns true if the product is a non-consumable, false otherwise.
    public func isNonConsumable(product: Product) -> Bool { return isNonConsumable(productId: product.id) }

    /// Uses StoreKit's `Transaction.currentEntitlements` property to iterate over the sequence of `VerificationResult<Transaction>`
    /// representing all transactions for products the user is currently entitled to. That is, all currently-subscribed
    /// transactions and all purchased (and not refunded) non-consumables. Note that transactions for consumables are NOT
    /// in the receipt.
    /// - Returns: A verified `Set<ProductId>` for all products the user is entitled to have access to. The set will be empty if the
    /// user has not purchased anything previously.
    @MainActor public func currentEntitlements() async -> Set<ProductId> {
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
    /// - Parameter options: Purchase options. See Product.PurchaseOption.
    /// - Returns: Returns a tuple consisting of a transaction object that represents the purchase and a `PurchaseState`
    /// describing the state of the purchase.
    @MainActor public func purchase(_ product: Product, options: Set<Product.PurchaseOption> = []) async throws -> (transaction: Transaction?, purchaseState: PurchaseState)  {
        
        guard hasStarted else {
            StoreLog.event("Please call StoreHelper.start() before use.")
            return (nil, .notStarted)
        }
        
        guard AppStore.canMakePayments else {
            StoreLog.event(.purchaseUserCannotMakePayments)
            return (nil, .userCannotMakePayments)
        }
        
        guard purchaseState != .inProgress else {
            StoreLog.exception(.purchaseInProgressException, productId: product.id)
            throw StoreException.purchaseInProgressException
        }
        
        // Start a purchase transaction
        purchaseState = .inProgress
        StoreLog.event(.purchaseInProgress, productId: product.id)

        let result: Product.PurchaseResult
        do {
            result = try await product.purchase(options: options)
        } catch {
            purchaseState = .failed
            StoreLog.event(.purchaseFailure, productId: product.id)
            if let handler = transactionNotification { handler(.purchaseFailure, product.id, "0") }
            throw StoreException.purchaseException(.init(error: error))
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
                let checkResult = checkVerificationResult(result: verificationResult)
                if !checkResult.verified {
                    purchaseState = .failedVerification
                    StoreLog.transaction(.transactionValidationFailure, productId: checkResult.transaction.productID, transactionId: String(checkResult.transaction.id))
                    if let handler = transactionNotification { handler(.transactionValidationFailure, product.id, String(checkResult.transaction.id)) }
                    throw StoreException.transactionVerificationFailed
                }

                let validatedTransaction = checkResult.transaction  // The transaction was successfully validated
                await validatedTransaction.finish()  // Tell the App Store we delivered the purchased content to the user

                if validatedTransaction.productType == .consumable {
                    // We need to treat consumables differently because their transactions are NOT stored in the receipt.
                    if KeychainHelper.purchase(validatedTransaction.productID) { updatePurchasedProducts(for: validatedTransaction.productID, purchased: true) }
                    else { StoreLog.event(.consumableKeychainError) }
                } else {
                    // For non-consumables and subscriptions
                    updatePurchasedProducts(for: validatedTransaction.productID, purchased: true)
                }

                // Let the caller know the purchase succeeded and that the user should be given access to the product
                purchaseState = .purchased
                StoreLog.event(.purchaseSuccess, productId: product.id, transactionId: String(validatedTransaction.id))
                if let handler = transactionNotification { handler(.purchaseSuccess, product.id, String(validatedTransaction.id)) }

                return (transaction: validatedTransaction, purchaseState: .purchased)

            case .userCancelled:
                purchaseState = .cancelled
                StoreLog.event(.purchaseCancelled, productId: product.id)
                if let handler = transactionNotification { handler(.purchaseCancelled, product.id, "0") }
                return (transaction: nil, .cancelled)

            case .pending:
                purchaseState = .pending
                StoreLog.event(.purchasePending, productId: product.id)
                if let handler = transactionNotification { handler(.purchasePending, product.id, "0") }
                return (transaction: nil, .pending)

            default:
                purchaseState = .unknown
                StoreLog.event(.purchaseFailure, productId: product.id)
                if let handler = transactionNotification { handler(.purchaseFailure, product.id, "0") }
                return (transaction: nil, .unknown)
        }
    }
    
    /// Should be called only when a purchase is handled by the StoreKit1-based AppHelper.
    /// This will be as a result of a user dirctly purchasing in IAP in the App Store ("IAP Promotion"), rather than in our app.
    /// It will also happen when a subscription-related transaction (renewal,cancellation, etc.) happens when the app is not running.
    /// - Parameter product: The ProductId of the purchased product.
    @MainActor public func productPurchased(_ productId: ProductId, transactionId: String)  {
        updatePurchasedProducts(for: productId, purchased: true)
        purchaseState = .purchased
        StoreLog.event(.purchaseSuccess, productId: productId, transactionId: transactionId)
    }
    
    /// The `Product` associated with a `ProductId`.
    /// - Parameter productId: `ProductId`.
    /// - Returns: Returns the `Product` associated with a `ProductId`.
    public func product(from productId: ProductId) -> Product? {
        
        guard let p = products else { return nil }
        
        let matchingProduct = p.filter { product in
            product.id == productId
        }
        
        guard matchingProduct.count == 1 else { return nil }
        return matchingProduct.first
    }
    
    /// Information on a non-consumable product.
    /// - Parameter productId: The `ProductId` of the product.
    /// - Returns: Information on a non-consumable product.
    /// If the product is not non-consumable nil is returned.
    @MainActor public func purchaseInfo(for productId: ProductId) async -> PurchaseInfo? {
        
        guard let p = product(from: productId) else { return nil }
        return await purchaseInfo(for: p)
    }
    
    /// Transaction information for a non-consumable product.
    /// - Parameter product: The `Product` you want information on.
    /// - Returns: Transaction information on a non-consumable product.
    /// If the product is not non-consumable nil is returned.
    @MainActor public func purchaseInfo(for product: Product) async -> PurchaseInfo? {
        
        guard product.type == .nonConsumable else { return nil }
        
        var purchaseInfo = PurchaseInfo(product: product)
        guard let unverifiedTransaction = await product.latestTransaction else { return nil }
        
        let transactionResult = checkVerificationResult(result: unverifiedTransaction)
        guard transactionResult.verified else { return nil }
        
        purchaseInfo.latestVerifiedTransaction = transactionResult.transaction
        return purchaseInfo
    }
    
    /// Check if StoreKit was able to automatically verify a transaction by inspecting the verification result.
    ///
    /// - Parameter result: The transaction VerificationResult to check.
    /// - Returns: Returns an `UnwrappedVerificationResult<T>` where `verified` is true if the transaction was
    /// successfully verified by StoreKit. When `verified` is false `verificationError` will be non-nil.
    @MainActor public func checkVerificationResult<T>(result: VerificationResult<T>) -> UnwrappedVerificationResult<T> {
        
        switch result {
            case .unverified(let unverifiedTransaction, let error):
                // StoreKit failed to automatically validate the transaction
                return UnwrappedVerificationResult(transaction: unverifiedTransaction, verified: false, verificationError: error)
                
            case .verified(let verifiedTransaction):
                // StoreKit successfully automatically validated the transaction
                return UnwrappedVerificationResult(transaction: verifiedTransaction, verified: true, verificationError: nil)
        }
    }
    
    /// Gets the unique transaction id for the product's most recent transaction.
    /// - Parameter productId: The product's unique App Store id.
    /// - Returns: Returns the unique transaction id for the product's most recent transaction, or nil if the product's never been purchased.
    @MainActor public func mostRecentTransactionId(for productId: ProductId) async -> UInt64? {
        if let result = await Transaction.latest(for: productId) {
            let verificationResult = checkVerificationResult(result: result)
            if verificationResult.verified { return verificationResult.transaction.id }
        }
        
        return nil
    }
    
    /// Gets the most recent transaction for the product.
    /// - Parameter productId: The product's unique App Store id.
    /// - Returns: Returns the most recent transaction for the product, or nil if the product's never been purchased.
    @MainActor public func mostRecentTransaction(for productId: ProductId) async -> Transaction? {
        if let result = await Transaction.latest(for: productId) {
            let verificationResult = checkVerificationResult(result: result)
            if verificationResult.verified { return verificationResult.transaction }
        }
        
        return nil
    }
    
    /// Handles notifications from the StoreKit1-related `AppStoreHelper` related to subscription transactions that happen
    /// when the app's not running. It also handles direct App Store purchases made outside of the app.
    ///
    /// Note that in Xcode StoreKit Testing and Sandbox Testing subscription renewal or cancellation transactions that
    /// happen when the app's not running are NEVER picked up by StoreKit2. That is, the transactions don't appear
    /// in `StoreKit.Transaction.all` or `Transaction.currentEntitlement(for:)`. This seems to have been a known issue
    /// since the release of StoreKit2 and can lead to the situation where a user has paid to renew their subscription
    /// but StoreKit2 has no knowledge of it.
    ///
    /// As a workaround, `StoreHelper` maintains a `transactionUpdateCache` that keeps track of subscription renewals
    /// that happen when the app's not running. See `AppStoreHelper.paymentQueue(_:updatedTransactions:)`.
    ///
    /// **Note that production builds using the live App Store DO NOT appear to suffer from this issue**.
    ///
    /// - Parameters:
    ///   - productId: The `ProductId` that the transaction relates to.
    ///   - date: The date and time of the transaction update.
    ///   - status: The new status (subscribed, expired, etc.) of the sunscription.
    @MainActor public func handleStoreKit1Transactions(productId: ProductId, date: Date, status: TransactionStatus, transaction: SKPaymentTransaction) async {
        var isPurchased = false
        var transactionStatus = TransactionStatus.unknown
        let transactionId = transaction.transactionIdentifier ?? "-1"
        
        switch status {
            case .purchased:
                StoreLog.transaction(.transactionSuccess, productId: productId, transactionId: transactionId)
                isPurchased = true
                transactionStatus = .purchased
                
            case .subscribed:
                StoreLog.transaction(.transactionSubscribed, productId: productId, transactionId: transactionId)
                isPurchased = true
                transactionStatus = .subscribed
                
            case .inGracePeriod:
                StoreLog.transaction(.transactionInGracePeriod, productId: productId, transactionId: transactionId)
                isPurchased = true
                transactionStatus = .inGracePeriod
                
            case .inBillingRetryPeriod:
                StoreLog.transaction(.transactionInGracePeriod, productId: productId, transactionId: transactionId)
                isPurchased = true
                transactionStatus = .inBillingRetryPeriod
                
            case .revoked:
                StoreLog.transaction(.transactionRevoked, productId: productId, transactionId: transactionId)
                transactionStatus = .revoked
                
            case .expired:
                StoreLog.transaction(.transactionExpired, productId: productId, transactionId: transactionId)
                transactionStatus = .expired
                
            default: return
        }
        
        updatePurchasedProducts(for: productId, purchased: isPurchased)
        
        if transactionUpdateCache.filter({ t in t.transactionId == transactionId && t.status == transactionStatus }).count == 0 {
            transactionUpdateCache.append(TransactionUpdate(productId: productId, date: Date(), status: transactionStatus, transactionId: transactionId))
        }
    }
    
    // MARK: - Internal methods
    
    /// Update our list of purchased product identifiers (see `purchasedProducts`).
    ///
    /// This method runs on the main thread because it will result in updates to the UI.
    /// - Parameter transaction: The `Transaction` that will result in changes to `purchasedProducts`.
    @MainActor internal func updatePurchasedIdentifiers(_ transaction: Transaction) {
        var purchased = true
        
        // Has the user's access to the product been revoked by the App Store?
        if transaction.revocationDate != nil { purchased = false }
        
        // Has the user's subscription has expired
        if let expirationDate = transaction.expirationDate, expirationDate < Date() { purchased = false }
        
        // The transaction has been superceeded by an active, higher-value subscription
        if transaction.isUpgraded { purchased = false }

        // Add or remove the ProductId to/from the list of `purchasedProducts`
        updatePurchasedIdentifiers(transaction.productID, purchased: purchased)
    }
    
    /// Update our list of purchased product identifiers (see `purchasedProducts`).
    /// - Parameters:
    ///   - productId: The `ProductId` to insert/remove.
    ///   - insert: If true the `ProductId` is purchased.
    @MainActor internal func updatePurchasedIdentifiers(_ productId: ProductId, purchased: Bool) {
        guard let product = product(from: productId) else { return }
        
        if purchased {
            if product.type == .consumable {
                let keychainCount = KeychainHelper.count(for: productId)
                let purchasedProductsCount = purchasedProducts.filter({ $0 == productId }).count
                if keychainCount == purchasedProductsCount || purchasedProductsCount > keychainCount { return } else {
                    while purchasedProducts.count < KeychainHelper.count(for: productId) {
                        purchasedProducts.append(productId)  // Consumables can appear more than once in this list
                    }
                }

            } else {
                if !purchasedProducts.contains(productId) { purchasedProducts.append(productId) }
            }
            
        } else {
            if product.type == .consumable {
                let keychainCount = KeychainHelper.count(for: productId)
                let purchasedProductsCount = purchasedProducts.filter({ $0 == productId }).count
                if keychainCount == purchasedProductsCount || purchasedProductsCount < keychainCount { return } else {
                    while purchasedProducts.count > KeychainHelper.count(for: productId) {
                        if let index = purchasedProducts.firstIndex(where: { $0 == productId}) { purchasedProducts.remove(at: index) }
                    }
                }
            } else {
                if let index = purchasedProducts.firstIndex(where: { $0 == productId}) { purchasedProducts.remove(at: index) }
            }
        }
    }
    
    /// Updates and persists our fallback cache of purchased products (`purchasedProductsFallback`). Also makes sure our set of purchase
    /// pids (`purchasedProducts`, used to trigger UI updates) is in-sync with the fallback cache. We also update UserDefaults in the
    /// container shared between ourselves and other members of the group.com.{developer}.{appname} AppGroup, if any.
    /// - Parameters:
    ///   - productId: The `ProductId` to update.
    ///   - purchased: True if the product is purchased,false otherwise.
    ///   - updateFallbackList: If true, the fallback cache of purchased products (`purchasedProductsFallback`) is updated.
    ///   - updateTransactionCheck: If true, the fallback cache check list has the `ProductId` added to it.
    @MainActor internal func updatePurchasedProducts(for productId: ProductId,
                                                     purchased: Bool,
                                                     updateFallbackList: Bool = true,
                                                     updateTransactionCheck: Bool = true) {
        
        // Update the cache check collection so we know which products have/have not had their purchase status checked against the receipt
        if updateTransactionCheck, !transactionCheck.contains(productId) { transactionCheck.append(productId) }
        
        // Update and persist our fallback cache of purchased products (`purchasedProductsFallback`)
        if updateFallbackList { updatePurchasedProductsFallbackList(for: productId, purchased: purchased) }

        // Update our set of purchased (`purchasedProducts`) productIds that are used to trigger UI updates
        updatePurchasedIdentifiers(productId, purchased: purchased)
        
        // Update UserDefaults in the container shared between ourselves and other members of the group.com.{developer}.{appname} AppGroup.
        // Currently this is done so that widgets can tell what IAPs have been purchased. Note that widgets can't use StoreHelper directly
        // because the they don't purchase anything and are not considered to be part of the app that did the purchasing as far as
        // StoreKit is concerned.
        AppGroupSupport.syncPurchase(productId: productId, purchased: purchased)
        
        // Persist the fallback list of purchased products
        savePurchasedProductsFallbackList()
    }
    
    /// Updates and persists our fallback cache of purchased products (`purchasedProductsFallback`). Also makes sure our set of purchase
    /// pids (`purchasedProducts`, used to trigger UI updates) is in-sync with the fallback cache. We also update UserDefaults in the
    /// container shared between ourselves and other members of the group.com.{developer}.{appname} AppGroup, if any.
    /// - Parameters:
    ///   - transaction: The product's transaction object.
    ///   - purchased: True if the product is purchased,false otherwise.
    ///   - updateFallbackList: If true, the fallback cache of purchased products (`purchasedProductsFallback`) is updated.
    ///   - updateTransactionCheck: If true, the fallback cache check list has the `ProductId` added to it.
    @MainActor internal func updatePurchasedProducts(transaction: Transaction,
                                                     purchased: Bool,
                                                     updateFallbackList: Bool = true,
                                                     updateTransactionCheck: Bool = true) {

        updatePurchasedProducts(for: transaction.productID,
                                purchased: purchased,
                                updateFallbackList: updateFallbackList,
                                updateTransactionCheck: updateTransactionCheck)
    }
    
    // MARK: - Private methods
    
    /// This is an infinite async sequence (loop). It will continue waiting for transactions until it is explicitly
    /// canceled by calling the Task.cancel() method. See `transactionListener`.
    /// - Returns: Returns a task for the transaction handling loop task.
    @MainActor private func handleTransactions() -> Task<Void, Error> {
        
        return Task.detached { [self] in
            
            for await verificationResult in Transaction.updates {
                // See if StoreKit validated the transaction
                let checkResult = await self.checkVerificationResult(result: verificationResult)
                guard checkResult.verified else {
                    // StoreKit's attempts to validate the transaction failed
                    if let handler = transactionNotification { handler(.transactionFailure, checkResult.transaction.productID, String(checkResult.transaction.id)) }
                    StoreLog.transaction(.transactionFailure, productId: checkResult.transaction.productID, transactionId: String(checkResult.transaction.id))
                    return
                }
                
                // The transaction was validated by StoreKit
                let transaction = checkResult.transaction
                if let handler = transactionNotification { handler(.transactionReceived, transaction.productID, String(transaction.id)) }
                StoreLog.transaction(.transactionReceived, productId: transaction.productID, transactionId: String(transaction.id))
                    
                if transaction.revocationDate != nil {
                    // The user's access to the product has been revoked by the App Store (e.g. a refund, etc.)
                    // See transaction.revocationReason for more details if required
                    StoreLog.transaction(.transactionRevoked, productId: transaction.productID, transactionId: String(transaction.id))
                    await self.updatePurchasedProducts(for: transaction.productID, purchased: false)
                    if let handler = transactionNotification { handler(.transactionRevoked, transaction.productID, String(transaction.id)) }
                    return
                }
                
                if let expirationDate = transaction.expirationDate, expirationDate < Date() {
                    // The user's subscription has expired
                    StoreLog.transaction(.transactionExpired, productId: transaction.productID, transactionId: String(transaction.id))
                    await self.updatePurchasedProducts(for: transaction.productID, purchased: false)
                    if let handler = transactionNotification { handler(.transactionExpired, transaction.productID, String(transaction.id)) }
                    return
                }
                
                if transaction.isUpgraded {
                    // Transaction superceeded by an active, higher-value subscription
                    StoreLog.transaction(.transactionUpgraded, productId: transaction.productID, transactionId: String(transaction.id))
                    await self.updatePurchasedProducts(for: transaction.productID, purchased: true)
                    if let handler = transactionNotification { handler(.transactionUpgraded, transaction.productID, String(transaction.id)) }
                    return
                }
                    
                // Update the list of products the user has access to
                StoreLog.transaction(.transactionSuccess, productId: transaction.productID, transactionId: String(transaction.id))
                await self.updatePurchasedProducts(transaction: transaction, purchased: true)
                if let handler = transactionNotification { handler(.transactionSuccess, transaction.productID, String(transaction.id)) }
                await transaction.finish()
            }
        }
    }
    
    /// Read the property list provided by the host app that overrides StoreHelper default values.
    /// - Returns: Returns a dictionary of key-value pairs, or nil if the configuration plist file cannot be found.
    private func readConfigurationOverride() -> [String : AnyObject]? {
        let configurationOverride = PropertyFile.read(filename: StoreConstants.Configuration)
        guard configurationOverride != nil else {
            StoreLog.event(.configurationOverrideNotFound)  // This is not necessarily an error. Overriding our configuration is optional
            return nil
        }
        
        StoreLog.event(.configurationOverrideSuccess)
        return configurationOverride
    }
    
    /// Read the list of fallback purchased products from storage.
    /// - Returns: Returns the list of fallback product ids, or nil if none is available.
    private func readPurchasedProductsFallbackList() -> [ProductId] {
        if let collection = UserDefaults.standard.object(forKey: StoreConstants.PurchasedProductsFallbackKey) as? [ProductId] {
            return collection
        }
        
        return [ProductId]()
    }
    
    /// Saves the fallback collection of purchased product ids.
    private func savePurchasedProductsFallbackList() {
        UserDefaults.standard.set(purchasedProductsFallback, forKey: StoreConstants.PurchasedProductsFallbackKey)
    }
    
    /// Add a ProductId from the list of fallback purchased product ids. The list is then persisted to UserDefaults.
    /// - Parameter productId: The ProductId to add.
    private func addToPurchasedProductsFallbackList(productId: ProductId) {
        if purchasedProductsFallback.contains(productId) { return }
        purchasedProductsFallback.append(productId)
        savePurchasedProductsFallbackList()
    }
    
    /// Remove a ProductId from the list of fallback purchased product ids. The list is then persisted to UserDefaults.
    /// - Parameter productId: The ProductId to remove.
    private func removeFromPurchasedProductsFallbackList(productId: ProductId) {
        purchasedProductsFallback.removeAll(where: { $0 == productId })
        savePurchasedProductsFallbackList()
    }
    
    /// Add or removes the ProductId to/from the list of fallback purchased product ids. The list is then persisted to UserDefaults.
    /// - Parameters:
    ///   - productId: The ProductId to add or remove.
    ///   - purchased: true if the product was purchased, false otherwise.
    private func updatePurchasedProductsFallbackList(for productId: ProductId, purchased: Bool) {
        if purchased { addToPurchasedProductsFallbackList(productId: productId)}
        else { removeFromPurchasedProductsFallbackList(productId: productId)}
    }
}


