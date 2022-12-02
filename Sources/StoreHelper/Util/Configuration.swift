//
//  Configuration.swift
//  StoreHelper
//
//  Created by Russell Archer on 20/12/2021.
//

import Foundation

/// Default config values used by StoreHelper. May be overriden by using a Configuration.plist file.
public enum Configuration {
    case appGroupBundleId            // The id for the container shared between the main app and widgets
    case contactUsUrl                // A URL where the user can contact the app developer.
    case requestRefundUrl            // A URL which users on macOS can use to request a refund for an IAP.
    case restorePurchasesButtonText  // The text to display on the restore purchases button. If nil the button is not displayed.
    case termsOfServiceUrl           // A URL that links to your terms of service. Displayed in the list of IAP products. If nil the link is not displayed.
    case privacyPolicyUrl            // A URL that links to your privacy policy. Displayed in the list of IAP products. If nil the link is not displayed.
    case redeemOfferCodeButtonText   // The text to display on the redeem offer code button. If nil the button is not displayed.
    
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
    public func value(storeHelper: StoreHelper) -> String? {
        switch self {
            case .appGroupBundleId:             return resolveOverriddenValue(overrides: storeHelper.configurationOverride)
            case .contactUsUrl:                 return resolveOverriddenValue(overrides: storeHelper.configurationOverride)
            case .requestRefundUrl:             return resolveOverriddenValue(overrides: storeHelper.configurationOverride)
            case .restorePurchasesButtonText:   return resolveOverriddenValue(overrides: storeHelper.configurationOverride)
            case .termsOfServiceUrl:            return resolveOverriddenValue(overrides: storeHelper.configurationOverride)
            case .privacyPolicyUrl:             return resolveOverriddenValue(overrides: storeHelper.configurationOverride)
            case .redeemOfferCodeButtonText:    return resolveOverriddenValue(overrides: storeHelper.configurationOverride)
        }
    }
    
    public func key() -> String {
        switch self {
            case .appGroupBundleId:             return "appGroupBundleId"
            case .contactUsUrl:                 return "contactUsUrl"
            case .requestRefundUrl:             return "requestRefundUrl"
            case .restorePurchasesButtonText:   return "restorePurchasesButtonText"
            case .termsOfServiceUrl:            return "termsOfServiceUrl"
            case .privacyPolicyUrl:             return "privacyPolicyUrl"
            case .redeemOfferCodeButtonText:    return "redeemOfferCodeButtonText"
        }
    }
    
    private func resolveOverriddenValue(overrides: [String : AnyObject]?) -> String? {
        // Use values from the Configuration.plist file in preference to default values where possible
        if let overrides, overrides.count > 0 {
            // We have a Configuration override file. Use values from it where they're available
            if let value = overrides[key()] {
                // The Configuration file contains the key we're looking for
                let sValue = value as! String  // This is a safe forced unwrap. If the value is undefined in the plist it will have been read as an empty string
                return sValue == "" ? nil : sValue  // We interpret an empty string (missing value) as nil
            }
        }
            
        // We don't have a Configuration file, or it doesn't have the key we're interested in. Use our default value
        switch self {
            case .appGroupBundleId:             return Configuration.AppGroupBundleId
            case .contactUsUrl:                 return Configuration.ContactUsUrl
            case .requestRefundUrl:             return Configuration.RequestRefundUrl
            case .restorePurchasesButtonText:   return Configuration.RestorePurchasesButtonText
            case .termsOfServiceUrl:            return Configuration.TermsOfServiceUrl
            case .privacyPolicyUrl:             return Configuration.PrivacyPolicyUrl
            case .redeemOfferCodeButtonText:    return Configuration.RedeemOfferCodeButtonText
        }
    }
}

