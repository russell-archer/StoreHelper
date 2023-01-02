//
//  Buttons.swift
//  StoreHelper
//
//  Created by Russell Archer on 10/12/2021.
//

import SwiftUI

@available(iOS 15.0, macOS 12.0, *)
public extension View {
    func xPlatformButtonStyleBorderless() -> some View { self.buttonStyle(.borderless) }
    
    func xPlatformButtonStyleBorderedProminent(foregroundColor: Color = .white,
                                               backgroundColor: Color = .blue,
                                               pressedColor: Color = .secondary,
                                               padding: EdgeInsets = EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)) -> some View {
        
        #if os(iOS)
        self.buttonStyle(.borderedProminent)
        #else
        self.buttonStyle(macOSButtonStyle(foregroundColor: foregroundColor, backgroundColor: backgroundColor, pressedColor: pressedColor, padding: padding))
        #endif
    }
}

#if os(macOS)
@available(macOS 12.0, *)
public struct macOSButtonStyle: ButtonStyle {
    var foregroundColor: Color = .white
    var backgroundColor: Color = .blue
    var pressedColor: Color = .secondary
    var opacity: Double = 1
    var padding: EdgeInsets = EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
    var scaleFactor: Double = FontUtil.baseDynamicTypeSize(for: .large)
    
    public init(foregroundColor: Color = .white,
                backgroundColor: Color = .blue,
                pressedColor: Color = .secondary,
                opacity: Double = 1,
                padding: EdgeInsets = EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10),
                scaleFactor: Double = FontUtil.baseDynamicTypeSize(for: .large)) {
        
        self.foregroundColor = foregroundColor
        self.backgroundColor = backgroundColor
        self.pressedColor = pressedColor
        self.opacity = opacity
        self.padding = padding
        self.scaleFactor = scaleFactor
    }
    
    public func makeBody(configuration: Self.Configuration) -> some View {
        Title2Font(scaleFactor: self.scaleFactor) { configuration.label }
            .padding(15)
            .foregroundColor(foregroundColor)
            .background(configuration.isPressed ? pressedColor : backgroundColor).opacity(opacity)
            .cornerRadius(5)
            .padding(padding)
    }
}

@available(macOS 12.0, *)
public extension View {
    func macOSStyle(foregroundColor: Color = .white, backgroundColor: Color = .blue, pressedColor: Color = .secondary, padding: EdgeInsets = EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)) -> some View {
        self.buttonStyle(macOSButtonStyle(foregroundColor: foregroundColor, backgroundColor: backgroundColor, pressedColor: pressedColor, padding: padding))
    }
    
    func macOSTransparentStyle(foregroundColor: Color = .blue, backgroundColor: Color = .white, pressedColor: Color = .secondary) -> some View {
        self.buttonStyle(macOSButtonStyle(foregroundColor: foregroundColor, backgroundColor: backgroundColor, pressedColor: pressedColor, opacity: 0))
    }
}

@available(macOS 12.0, *)
public extension Button {
    func macOSRoundedStyle() -> some View {
        self
            .frame(width: 30, height: 30)
            .buttonStyle(.plain)
            .foregroundColor(Color.white)
            .background(Color.blue)
            .clipShape(Circle())
    }
}

@available(macOS 12.0, *)
public extension Text {
    func macOSNarrowButtonStyle() -> some View {
        self
            .frame(width: 100, height: 40)
            .buttonStyle(.plain)
            .foregroundColor(Color.white)
            .background(Color.blue)
            .clipShape(RoundedRectangle(cornerRadius: 10))
    }
    
    func macOSNarrowButtonStyle(disabled: Bool = false) -> some View {
        self
            .frame(width: 100, height: 40)
            .buttonStyle(.plain)
            .foregroundColor(disabled ? Color.secondary : Color.white)
            .background(disabled ? Color.gray : Color.blue)
            .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}
#endif
