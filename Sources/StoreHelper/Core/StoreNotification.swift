//
//  StoreNotification.swift
//  StoreHelper
//
//  Created by Russell Archer on 16/06/2021.
//

import Foundation
import StoreKit

extension StoreKitError: Equatable {
    public static func == (lhs: StoreKitError, rhs: StoreKitError) -> Bool {
        switch (lhs, rhs) {
        case (.unknown, .unknown): return true
        case (.userCancelled, .userCancelled): return true
        case (.networkError, .networkError): return true
        case (.systemError, .systemError): return true
        case (.notAvailableInStorefront, .notAvailableInStorefront): return true
        case (.notEntitled, .notEntitled): return true
        default: return false
        }
    }
}

public enum UnderlyingError: Equatable {
    case purchase(Product.PurchaseError)
    case storeKit(StoreKitError)

    public init?(error: Error) {
        if let purchaseError = error as? Product.PurchaseError {
            self = .purchase(purchaseError)
        } else if let skError = error as? StoreKitError {
            self = .storeKit(skError)
        } else {
            return nil
        }
    }
}

/// StoreHelper exceptions
public enum StoreException: Error, Equatable {
    case purchaseException(UnderlyingError?)
    case purchaseInProgressException
    case transactionVerificationFailed
    case productTypeNotSupported
    
    public func shortDescription() -> String {
        switch self {
            case .purchaseException:             return "Exception. StoreKit throw an exception while processing a purchase"
            case .purchaseInProgressException:   return "Exception. You can't start another purchase yet, one is already in progress"
            case .transactionVerificationFailed: return "Exception. A transaction failed StoreKit's automatic verification"
            case .productTypeNotSupported:       return "Exception. Products of type nonRenewable are not supported"
        }
    }
}

/// Informational logging notifications issued by StoreHelper
public enum StoreNotification: Error, Equatable {
    
    case configurationNotFound
    case configurationEmpty
    case configurationSuccess
    case configurationFailure
    
    case configurationOverrideNotFound
    case configurationOverrideEmpty
    case configurationOverrideSuccess
    case configurationOverrideFailure
    
    case requestProductsStarted
    case requestProductsSuccess
    case requestProductsFailure
    
    case purchaseUserCannotMakePayments
    case purchaseAlreadyInProgress
    case purchaseInProgress
    case purchaseCancelled
    case purchasePending
    case purchaseSuccess
    case purchaseFailure
    
    case transactionReceived
    case transactionValidationSuccess
    case transactionValidationFailure
    case transactionFailure
    case transactionSuccess
    case transactionSubscribed
    case transactionRevoked
    case transactionRefundRequested
    case transactionRefundFailed
    case transactionExpired
    case transactionUpgraded
    case transactionInGracePeriod
    
    case consumableSavedInKeychain
    case consumableKeychainError
    
    case requestPurchaseStatusStarted
    case requestPurchaseStatusSucess
    case requestPurchaseStatusFailure
    
    case productIsPurchasedFromTransaction
    case productIsPurchasedFromCache
    case productIsPurchased
    case productIsNotPurchased
    case productIsNotPurchasedNoEntitlement

    case appStoreNotAvailable
    case purchasedProductsCache
    
    /// A short description of the notification.
    /// - Returns: Returns a short description of the notification.
    public func shortDescription() -> String {
        switch self {
                
            case .configurationNotFound:                return "Configuration file not found in the main bundle"
            case .configurationEmpty:                   return "Configuration file does not contain any product definitions"
            case .configurationSuccess:                 return "Configuration success"
            case .configurationFailure:                 return "Configuration failure"
                        
            case .configurationOverrideNotFound:        return "Configuration override file not found in the main bundle"
            case .configurationOverrideEmpty:           return "Configuration override file does not contain any key-value pairs"
            case .configurationOverrideSuccess:         return "Configuration override success"
            case .configurationOverrideFailure:         return "Configuration override failure"
                        
            case .requestProductsStarted:               return "Request products from the App Store started"
            case .requestProductsSuccess:               return "Request products from the App Store success"
            case .requestProductsFailure:               return "Request products from the App Store failure"
                        
            case .purchaseUserCannotMakePayments:       return "Purchase failed because the user cannot make payments"
            case .purchaseAlreadyInProgress:            return "Purchase already in progress"
            case .purchaseInProgress:                   return "Purchase in progress"
            case .purchasePending:                      return "Purchase in progress. Awaiting authorization"
            case .purchaseCancelled:                    return "Purchase cancelled"
            case .purchaseSuccess:                      return "Purchase success"
            case .purchaseFailure:                      return "Purchase failure"
                        
            case .transactionReceived:                  return "Transaction received"
            case .transactionValidationSuccess:         return "Transaction validation success"
            case .transactionValidationFailure:         return "Transaction validation failure"
            case .transactionFailure:                   return "Transaction failure"
            case .transactionSuccess:                   return "Transaction success"
            case .transactionSubscribed:                return "Transaction for subscription was a success"
            case .transactionRevoked:                   return "Transaction was revoked (refunded) by the App Store"
            case .transactionRefundRequested:           return "Transaction refund successfully requested"
            case .transactionRefundFailed:              return "Transaction refund request failed"
            case .transactionExpired:                   return "Transaction for subscription has expired"
            case .transactionUpgraded:                  return "Transaction superceeded by higher-value subscription"
            case .transactionInGracePeriod:             return "Transaction for subscription is in a grace period"
                        
            case .consumableSavedInKeychain:            return "Consumable purchase successfully saved to the keychain"
            case .consumableKeychainError:              return "Keychain error"
                        
            case .requestPurchaseStatusStarted:         return "Request all products purchase status started"
            case .requestPurchaseStatusSucess:          return "Request all products purchase status success"
            case .requestPurchaseStatusFailure:         return "Request all products purchase status failure"
                
            case .productIsPurchasedFromTransaction:    return "Product purchased (via transaction)"
            case .productIsPurchasedFromCache:          return "Product purchased (via cache)"
            case .productIsPurchased:                   return "Product purchased"
            case .productIsNotPurchased:                return "Product not purchased"
            case .productIsNotPurchasedNoEntitlement:   return "Product not purchased (no entitlement)"

            case .appStoreNotAvailable:                 return "App Store not available"
            case .purchasedProductsCache:               return "Purchased products fallback cache valid"
        }
    }
    
    /// Returns `true` if a notification is related to a StoreHelper.isPurchased() check.
    /// - Returns: Returns `true` if a notification is related to a StoreHelper.isPurchased() check.
    public func isNotificationPurchaseState() -> Bool {
        switch self {
            case .productIsPurchasedFromTransaction:    return true
            case .productIsPurchasedFromCache:          return true
            case .productIsPurchased:                   return true
            case .productIsNotPurchased:                return true
            case .productIsNotPurchasedNoEntitlement:   return true
                
            default: return false
        }
    }
}
