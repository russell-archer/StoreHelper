//
//  StoreNotification.swift
//  StoreHelper
//
//  Created by Russell Archer on 16/06/2021.
//

import Foundation

/// StoreHelper exceptions
public enum StoreException: Error, Equatable { case transactionException }

/// Informational logging notifications issued by StoreHelper
public enum StoreNotification: Error, Equatable {
    
    case configurationNotFound
    case configurationEmpty
    case configurationSuccess
    case configurationFailure

    case purchaseInProgress(productId: ProductId)
    case purchaseCancelled(productId: ProductId)
    case purchasePending(productId: ProductId)
    case purchaseSuccess(productId: ProductId)
    case purchaseFailure(productId: ProductId)

    case transactionValidationSuccess(productId: ProductId)
    case transactionValidationFailure(productId: ProductId)
    case transactionFailure
    case transactionSuccess(productId: ProductId)

    case requestProductsStarted
    case requestProductsSuccess
    case requestProductsFailure
    
    /// A short description of the notification.
    /// - Returns: Returns a short description of the notification.
    public func shortDescription() -> String {
        switch self {
            
        case .configurationNotFound:           return "Configuration file not found in the main bundle"
        case .configurationEmpty:              return "Configuration file does not contain any product definitions"
        case .configurationSuccess:            return "Configuration success"
        case .configurationFailure:            return "Configuration failure"

        case .purchaseInProgress:              return "Purchase in progress"
        case .purchasePending:                 return "Purchase in progress. Awaiting authorization"
        case .purchaseCancelled:               return "Purchase cancelled"
        case .purchaseSuccess:                 return "Purchase success"
        case .purchaseFailure:                 return "Purchase failure"

        case .transactionValidationSuccess:    return "Transaction validation success"
        case .transactionValidationFailure:    return "Transaction validation failure"
        case .transactionFailure:              return "Transaction failure"
        case .transactionSuccess:              return "Transaction success"

        case .requestProductsStarted:          return "Request products from the App Store started"
        case .requestProductsSuccess:          return "Request products from the App Store success"
        case .requestProductsFailure:          return "Request products from the App Store failure"
        }
    }
}
