//
//  Button.swift
//  StoreHelper (macOS)
//
//  Created by Russell Archer on 10/12/2021.
//

import SwiftUI

struct macOSButtonStyle: ButtonStyle {
    var foregroundColor: Color = .white
    var backgroundColor: Color = .blue
    var pressedColor: Color = .secondary
    var opacity: Double = 1
    var padding: EdgeInsets = EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
    
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .font(.title2)
            .padding(15)
            .foregroundColor(foregroundColor)
            .background(configuration.isPressed ? pressedColor : backgroundColor).opacity(opacity)
            .cornerRadius(5)
            .padding(padding)
    }
}

extension View {
    func macOSStyle(foregroundColor: Color = .white, backgroundColor: Color = .blue, pressedColor: Color = .secondary, padding: EdgeInsets = EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)) -> some View {
        self.buttonStyle(macOSButtonStyle(foregroundColor: foregroundColor, backgroundColor: backgroundColor, pressedColor: pressedColor, padding: padding))
    }
    
    func macOSTransparentStyle(foregroundColor: Color = .blue, backgroundColor: Color = .white, pressedColor: Color = .secondary) -> some View {
        self.buttonStyle(macOSButtonStyle(foregroundColor: foregroundColor, backgroundColor: backgroundColor, pressedColor: pressedColor, opacity: 0))
    }
}

extension Button {
    func macOSRoundedStyle() -> some View {
        self
            .frame(width: 30, height: 30)
            .buttonStyle(.plain)
            .foregroundColor(Color.white)
            .background(Color.blue)
            .clipShape(Circle())
    }
}

extension Text {
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
