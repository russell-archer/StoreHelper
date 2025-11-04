//
//  Fonts.swift
//  StoreHelper
//
//  Created by Russell Archer on 22/03/2022.
//


import SwiftUI

@available(iOS 15.0, macOS 12.0, *)
public struct Caption2Font<Content: View>: View {
    private var scaleFactor: Double
    private let content: () -> Content
    
    public init(scaleFactor: Double, @ViewBuilder content: @escaping () -> Content) {
        self.scaleFactor = scaleFactor
        self.content = content
    }
    
    public var body: some View { content().font(.system(size: FontUtil.scale(for: .caption2, and: scaleFactor)))}
}

@available(iOS 15.0, macOS 12.0, *)
public struct CaptionFont<Content: View>: View {
    private var scaleFactor: Double
    private let content: () -> Content
    
    public init(scaleFactor: Double, @ViewBuilder content: @escaping () -> Content) {
        self.scaleFactor = scaleFactor
        self.content = content
    }
    
    public var body: some View { content().font(.system(size: FontUtil.scale(for: .caption, and: scaleFactor)))}
}

@available(iOS 15.0, macOS 12.0, *)
public struct FootnoteFont<Content: View>: View {
    private var scaleFactor: Double
    private let content: () -> Content
    
    public init(scaleFactor: Double, @ViewBuilder content: @escaping () -> Content) {
        self.scaleFactor = scaleFactor
        self.content = content
    }
    
    public var body: some View { content().font(.system(size: FontUtil.scale(for: .footnote, and: scaleFactor)))}
}

@available(iOS 15.0, macOS 12.0, *)
public struct SubHeadlineFont<Content: View>: View {
    private var scaleFactor: Double
    private let content: () -> Content
    
    public init(scaleFactor: Double, @ViewBuilder content: @escaping () -> Content) {
        self.scaleFactor = scaleFactor
        self.content = content
    }
    
    public var body: some View { content().font(.system(size: FontUtil.scale(for: .subheadline, and: scaleFactor)))}
}

@available(iOS 15.0, macOS 12.0, *)
public struct CalloutFont<Content: View>: View {
    private var scaleFactor: Double
    private let content: () -> Content
    
    public init(scaleFactor: Double, @ViewBuilder content: @escaping () -> Content) {
        self.scaleFactor = scaleFactor
        self.content = content
    }
    
    public var body: some View { content().font(.system(size: FontUtil.scale(for: .callout, and: scaleFactor)))}
}

@available(iOS 15.0, macOS 12.0, *)
public struct BodyFont<Content: View>: View {
    private var scaleFactor: Double
    private let content: () -> Content
    
    public init(scaleFactor: Double, @ViewBuilder content: @escaping () -> Content) {
        self.scaleFactor = scaleFactor
        self.content = content
    }
    
    public var body: some View { content().font(.system(size: FontUtil.scale(for: .body, and: scaleFactor)))}
}

@available(iOS 15.0, macOS 12.0, *)
public struct Title3Font<Content: View>: View {
    private var scaleFactor: Double
    private let content: () -> Content
    
    public init(scaleFactor: Double, @ViewBuilder content: @escaping () -> Content) {
        self.scaleFactor = scaleFactor
        self.content = content
    }
    
    public var body: some View { content().font(.system(size: FontUtil.scale(for: .title3, and: scaleFactor)))}
}

@available(iOS 15.0, macOS 12.0, *)
public struct Title2Font<Content: View>: View {
    private var scaleFactor: Double
    private let content: () -> Content
    
    public init(scaleFactor: Double, @ViewBuilder content: @escaping () -> Content) {
        self.scaleFactor = scaleFactor
        self.content = content
    }
    
    public var body: some View { content().font(.system(size: FontUtil.scale(for: .title2, and: scaleFactor )))}
}

@available(iOS 15.0, macOS 12.0, *)
public struct HeadlineFont<Content: View>: View {
    private var scaleFactor: Double
    private let content: () -> Content
    
