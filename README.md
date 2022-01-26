# StoreHelper

- See [StoreHelper Quick Start](https://github.com/russell-archer/StoreHelper/Documentation/quickstart.md) for a short tutorial on using `StoreHelper` to add in-app purchase support to your **iOS 15/macOS 12 SwiftUI** app
- See [StoreHelper Guide](https://github.com/russell-archer/StoreHelper/Documentation/guide.md) for in-depth discussion and tutorial on using `StoreHelper`, `StoreKit2` with **Xcode 13**, **iOS 15** and **macOS 12**
- See [StoreHelperDemo](https://github.com/russell-archer/StoreHelperDemo) for an example SwiftUI project using StoreHelper with **Xcode 13** and **iOS 15**
- See [In-App Purchases with Xcode 12 and iOS 14](https://github.com/russell-archer/IAPDemo) for details of working with StoreKit1 in **iOS 14**

# Overview of StoreHelper

`StoreHelper` is a Swift Package Manager (SPM) package that enables developers to easily add in-app purchase support to **iOS 15/macOS 12 SwiftUI** apps.

Specifically, `StoreHelper` provides the following features:

- Multi-platform (iOS and macOS) SwiftUI support that allows users to purchase **Consumables**, **Non-consumables** and **Subscriptions**
- Supports **transaction validation**
- Handles **pending ("ask to buy") transactions** where parental permission must be obtained before a purchase is completed
- Handles **cancelled** and **failed transactions**
- Supports customer **refunds**
- Handles management of **subscriptions**
- Provides detailed **transaction information and history** for non-consumables and subscriptions
- Support for direct App Store purchases of **promoted in-app purchases**
- Used by apps [live on the App Store](https://apps.apple.com/app/writerly/id1143101981)

# License

MIT License. Copyright (c) 2022 Russell Archer. See [License](https://github.com/russell-archer/StoreHelper/blob/main/LICENSE.md).

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
