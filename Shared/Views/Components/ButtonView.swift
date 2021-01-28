//
//  ButtonView.swift
//  Slate iOS (iOS)
//
//  Created by Martina Long on 1/21/21.
//

import SwiftUI

struct ButtonView<Content: View>: View {
    enum ButtonStyle {
        case primary, secondary, tertiary, disabled, warning
    }
    
    let style: ButtonStyle
    let content: Content
    let action: () -> Void
    
    init(_ style: ButtonStyle, action: @escaping () -> Void, @ViewBuilder content: () -> Content) {
        self.style = style
        self.content = content()
        self.action = action
    }
    
    var body: some View {
        Button(action: self.action) {
            HStack {
                Spacer()
                content
                Spacer()
            }
            .padding(.horizontal, 40)
            .frame(height: 40)
            .background(style == .primary ? Color("brand") : style == .disabled ? Color("foreground") : Color("white"))
            .foregroundColor(style == .primary ? Color("white") : style == .secondary ? Color("brand") : style == .tertiary ? Color("black") : style == .warning ? Color("red") : Color("textGrayLight"))
            .clipShape(RoundedRectangle(cornerRadius: 4))
            .overlay(RoundedRectangle(cornerRadius: 4).stroke(style == .primary || style == .disabled ? Color("transparent") : Color("bgGray"), lineWidth: 1))
            .contentShape(RoundedRectangle(cornerRadius: 4))
        }
        .disabled(style == .disabled)
    }
    
    func primaryStyle() -> some View {
        self
            .background(Color("brand"))
            .foregroundColor(Color("white"))
    }
}

struct ButtonView_Previews: PreviewProvider {
    static var previews: some View {
        ButtonView(.warning, action: { print("hi") }) {
            Text("Sign up")
                .font(Font.custom("Inter", size: 14))
                .fontWeight(.semibold)
        }
    }
}
