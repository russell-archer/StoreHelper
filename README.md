[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Frussell-archer%2FStoreHelper%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/russell-archer/StoreHelper)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Frussell-archer%2FStoreHelper%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/russell-archer/StoreHelper)
[![](https://img.shields.io/github/license/russell-archer/StoreHelper)](https://img.shields.io/github/license/russell-archer/StoreHelper)

---

# StoreHelper

![](./Documentation/assets/StoreHelperDemo0.png)

- [Quick Start](https://github.com/russell-archer/StoreHelper/blob/main/Documentation/quickstart.md) - `StoreHelper` quick-start guide 
- [In-Depth Guide](https://github.com/russell-archer/StoreHelper/blob/main/Documentation/guide.md) - `StoreHelper` and `StoreKit2` in-depth guide
- [Demo Project](https://github.com/russell-archer/StoreHelperDemo) - Example **Xcode 14** `StoreHelper` project
- [StoreHelper Demo with UIKit](https://github.com/russell-archer/StoreHelperDemoUIKit) - experimental demo showing `StoreHelper` in a UIKit project

---

# Recent Major Changes
- 27 January, 2023
    - Fixed a bug related to isPurchased for consumable products. Caused a crash on macOS and iOS (thank you Abdullah Kardaş!) 
- 18 January, 2023
    - Additional logging of various activities added
- 17 January, 2023
    - Improved support for handling extended wait times for StoreKit and App Store responses
    - Improved caching of purchasing status
    - Updates to many shared views to handle unknown purchases status
- 10 January, 2023
    - Added support for caching of product purchase status in `isPurchased(productId:)` using the `purchasedProductsFallback` collection
    - Using `purchasedProductsFallback` as a cache can be turned on/off using `StoreHelper.doUsePurchasedProductsFallbackCache`
    - The `purchasedProductsFallback` property is now `public private(set)` rather than `public`
    - Added "Refresh Products" button and support for pull-to-refresh to the products list
    - UI improvements to various views and improved sharing of views between iOS and macOS 
    - Minor documentation updates (StoreHelper Guide)
- 13 December, 2022
    - Added proof-of-concept demo showing `StoreHelper` in a UIKit project
- 27 November, 2022
	- Major update to the way **subscriptions** are handled
	- Subscription prices now show **prices and renewal periods**
	- **Promotional and Introductory offers** on subscriptions are now supported
	- The most appropriate **promotional** or **introductory** offers or standard price and renewal period are automatically displayed
	- Additions to `StoreHelper.SubscriptionHelper`: `hasLowerValueCurrentSubscription(than:)`, `isLapsedSubscriber(to:)`, `allSubscriptionTransactions()`
	- Added in-app redemption of **offer codes**
	- Added new sections to the **Guide** on "Subscription Introductory and Promotional Offers" and "Supporting In-App Offer Code Redemption"
	- **Quick Start** and **Guide** documentation reviewed and updated for iOS16/macOS13/Xcode14 and new subscription features
- 7 Nov, 2022
    - Minor changes re upgrade to iOS 16 and macOS 13
- 19 October, 2022
	- Added new section to the Guide on "Restoring Previous Purchases"
- 15 March, 2022
	- Changed the initialization flow because of a new warning in Xcode 13.3 related to having `@MainActor init()`
	- Removed the need for StoreHelper's init method to run on the main thread by moving some initialization code to a new `start()` method
	- You should now call `StoreHelper.start()` as soon as possible after initializing `StoreHelper`
	- The `start()` method starts listening for transactions and get localized product info from the App Store
	- Updated all documentation because of this change
- 25 January, 2022
	- Refactored `StoreHelper` as a SPM Package
	- Moved example app to separate repo ([StoreHelperDemo](https://github.com/russell-archer/StoreHelperDemo))
	- Updated documentation re change to SPM package
- 19 January, 2022
	- Major updates to documentation
	- Added Mac target
- 21 December, 2021
	- Updated documentation to reflect refactoring changes
- 20 December, 2021
	- Refactored throughout so that this non-private version of `StoreHelper` is in-sync with private `StoreHelper` code used in an app released to the App Store
    
---

## Overview of StoreHelper

`StoreHelper` is a Swift Package Manager (SPM) package that enables developers using Xcode 14/13 to easily add in-app purchase 
support to **iOS 16/15** and **macOS 13/12** SwiftUI apps.

`StoreHelper` is used to provide in-app purchase support in **Writerly** (iOS/macOS), which is available on the [App Store](https://apps.apple.com/app/writerly/id1143101981?ls=1).

`StoreHelper` provides the following features:

- Multi-platform (iOS, macOS) SwiftUI support for purchasing **Consumable**, **Non-consumable** and **Subscription** products
- Detailed **documentation** and an example project
- Supports **transaction validation**, **pending ("ask to buy") transactions**, **cancelled** and **failed** transactions
- Supports customer **refunds** and management of **subscriptions**
- Supports **introdctory offers**, in-app redeeming of **offer codes** and experimental support for **promotional offers**
- Provides detailed **transaction information and history** for non-consumables and subscriptions
- Support for direct App Store purchases of **promoted in-app purchases**

## License

MIT license, copyright (c) 2022, 2023 Russell Archer. This software is provided "as-is" 
without warranty and may be freely used, copied, modified and redistributed, including 
as part of commercial software. 

See [License](https://github.com/russell-archer/StoreHelper/blob/main/LICENSE.md) for details.

## Requirements

`StoreHelper` uses Apple's `StoreKit2`, which requires **iOS 16/15**, **macOS 13/12** and **Xcode 14/13**.

## Getting Started

Jump to the [Quick Start](https://github.com/russell-archer/StoreHelper/blob/main/Documentation/quickstart.md) guide.
