# StoreHelper Demo
Implementing and testing In-App Purchases with `StoreKit2` and `StoreHelper` in Xcode 13, Swift 5.5, iOS 15, macOS 12, tvOS 15 and watchOS 8.

***
WORK IN PROGRESS
***

# Description
![[StoreHelper Demo 0.png | 100]]

Implementing and testing In-App Purchases with `StoreKit2` and `StoreHelper` in Xcode 13, Swift 5.5, iOS 15, macOS 12, tvOS 15 and watchOS 8.

> This app requires StoreKit2, Swift 5.5, Xcode 13 and iOS 15.
> See [[In-App Purchases with Xcode 12 and iOS 14]] for details of working with the original StoreKit1 in iOS 14 and lower.

# Source Code
See [StoreHelperDemo on GitHub](https://github.com/russell-archer/IAPDemo) for source code. 

> **Disclaimer**. The source code presented here is for educational purposes. 
> You may freely reuse and amend this code for use in your own apps. However, you do so entirely at your own risk.

# Contents
- [[#References]]
- [[#Overview]]
- [[#What's changed from the original StoreKit]]
	- [[#Receipt validation]]
	- [[#Async Await support]]
	- [[#Should I use StoreKit1 or StoreKit2]]
- [[#StoreHelperDemo App]]
	- [[#Get Started]]
	- [[#Defining our Products]]
	- [[#Create the StoreKit configuration file]]
	- [[#Enable StoreKit Testing via the Project Scheme]]
	- [[#Creating a Production Product List]]

# References
- https://developer.apple.com/documentation/storekit/in-app_purchase
- https://developer.apple.com/documentation/storekit/choosing_a_storekit_api_for_in-app_purchase
- https://developer.apple.com/documentation/storekit/in-app_purchase/implementing_a_store_in_your_app_using_the_storekit_api
- https://developer.apple.com/design/human-interface-guidelines/in-app-purchase/overview/introduction/
- https://developer.apple.com/videos/play/wwdc2021/10175 
- https://developer.apple.com/videos/play/wwdc2021/10114/
- https://developer.apple.com/support/universal-purchase/

---

# Overview
![[StoreHelper Demo 2.png]] 

This SwiftUI app will demonstrate how to use Apple's new `StoreKit2` framework to provide in-app purchases to your users. 

The basic premise of the demo is that we're creating an app for an on-line florist that sells a range of flowers, chocolates and other related services like home visits to water and care for house plants.

Specifically, in building the app we'll cover:

- How to create a **multi-platform** SwiftUI app that allows users to purchase a range of products, including:

	- **consumable** (VIP plant installation service: lasts for one day)
	- **non-consumable** (cut flowers, potted plants, chocolates, etc.), and 
	- **subscription** (VIP plant home care: scheduled home visits to water and care for house plants)

- Creating a `StoreHelper` that encapsulates `StoreKit2` in-app purchase functionality and makes it easy to work with the App Store
- Requesting localized **product information** from the App Store
- How to **purchase** a product and **validate the transaction**
- Handling **pending ("ask to buy") transactions** where parental permission must be obtained before a purchase is completed
- Handling **canceled** and **failed transactions**
- Automatically handling customer **refunds**
- Exploring detailed **transaction information and history**
- Testing purchases locally using **StoreKit configuration** files
- **Sandbox testing**
- **Automated testing** of `StoreHelper`

# What's changed from the original StoreKit?
There are two **huge** changes from the previous (original) version of StoreKit (`StoreKit1` hereafter):

## Receipt validation
With `StoreKit1` validating the receipt issued by the App Store was a tricky process that required either:

- Working with the C-based `OpenSSL` library to decrypt, read and validate receipt data (on-device validation)
- Setting up an app server to communicate with the App Store server (server-based validation)

See [[In-App Purchases with Xcode 12 and iOS 14]] for more details.

`StoreKit2` now uses the industry-standard JSON Web Signature (`JWS`) format as a secure container for transaction information signed by the App Store:

- JWS is easy to read - no need for a third-party cryptography library!
- Better still, transactions are now **automatically** validated by `StoreKit2`!!

## Async/Await support
`StoreKit1` used a closure-based method of working with async APIs and notifications:

- This led to code that was difficult to read, with program flow being somewhat disjointed

`StoreKit2` fully embraces the `Async`/`Await` pattern introduced in Swift 5.5, Xcode 13 and iOS 15:

- This makes working with async APIs much easier and results in a more "natural" flow to your code

## Should I use StoreKit1 or StoreKit2?
Working with in-app purchases using `StoreKit2` is a vastly superior experience over using `StoreKit1` and you should choose to use it possible.
However, `StoreKit2` requires that your app targets **iOS 15/macOS 12**. If you need to support iOS 14 and lower you'll need to continue using `StoreKit1`.

Apple provides [documentation](https://developer.apple.com/documentation/storekit/choosing_a_storekit_api_for_in-app_purchase) to help you decide which version of StoreKit is right for your app.

The good news is that although there are two versions of the StoreKit, both frameworks share a common App Store backend:

- Both versions of StoreKit provide access to the same in-app purchase product data you configure in the App Store
- Both versions of StoreKit provide the exact same UI experience for users
- Transactions made with one version of StoreKit are immediately available in the other version

# StoreHelperDemo App
The best way to get familiar with `StoreKit2` is to create a simple, but full-featured demo app. 
I'll introduce features in an as-required manner as we build the app from it's simplest form to a fully-functional demo.

## Get Started
`StoreHelperDemo` was created using Xcode 13 (beta) and the multi-platform app template.

To get started, here's the structure of the Xcode project after creating empty group folders but before we start adding files. Note that I moved `ContentView.swift` into the `Shared/Views` folder and `StoreHelperApp.swift` and the `Assets` catalog into the `Shared/Support` folder:

![[StoreHelper Demo 1.png]]

Check that your iOS and macOS targets support iOS 15 and macOS 12 respectively:

![[StoreHelper Demo 3.png]]

![[StoreHelper Demo 4.png]]

For both targets, add the **In-App Purchase** capability. This will also add the `StoreKit` framework to your project:

![[StoreHelper Demo 5.png]]

## Defining our Products
Before we do anything else we need to define the products we'll be selling. Ultimately this will be done in App Store Connect. However, testing in-app purchases (IAPs) using an **App Store Sandbox** environment takes quite a bit of setting up and is rather frustrating to work with. 

> The sandbox test environment requires you to create multiple **sandbox test accounts** in App Store Connect. Each sandbox account has to have a unique email address and be validated as an AppleID. In addition, tests must be on a real device, not the simulator.
> 
> On the test device you need to sign out of your normal AppleID and sign-in using the sandbox account. This really means you need a spare device to do testing on. To make things more painful, each time you make a purchase using a sandbox account that account becomes “used up” and can’t be used to re-purchase the same product. There’s no way to clear purchases, so you need to use a fresh sandbox account for each set of product purchases.

Fortunately, there's now a much better way.

Introduced in Xcode 12 a new **local** StoreKit test environment allows you to do early testing of IAPs in the simulator without having to set anything up in App Store Connect. You define your products locally in a **StoreKit Configuration** file. Furthermore, you can view and delete transactions, issue refunds, and a whole lot more. There’s also a new `StoreKitTest` framework that enables you to do automated testing of IAPs which we'll use later on. We'll use this approach to test IAPs in our app.

## Create the StoreKit configuration file
Select **File > New > File** and choose the **StoreKit Configuration File** template:

![[StoreHelper Demo 6.png]]

Save the file as `Products.storekit` in the `Shared/Configuration` folder.

Open the Products configuration file and click **+** to add an in-app purchase. For example, select the **Add Non-Consumable In-App Purchase** option:

![[StoreHelper Demo 7.png]]

You can now define your products in the StoreKit configuration file. For now we'll create four non-consumable products:

![[StoreHelper Demo 8.png]]

```stylus
Type				: NonConsumable
ReferenceName 		: flowers-large
ProductID 			: com.rarcher.nonconsumable.flowers-large
Price 				: 1.99
FamilyShareable 	: true
Locale 				: en_US
DisplayName 		: Flowers Large
Description 		: A cool bunch of mixed flowers

Type				: NonConsumable
ReferenceName 		: flowers-small
ProductID 			: com.rarcher.nonconsumable.flowers-small
Price 				: 0.99
FamilyShareable 	: false
Locale 				: en_US
DisplayName 		: Flowers Small
Description 		: A cool small bunch of flowers

Type				: NonConsumable
ReferenceName 		: roses-large
ProductID 			: com.rarcher.nonconsumable.roses-large
Price 				: 2.99
FamilyShareable 	: false
Locale 				: en_US
DisplayName 		: Roses Large
Description 		: A large bunch of red roses

Type				: NonConsumable
ReferenceName 		: chocolates-small
ProductID 			: com.rarcher.nonconsumable.chocolates-small
Price 				: 3.99
FamilyShareable 	: true
Locale 				: en_US
Description 		: A small box of chocolates
DisplayName 		: Chocolates Small
```

- **Type**
The type of product (Non-Consumable, Consumable, Non-Renewing, Auto-Renewing).

- **Reference Name** 
A short descriptive reference for the product. Not visible to users.

- **Product ID** 
The unique code used to identify an IAP product. This same ID will be used in App Store Connect when setting up in-app purchases for production. Note that Product ID is a string that, by convention, uses the format “com.developer.product”, although it can be anything you like. Not visible to users.

- **Price** 
A hard-coded price for the product. In production your app will request localized price (and other) information from the App Store. Visible to users.

- **Family Shareable**
True if purchases can be shared by family members, false otherwise. Visible to users.

- **Locale**
By default, the first localization is for the US store. This is used if no other localizations are defined. You can add as many localizations as required. Visible to users.

- **Description**
A short description of the product. Visible to users.

- **Display Name**
The name for the product that users see.

> Note that none of the data defined in the .storekit file is ever uploaded to App Store Connect. It’s only used when testing in-app purchases locally in Xcode.

## Enable StoreKit Testing via the Project Scheme
You now need to enable StoreKit testing in Xcode (it’s disabled by default).

Select **Product > Scheme > Edit Scheme**. Now select **Run** and the **Options** tab. You can now select your configuration file from the **StoreKit Configuration** list:

![[StoreHelper Demo 9.png]]

You'll need to do this for both targets (iOS and macOS).

Should you wish to disable StoreKit testing then repeat the above steps and remove the StoreKit configuration file from the **StoreKit Configuration** list.

## Creating a Production Product List
We'll see shortly how one of the first things our app has to do on starting is request localized product information from the App Store (this is the case both when using the local StoreKit test environment and the App Store release environment). This requires a list of our product identifiers. We've defined our products in the StoreKit configuration file, so it seems obvious that we should use that as the repository for our IAP data. Retrieving config data at runtime isn't difficult (it's `JSON`). However, the StoreKit configuration file is intended for use *when testing* and it's not a good idea to use it for production too. It would be all too easy to allow "test products" to make it into the release build!

So, we'll define a plain list of our product identifiers in a property list.

Create a new property list named "**Products.plist**", save it to the `Shared/Configuration` folder and add the product identifiers:

```xml
<plist version="1.0">
<dict>
    <key>Products</key>
    <array>
        <string>com.rarcher.nonconsumable.flowers-large</string>
        <string>com.rarcher.nonconsumable.flowers-small</string>
        <string>com.rarcher.nonconsumable.roses-large</string>
        <string>com.rarcher.nonconsumable.chocolates-small</string>
    </array>
</dict>
</plist>
```

To help us read the property list we'll create a `Configuration` struct:

```swift
import Foundation

/// Provides static methods for reading plist configuration files.
public struct Configuration {
    
    /// Read a plist property file and return a dictionary of values
    public static func readPropertyFile(filename: String) -> [String : AnyObject]? {
        if let path = Bundle.main.path(forResource: filename, ofType: "plist") {
            if let contents = NSDictionary(contentsOfFile: path) as? [String : AnyObject] {
                return contents
            }
        }

        return nil
    }
}
```

## StoreHelper
So that we have some products to display, we'll create the `StoreHelper` class before we focus on the UI.







%%
The `Product` struct is a key object in StoreKit2 and is used to request info on all products in the app store and make purchases:

![[In-app purchases with StoreKit2 0.png]]

Receipt validation:

![[Pasted image 20210611133421.png]]



Access Transaction History and Current Entitlements
Your app doesn’t create transaction objects. Instead, StoreKit automatically makes up to date transactions available to your app, including when the user launches the app for the first time. You access transactions in several ways:
Get transaction history anytime by accessing the static all sequence, or get just the most recent transactions for a product by calling latest(for:).
Get notified of new transactions while your app is running when users complete a transaction on another device, through the transaction listener.
The most important use of transaction information is for determining which in-app purchases the user has paid access to, so your app can unlock the content or service. The currentEntitlements API provides the information you need to unlock all of the user’s paid content in your app. Use currentEntitlements to get a list of transactions for all the products the user is currently entitled to, including non-consumable in-app purchases and currently active subscriptions.

Verify Transactions
The App Store cryptographically signs transaction information, in JWS format. The transaction type provides the raw jws string and also makes the transaction information immediately available in the Transaction Properties. StoreKit automatically validates the transaction information, returning it wrapped in a VerificationResult. If you get a transaction through VerificationResult.verified(_:), the information passed validation. If you get it through VerificationResult.unverified(_:), the transaction information didn’t pass StoreKit’s automatic validation. Perform your own validation directly on the transaction’s jws string, or use the provided convenience properties such as headerData, payloadData, signatureData. For more information about JWS, see the RFC7515 standard.
If StoreKit returned the transaction as verified, then the transaction is valid for the device. For more information about verifying a transaction for a device, see deviceVerification.
%%