    public init(scaleFactor: Double, @ViewBuilder content: @escaping () -> Content) {
        self.scaleFactor = scaleFactor
        self.content = content
    }
    
    public var body: some View { content().font(.system(size: FontUtil.scale(for: .headline, and: scaleFactor)))}
}

@available(iOS 15.0, macOS 12.0, *)
public struct TitleFont<Content: View>: View {
    private var scaleFactor: Double
    private let content: () -> Content
    
    public init(scaleFactor: Double, @ViewBuilder content: @escaping () -> Content) {
        self.scaleFactor = scaleFactor
        self.content = content
    }
    
    public var body: some View { content().font(.system(size: FontUtil.scale(for: .title, and: scaleFactor)))}
}

@available(iOS 15.0, macOS 12.0, *)
public struct LargeTitleFont<Content: View>: View {
    private var scaleFactor: Double
    private let content: () -> Content
    
    public init(scaleFactor: Double, @ViewBuilder content: @escaping () -> Content) {
        self.scaleFactor = scaleFactor
        self.content = content
    }
    
    public var body: some View { content().font(.system(size: FontUtil.scale(for: .largeTitle, and: scaleFactor)))}
}

@available(iOS 15.0, macOS 12.0, *)
public struct CustomFont<Content: View>: View {
    @Environment(\.dynamicTypeSize) var dynamicTypeSize
    private var scaleFactor:        Double
    private var name:               String
    private var baseSize:           Double
    private let content:            () -> Content
    
    public init(name: String, baseSize: Double, scaleFactor: Double, @ViewBuilder content: @escaping () -> Content) {
        self.name        = name
        self.baseSize    = baseSize
        self.scaleFactor = scaleFactor
        self.content     = content
    }
    
    public var body: some View { content().font(.custom(name, size: baseSize + (scaleFactor - FontUtil.baseDynamicTypeSize(for: dynamicTypeSize))))}
}

@available(iOS 15.0, macOS 12.0, *)
public struct FontUtil {
    /// The point size of the body font for a particular dynamic type size.
    /// See "Dynamic Type Sizes": https://developer.apple.com/design/human-interface-guidelines/ios/visual-design/typography/
    /// - Parameter dynamicTypeSize: The environment's dynamic type size.
    /// - Returns: Returns the point size of the body font for a dynamic type size.
    public static func baseDynamicTypeSize(for dynamicTypeSize: DynamicTypeSize) -> Double {
        switch(dynamicTypeSize) {
            case .xSmall:           return 14
            case .small:            return 15
            case .medium:           return 16
            case .large:            return 17  // Default
            case .xLarge:           return 19
            case .xxLarge:          return 21
            case .xxxLarge:         return 23
            case .accessibility1:   return 28
            case .accessibility2:   return 33
            case .accessibility3:   return 40
            case .accessibility4:   return 47
            case .accessibility5:   return 53
            @unknown default:       return 17
        }
    }
    
    public static func scale(for style: Font.TextStyle, and scaledBy: Double) -> CGFloat {
        switch style {
            case .caption2:     return scaledBy * 0.5
            case .caption:      return scaledBy * 0.6
            case .footnote:     return scaledBy * 0.7
            case .subheadline:  return scaledBy * 0.8
            case .callout:      return scaledBy * 0.9
            case .body:         return scaledBy * 1.0
            case .title3:       return scaledBy * 1.1
            case .title2:       return scaledBy * 1.2
            case .headline:     return scaledBy * 1.3
            case .title:        return scaledBy * 1.5
            case .largeTitle:   return scaledBy * 2.0
            @unknown default:   return scaledBy * 1.0
        }
    }
}

@available(iOS 15.0, macOS 12.0, *)
public struct TextBlockLeft<Content: View>: View {
    private let content: () -> Content
    
    public init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }
    
    public var body: some View {
        HStack {
            Group(content: content)
            Spacer()
        }
    }
}

