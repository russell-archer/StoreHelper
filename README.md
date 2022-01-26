# StoreHelper

- [Quick Start](https://github.com/russell-archer/StoreHelper/blob/main/Documentation/quickstart.md) - a tutorial on using `StoreHelper`
- [Guide](https://github.com/russell-archer/StoreHelper/blob/main/Documentation/guide.md) - in-depth discussion on `StoreHelper` and `StoreKit2`
- [Demo](https://github.com/russell-archer/StoreHelperDemo) - an example SwiftUI project using `StoreHelper` with **Xcode 13** and **iOS 15**

# Overview of StoreHelper

`StoreHelper` is a Swift Package Manager (SPM) package that enables developers to easily add in-app purchase support to **iOS 15/macOS 12 SwiftUI** apps.

Specifically, `StoreHelper` provides the following features:

- Multi-platform (iOS and macOS) SwiftUI support enables users to purchase **Consumable**, **Non-consumable** and **Subscription** products
- Supports **transaction validation**, **pending ("ask to buy") transactions**, **cancelled** and **failed transactions**
- Supports customer **refunds** and management of **subscriptions**
- Provides detailed **transaction information and history** for non-consumables and subscriptions
- Support for direct App Store purchases of **promoted in-app purchases**

# License

MIT license, copyright (c) 2022, Russell Archer. This software is provided "as-is" without warranty and may be freely used, copied, modified and redistributed, including as part of commercial software. 
See [License](https://github.com/russell-archer/StoreHelper/blob/main/LICENSE.md) for details.

# Requirements

`StoreHelper` uses Apple's `StoreKit2`, which requires **iOS 15**, **macOS 12** and **Xcode 13** or higher.

# Adding the Package to your Project

- Open your project in Xcode
- Select **File > Add Packages...**
- Paste the URL of the `StoreHelper` package into the search box: https://github.com/russell-archer/StoreHelper
- Click **Add Package**
- Xcode will fetch the package from GitHub and then display a confirmation. Click **Add Package**
- Notice that the `StoreHelper` and `swift-collections` packages have been added to the project. `swift-collections` is a package dependency for `StoreHelper`
- If you expand the `StoreHelper` package you'll be able to see the source
