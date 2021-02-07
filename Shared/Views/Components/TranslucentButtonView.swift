//
//  TranslucentButtonView.swift
//  Slate iOS (iOS)
//
//  Created by Martina Long on 1/29/21.
//

import SwiftUI

struct TranslucentButtonView<Content: View>: View {
    enum ButtonType {
        case icon, text
    }
    
    let content: Content
    let action: () -> Void
    let buttonType: ButtonType
    
    init(type: ButtonType, action: @escaping () -> Void = { print("button clicked") }, @ViewBuilder content: () -> Content) {
        self.content = content()
        self.action = action
        self.buttonType = type
    }
    
    var body: some View {
        Button(action: self.action) {
            content
                .padding(.horizontal, buttonType == .text ? 12 : 0)
                .frame(width: buttonType == .text ? nil : 32, height: 32)
                .background(Blur(style: .systemMaterial))
                .foregroundColor(Color("grayBlack"))
                .clipShape(RoundedRectangle(cornerRadius: 100))
                .contentShape(RoundedRectangle(cornerRadius: 100))
        }
    }
}

struct TranslucentButtonView_Previews: PreviewProvider {
    static var previews: some View {
        TranslucentButtonView(type: .text, action: { print("Pressed button") }) {
            Text("Upload")
                .font(Font.custom("Inter", size: 14))
                .fontWeight(.medium)
        }
    }
}
