//
//  InputView.swift
//  Slate iOS (iOS)
//
//  Created by Martina Long on 1/21/21.
//

import SwiftUI
import Combine

struct InputView: View {
    let title: String
    @Binding var text: String
    var onCommit: (() -> Void)?
    
    init(_ title: String, text: Binding<String>, onCommit: (() -> Void)? = nil) {
        self.title = title
        self._text = text
        self.onCommit = onCommit
    }
    
    var body: some View {
        TextField(title, text: $text)
            .font(Font.custom("Inter", size: 14))
            .disableAutocorrection(true)
            .autocapitalization(.none)
            .padding(.horizontal, 16)
            .frame(height: 40)
            .overlay(RoundedRectangle(cornerRadius: 4).stroke(Color("bgGray"), lineWidth: 1))
    }
}

struct SecureInputView: View {
    let title: String
    @Binding var text: String
    var onCommit: (() -> Void)?
    
    init(_ title: String, text: Binding<String>, onCommit: (() -> Void)? = nil) {
        self.title = title
        self._text = text
        self.onCommit = onCommit
    }
    
    var body: some View {
        SecureField(title, text: $text)
            .font(Font.custom("Inter", size: 14))
            .padding(.horizontal, 16)
            .frame(height: 40)
            .overlay(RoundedRectangle(cornerRadius: 4).stroke(Color("bgGray"), lineWidth: 1))
    }
}

struct InputView_Previews: PreviewProvider {
    static var previews: some View {
        InputView("Username", text: .constant("username"))
    }
}
