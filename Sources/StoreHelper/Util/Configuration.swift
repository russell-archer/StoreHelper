//
//  Configuration.swift
//  StoreHelper
//
//  Created by Russell Archer on 20/12/2021.
//

import Foundation

/// Default config values used by StoreHelper. May be overriden by using a Configuration.plist file in your app's main bundle.
///
/// See `StoreHelper/Samples/Configuration/Configuration.plist` for an example.
public enum Configuration {
    /// The id for the container shared between the main app and widgets. If nil, the app doesn't have widgets.
    /// Default value is nil.
    case appGroupBundleId

    /// A URL where the user can contact the app developer. If nil,
    /// Default value is nil.
    case contactUsUrl

    /// A URL which users on macOS can use to request a refund for an IAP.
    /// Default value is "https://reportaproblem.apple.com/".
    case requestRefundUrl

    /// The text to display on the restore purchases button. If nil the button is not displayed.
    /// Default value is "Restore Purchases".
    case restorePurchasesButtonText

    /// A URL that links to your terms of service. Displayed in the list of IAP products. If nil the link is not displayed.
    /// Default value is "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/".
    case termsOfServiceUrl

    /// A URL that links to your privacy policy. Displayed in the list of IAP products. If nil the link is not displayed.
    /// Default value is nil.
    case privacyPolicyUrl

    /// The text to display on the redeem offer code button. If nil the button is not displayed.
    /// Default value is "Redeem an Offer".
    case redeemOfferCodeButtonText
    
    // Default values:
    private static let AppGroupBundleId: String?            = nil
    private static let ContactUsUrl: String?                = nil
    private static let RequestRefundUrl: String?            = "https://reportaproblem.apple.com/"
    private static let RestorePurchasesButtonText: String?  = "Restore Purchases"
    private static let TermsOfServiceUrl: String?           = "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/"
    private static let PrivacyPolicyUrl: String?            = nil
    private static let RedeemOfferCodeButtonText: String?   = "Redeem an Offer"
    
    /// Gets an overridden configuration value, or if not found, provides a default value.
    /// - Parameter storeHelper: An instance of StoreHelper
    /// - Returns: Returns an overridden configuration value, or if not found, provides a default value.
    /// If the value is undefined in the configuration plist, nil will be returned.
    public func stringValue(storeHelper: StoreHelper) -> String? { resolveOverriddenStringValue(overrides: storeHelper.configurationOverride) }
    
    /// Gets an overridden configuration value, or if not found, provides a default value.
    /// - Parameter overrides: A dictionary of values which override the default values set by StoreHelper.
    /// - Returns: Returns an overridden configuration value, or if not found, provides a default value.
    /// If the value is undefined in the configuration plist, nil will be returned.
    public func stringValue(overrides: [String : AnyObject]?) -> String? { resolveOverriddenStringValue(overrides: overrides) }
    
    /// Gets an overridden configuration value, or if not found, provides a default value.
    /// - Parameter storeHelper: An instance of StoreHelper
    /// - Returns: Returns an overridden configuration value, or if not found, provides a default value.
    /// If the value is undefined in the configuration plist, false will be returned.
    public func booleanValue(storeHelper: StoreHelper) -> Bool { resolveOverriddenBooleanValue(overrides: storeHelper.configurationOverride) }
    
    /// Gets an overridden configuration value, or if not found, provides a default value.
    /// - Parameter overrides: A dictionary of values which override the default values set by StoreHelper.
    /// - Returns: Returns an overridden configuration value, or if not found, provides a default value.
    /// If the value is undefined in the configuration plist, false will be returned.
    public func booleanValue(overrides: [String : AnyObject]?) -> Bool { resolveOverriddenBooleanValue(overrides: overrides) }
    
    public func key() -> String {
        switch self {
            case .appGroupBundleId:           return "appGroupBundleId"
            case .contactUsUrl:               return "contactUsUrl"
            case .requestRefundUrl:           return "requestRefundUrl"
            case .restorePurchasesButtonText: return "restorePurchasesButtonText"
            case .termsOfServiceUrl:          return "termsOfServiceUrl"
            case .privacyPolicyUrl:           return "privacyPolicyUrl"
            case .redeemOfferCodeButtonText:  return "redeemOfferCodeButtonText"
        }
    }
    
    private func resolveOverriddenStringValue(overrides: [String : AnyObject]?) -> String? {
        // Use values from the Configuration.plist file in preference to default values where possible
        if let overrides, overrides.count > 0 {
            // We have a Configuration override file. Use values from it where they're available
            if let value = overrides[key()] {
                // The Configuration file contains the key we're looking for
                let sValue = value as! String  // This is a safe force unwrap. If the value is undefined in the plist it will have been read as an empty string
                return sValue.count == 0 ? nil : sValue  // We interpret an empty string (missing value) as nil
            }
        }
        
        // We don't have a Configuration file, or it doesn't have the key we're interested in. Use our default value
        switch self {
            case .appGroupBundleId:           return Configuration.AppGroupBundleId
            case .contactUsUrl:               return Configuration.ContactUsUrl
            case .requestRefundUrl:           return Configuration.RequestRefundUrl
            case .restorePurchasesButtonText: return Configuration.RestorePurchasesButtonText
            case .termsOfServiceUrl:          return Configuration.TermsOfServiceUrl
            case .privacyPolicyUrl:           return Configuration.PrivacyPolicyUrl
            case .redeemOfferCodeButtonText:  return Configuration.RedeemOfferCodeButtonText
        }
    }
    
    private func resolveOverriddenBooleanValue(overrides: [String : AnyObject]?) -> Bool {
        // Use values from the Configuration.plist file in preference to default values where possible
        if let overrides, overrides.count > 0 {
            // We have a Configuration override file. Use values from it where they're available
            if let value = overrides[key()] {
                // The Configuration file contains the key we're looking for
                // If the value is undefined in the plist it will have been read as an empty string. which we'll interpret as false
                if let sValue = value as? String, sValue.count == 0 { return false }
                if let bValue = value as? Bool { return bValue }
                return false
            }
        }
            
        // We don't have a Configuration file, or it doesn't have the key we're interested in. Use our default value
        switch self {
            case .appGroupBundleId:                 return false
            case .contactUsUrl:                     return false
            case .requestRefundUrl:                 return false
            case .restorePurchasesButtonText:       return false
            case .termsOfServiceUrl:                return false
            case .privacyPolicyUrl:                 return false
            case .redeemOfferCodeButtonText:        return false
        }
    }
}

