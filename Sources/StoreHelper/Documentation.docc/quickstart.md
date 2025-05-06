# StoreHelper Quick Start

@Metadata {
    @PageImage(purpose: icon, source: storehelper-logo)
    @CallToAction(url: "https://github.com/russell-archer/StoreHelperDemo", purpose: link, label: "View StoreHelperDemo on GitHub")
}

The Quick Start guide shows how to use `StoreHelper` to create a bare-bones SwiftUI app that supports in-app purchases on **iOS 17** and **macOS 14**.

## Description

![](StoreHelperDemo0.png)

- See <doc:guide> for in-depth discussion and tutorial on using `StoreHelper`, `StoreKit2` with **Xcode 13 - 15**, **iOS 15 - 17** and **macOS 12 - 14**
- See [StoreHelperDemo](https://github.com/russell-archer/StoreHelperDemo) for an example SwiftUI project using StoreHelper with Xcode and **iOS 17**
- See [StoreHelper Demo with UIKit](https://github.com/russell-archer/StoreHelperDemoUIKit) for an experimental demo project showing how to use `StoreHelper` in a UIKit #project

## Contents

- <doc:#Description>
- <doc:#Contents>
- <doc:#Quick-Start>
	- <doc:#What-you'll-need>
	- <doc:#Steps>
		- <doc:#Getting-the-StoreHelper-Package>
		- <doc:#Create-the-App-struct>
		- <doc:#Create-MainView>
		- <doc:#Create-ProductView>
		- <doc:#Modify-ContentView>
		- <doc:#Create-the-ProductInfo-View>
        	- <doc:#Create-SubscriptionView>
		- <doc:#Create-SimplePurchaseView>
		- <doc:#Add-Product-Images>
		- <doc:#Add-Product-Configuration-Files>
		- <doc:#Run-the-App>

---

## Quick Start
The following steps show to use `StoreHelper` to create a bare-bones SwiftUI demo app that supports in-app purchases on **iOS 17** and **macOS 14**.

See [StoreHelperDemo](https://github.com/russell-archer/StoreHelperDemo) for an example SwiftUI project using `StoreHelper` with Xcode 15.

### What you'll need
- **Xcode 13 - 15** installed on your Mac
- Basic familiarity with **Xcode**, **Swift** and **SwiftUI**
- About 15-minutes!

## Steps
### Getting the StoreHelper Package
- Open Xcode and create a new project
- Select the **multi-platform** template and create an app named **"StoreHelperDemo"**
- Select **File > Add Packages...**
- Paste the URL of the `StoreHelper` package into the search box: 

    - For HTTPS use: https://github.com/russell-archer/StoreHelper.git
    - For SSH use: git@github.com:russell-archer/StoreHelper.git

- Click **Add Package**:

![](StoreHelperDemo101.png)

- Xcode will fetch the package from GitHub and then display a confirmation. Click **Add Package**:

![](StoreHelperDemo102.png)

- The project should now look like this:

![](StoreHelperDemo103.png)

- Notice that the `StoreHelper` and `swift-collections` packages have been added to the project. `swift-collections` is a package dependency for `StoreHelper`
- If you expand the `StoreHelper` package you'll be able to see the source:

![](StoreHelperDemo104.png)

- Select the project's **target**. Notice that `StoreHelper` has been added as a library for the **iOS**, **iPad** and **macOS** targets:

![](StoreHelperDemo109.png)

- With the project's target selected, add the **In-App Purchase** capability:

![](StoreHelperDemo105.png)

- Adding the in-app purchase capability will automatically add the `StoreKit` framework to your project:

![](StoreHelperDemo110.png)

## Create the App struct
- Create a folder below the main project root named **Shared**
- Move the file `StoreHelperDemoApp.swift` into the Shared folder
- Open `StoreHelperDemoApp.swift` and replace the existing code with the following:

> Alternatively, you can copy everything required for the **StoreHelperDemo** app from the **StoreHelper > Samples** folder:
> - Delete **ContentView.swift** and **Your-Project-NameApp.swift** from your project and move them to the trash
> - Select any file in the **StoreHelper > Samples > Code** folder in Xcode, right-click it and select **Show in Finder**
> - In Finder, select all the files in the **Code** directory and drag them into into your project's main folder in Xcode. Select **Copy items if needed** when prompted
> - Rename **StoreHelperDemoApp.swift** to **Your-Project-NameApp.swift**, also rename the struct from `StoreHelperDemoApp` to `Your-Project-NameApp`
> - In Finder, select all files (except the readme.md) in the **Configuration** directory and drag them into your project's main folder in Xcode. Select **Copy items if needed** when prompted
> - Rename **SampleProducts.plist** to **Products.plist** and **SampleProducts.storekit** to **Products.storekit**
> - In Finder, select all images in the **Images** directory and drag them into your project's **Asset Catalog** in Xcode

```swift
import SwiftUI
import StoreHelper

@available(iOS 15.0, macOS 12.0, *)
@main
struct StoreHelperDemoApp: App {
    @StateObject var storeHelper = StoreHelper()
    
    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(storeHelper)
                .task { storeHelper.start() }  // Start listening for transactions
                #if os(macOS)
                .frame(minWidth: 700, idealWidth: 700, minHeight: 700, idealHeight: 700)
                .font(.title2)
                #endif
        }
    }
}
```

- Notice how we `import StoreHelper`, create an instance of the `StoreHelper` class and add it to the SwiftUI view hierarchy using the `.environmentObject()` modifier 
- We also call `storeHelper.start()` to begin listening for App Store transactions. This should be done as soon as possible during app start-up

## Create MainView
- Create a new SwiftUI `View` in the **Shared** folder named `MainView` and replace the existing code with the following:

```swift
import SwiftUI

@available(iOS 15.0, macOS 12.0, *)
struct MainView: View {
    let largeFlowersId = "com.rarcher.nonconsumable.flowers.large"
    let smallFlowersId = "com.rarcher.nonconsumable.flowers.small"
    
    var body: some View {
        NavigationStack {
            List {
                NavigationLink(destination: ContentView()) { Text("Product List").font(.largeTitle).padding()}
                NavigationLink(destination: ProductView(productId: largeFlowersId)) { Text("Large Flowers").font(.largeTitle).padding()}
                NavigationLink(destination: ProductView(productId: smallFlowersId)) { Text("Small Flowers").font(.largeTitle).padding()}
                NavigationLink(destination: SubscriptionView()) { Text("Subscriptions").font(.largeTitle).padding()}
                NavigationLink(destination: SimplePurchaseView()) { Text("Simple Purchase").font(.largeTitle).padding()}
            }
        }
        #if os(iOS)
        .navigationViewStyle(.stack)
        .navigationBarTitle(Text("StoreHelperDemo"), displayMode: .large)
        #endif
    }
}
```

- `MainView` provides simple navigation to `ContentView`, which shows a list of available products, and `ProductView` which gives the user access to a particular product if they've purchased it
- Notice how we pass the `ProductId` for either the "Large Flowers" or "Small Flowers" product to `ProductView`

### Create ProductView
- Create a new SwiftUI `View` named `ProductView` and save it to the **Shared** folder. Replace the existing code with the following:

```swift
import SwiftUI
import StoreHelper

@available(iOS 15.0, macOS 12.0, *)
struct ProductView: View {
    @EnvironmentObject var storeHelper: StoreHelper
    @State private var purchaseState: PurchaseState = .unknown
    var productId: ProductId
    
    var body: some View {
        VStack {
            Image(productId).bodyImage()

            switch purchaseState {
                case .purchased: Text("You have purchased this product and have full access.")
                        .font(.title)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.green)
                        .padding()
                    
                case .notPurchased: Text("Sorry, you have not purchased this product and do not have access.")
                        .font(.title)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.red)
                        .padding()
                    
                default:
                    ProgressView().padding()
                    Text("The purchase state for this product is \(purchaseState.shortDescription().lowercased())")
                        .font(.title)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.orange)
                        .padding()
            }
        }
        .padding()
        .task {
            let isPurchased = (try? await storeHelper.isPurchased(productId: productId)) ?? false
            purchaseState = isPurchased ? .purchased : .notPurchased
        }
        .onChange(of: storeHelper.purchasedProducts) {
            Task.init {
                let isPurchased = (try? await storeHelper.isPurchased(productId: productId)) ?? false
                purchaseState = isPurchased ? .purchased : .notPurchased
            }
        }
    }
}
```

- Notice that when the `VStack` appears we asynchronously call `StoreHelper.isPurchased(productId:)` to see if the user has purchased the product 

### Modify ContentView
- Move `ContentView.swift` into the **Shared** folder
- Open `ContentView.swift` and replace the existing code with the following:

```swift
import SwiftUI
import StoreHelper

@available(iOS 15.0, macOS 12.0, *)
struct ContentView: View {
    @State private var showProductInfoSheet = false
    @State private var productId: ProductId = ""
    
    var body: some View {
        Products() { id in
            productId = id
            showProductInfoSheet = true
        }
        .sheet(isPresented: $showProductInfoSheet) {
            VStack {
                // Pull in text and images that explain the particular product identified by `productId`
                ProductInfo(productInfoProductId: $productId, showProductInfoSheet: $showProductInfoSheet)
            }
            #if os(macOS)
            .frame(minWidth: 500, idealWidth: 500, maxWidth: 500, minHeight: 500, idealHeight: 500, maxHeight: 500)
            #endif
        }
    }
}

```

- The above creates the `StoreHelper Products` view. This view displays a list of your configured products (we haven't configured them yet), allow the user to purchase products and see detailed information about purchases
- If the user taps on a product's **More Info** button, the `Products` view provides the unique `ProductId` of that product to our app via a closure. We can then display a view or (as in this example) sheet showing details of the product, and why the user might want to purchase it
- We hand-off the presentation of our product information details to the (as yet undefined) `ProductInfo` view

### Create the ProductInfo View
- Create a new SwiftUI view in the **Shared** folder named `ProductInfo.swift`. Replace the existing code with the following:

```swift
import SwiftUI
import StoreHelper
import StoreKit

@available(iOS 15.0, macOS 12.0, *)
struct ProductInfo: View {
    @EnvironmentObject var storeHelper: StoreHelper
    @State private var product: Product?
    @Binding var productInfoProductId: ProductId
    @Binding var showProductInfoSheet: Bool
    
    var body: some View {
        VStack {
            SheetBarView(showSheet: $showProductInfoSheet, title: product?.displayName ?? "Product Info")
            ScrollView {
                VStack {
                    if let p = product {
                        Image(p.id)
                            .resizable()
                            .frame(maxWidth: 200, maxHeight: 200)
                            .aspectRatio(contentMode: .fit)
                            .cornerRadius(25)
                    }
                    
                    // Pull in the text appropriate for the product
                    switch productInfoProductId {
                        case "com.rarcher.nonconsumable.flowers.large": ProductInfoFlowersLarge()
                        case "com.rarcher.nonconsumable.flowers.small": ProductInfoFlowersSmall()
                        default: ProductInfoDefault()
                    }
                }
                .padding(.bottom)
            }
        }
        .onAppear {
            product = storeHelper.product(from: productInfoProductId)
        }
    }
}

@available(iOS 15.0, macOS 12.0, *)
struct ProductInfoFlowersLarge: View {
    @ViewBuilder var body: some View {
        Text("This is a information about the **Large Flowers** product.").font(.title2).padding().multilineTextAlignment(.center)
        Text("Add text and images explaining this product here.").font(.title3).padding().multilineTextAlignment(.center)
    }
}

@available(iOS 15.0, macOS 12.0, *)
struct ProductInfoFlowersSmall: View {
    @ViewBuilder var body: some View {
        Text("This is a information about the **Small Flowers** product.").font(.title2).padding().multilineTextAlignment(.center)
        Text("Add text and images explaining this product here.").font(.title3).padding().multilineTextAlignment(.center)
    }
}

@available(iOS 15.0, macOS 12.0, *)
struct ProductInfoDefault: View {
    @ViewBuilder var body: some View {
        Text("This is generic information about a product.").font(.title2).padding().multilineTextAlignment(.center)
        Text("Add text and images explaining your product here.").font(.title3).padding().multilineTextAlignment(.center)
    }
}
```

- `ProductInfo` uses `StoreHelper.product(from:)` to retrieve a `StoreKit2 Product` struct, which gives localized information about the product

### Create SubscriptionView
- Create a new SwiftUI view in the **Shared** folder named `SubscriptionView.swift`. Replace the existing code with the following:

```swift
import SwiftUI
import StoreHelper

@available(iOS 15.0, macOS 12.0, *)
struct SubscriptionView: View {
    @EnvironmentObject var storeHelper: StoreHelper
    @State private var productIds: [ProductId]?
    
    var body: some View {
        VStack {
            if let pids = productIds {
                ForEach(pids, id: \.self) { pid in
                    SubscriptionRow(productId: pid)
                    Divider()
                }
                
                Spacer()
            } else {
                if storeHelper.isRefreshingProducts {
                    ProgressView().padding()
                    Text("Getting subscription products...").font(.title).foregroundColor(.blue)
                } else {
                    Text("You don't have any subscription products").font(.title).foregroundColor(.red)
                }
            }
        }
        .padding()
        .onAppear { productIds = storeHelper.subscriptionProductIds }
        .onChange(of: storeHelper.products) {
            productIds = storeHelper.subscriptionProductIds
        }
    }
}

@available(iOS 15.0, macOS 12.0, *)
struct SubscriptionRow: View {
    @EnvironmentObject var storeHelper: StoreHelper
    @State private var subscriptionState: PurchaseState = .unknown
    @State private var isSubscribed = false
    @State private var detailedSubscriptionInfo: ExtendedSubscriptionInfo?
    var productId: ProductId
    
    var body: some View {
        VStack {
            HStack {
                if subscriptionState == .unknown {
                    HStack {
                        ProgressView().padding()
                        Text(productId).foregroundColor(.orange).padding()
                    }
                } else {
                    
                    Text("You are \(isSubscribed ? "" : "not") subscribed to \(productId)")
                        .foregroundColor(isSubscribed ? .green : .red)
                        .multilineTextAlignment(.center)
                        .padding()
                }
            }
        }
        .task {
            isSubscribed = await subscribed(to: productId)
            if isSubscribed {
                subscriptionState = .purchased
                if let subscriptionInfo = await getSubscriptionInfo() {
                    detailedSubscriptionInfo = await getDetailedSubscriptionInfo(for: subscriptionInfo)
                }
            } else {
                subscriptionState = .notPurchased
            }
        }
    }
    
    private func subscribed(to productId: ProductId) async -> Bool {
        let currentlySubscribed = try? await storeHelper.isSubscribed(productId: productId)
        return currentlySubscribed ?? false
    }
    
    private func getSubscriptionInfo() async -> SubInfo? {
        var subInfo: SubInfo?
        
        // Get info on all subscription groups (this demo only has one group called "VIP")
        let subscriptionGroupInfo = await storeHelper.subscriptionHelper.groupSubscriptionInfo()
        if let vipGroup = subscriptionGroupInfo?.first, let product = vipGroup.product {
            // Get subscription info for the subscribed product
            subInfo = storeHelper.subscriptionHelper.subscriptionInformation(for: product, in: subscriptionGroupInfo)
        }
        
        return subInfo
    }
    
    private func getDetailedSubscriptionInfo(for subInfo: SubscriptionInfo) async -> ExtendedSubscriptionInfo? {
        let viewModel = SubscriptionInfoViewModel(storeHelper: storeHelper, subscriptionInfo: subInfo)
        return await viewModel.extendedSubscriptionInfo()
    }
}

```

## Create SimplePurchaseView
- Create a new SwiftUI view in the **Shared** folder named `SimplePurchaseView.swift`. Replace the existing code with the following:

```swift
import SwiftUI
import StoreKit
import StoreHelper

struct SimplePurchaseView: View {
    @EnvironmentObject var storeHelper: StoreHelper
    @State private var purchaseState: PurchaseState = .unknown
    @State private var product: Product?
    let productId = "com.rarcher.nonconsumable.flowers.large"
    
    var body: some View {
        VStack {
            Text("This view shows how to create a minimal purchase page for a product. The product shown is **Large Flowers**").multilineTextAlignment(.center)
            Image(productId)
                .resizable()
                .frame(maxWidth: 250, maxHeight: 250)
                .aspectRatio(contentMode: .fit)
                .cornerRadius(25)
            
            if let product { PurchaseButton(purchaseState: $purchaseState, productId: productId, price: product.displayPrice).padding() }
            
            switch purchaseState {
                case .purchased: Text("This product has already been purchased")
                        .font(.title)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.blue)
                        .padding()
                    
                case .notPurchased: Text("This product is available for purchase")
                        .font(.title)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.green)
                        .padding()
                    
                case .unknown: Text("The purchase state for this product has not been determined")
                        .font(.title)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.orange)
                        .padding()
                    
                default: Text("The purchase state for this product is \(purchaseState.shortDescription().lowercased())")
                        .font(.title)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.red)
                        .padding()
            }
            
            Spacer()
        }
        .padding()
        .task {
            product = storeHelper.product(from: productId)
            let isPurchased = (try? await storeHelper.isPurchased(productId: productId)) ?? false
            purchaseState = isPurchased ? .purchased : .notPurchased
        }
        .onChange(of: storeHelper.purchasedProducts) {
            Task.init {
                let isPurchased = (try? await storeHelper.isPurchased(productId: productId)) ?? false
                purchaseState = isPurchased ? .purchased : .notPurchased
            }
        }
    }
}
```

### Add Product Images
- Select any file in the **StoreHelper > Samples > Images** folder in Xcode, right-click it and select **Show in Finder**
- In Finder, select all images in the **Images** directory and drag them into your project's **Asset Catalog** in Xcode
- These images have filenames that are the same as the product ids for the products which they represent

### Add Product Configuration Files
- Select any file in the **StoreHelper > Samples > Configuration** folder in Xcode, right-click it and select **Show in Finder**
- In Finder, select all files (except readme.md) in the **Configuration** directory and drag them into your project's main folder in Xcode. Select **Copy items if needed** when prompted
- Rename **SampleProducts.plist** to **Products.plist** and **SampleProducts.storekit** to **Products.storekit**
- Select your project's **target** and then select **Product > Scheme> Edit Scheme**
- Select the `Products.storekit` file in the **StoreKit Configuration** field:

![](StoreHelperDemo107.png)

### Run the App
- Select the **iOS target** and run it in the simulator:
    - `MainView` provides navigation to `ContentView` (the products list) and product access views
    - `ContentView` displays a list of products, along with images and descriptions
    - Try purchasing the **Large Flowers** product
    - Your demo app supports a complete range of in-app purchase-related features
    - Try selecting "Large Flowers" from `MainView`. If you've purchased it you should see that you have access, otherwise you'll see a "no access" error 

![](StoreHelperDemo108.png)
