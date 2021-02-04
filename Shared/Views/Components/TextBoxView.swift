//
//  TextBoxView.swift
//  Slate iOS (iOS)
//
//  Created by Martina Long on 2/3/21.
//

import SwiftUI
import UIKit

struct TextBox: UIViewRepresentable {
    @Binding var text: String
    let attributes: [NSAttributedString.Key: NSObject]
    
    init(text: Binding<String>) {
        self._text = text
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 2
        self.attributes = [NSAttributedString.Key.paragraphStyle: style, NSAttributedString.Key.font: UIFont(name:"Inter", size: 14)!]
    }
    
    func makeUIView(context: Context) -> UITextView {
        let view = UITextView()
        view.textContainerInset = .zero
        view.textContainer.lineFragmentPadding = 0
        view.contentInset = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)
        view.attributedText = NSAttributedString(string: text, attributes: self.attributes)
        view.delegate = context.coordinator
        return view
    }
    
    func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.text = text
        let selectedRange = uiView.selectedRange
        uiView.attributedText = NSAttributedString(string: text, attributes: self.attributes)
        uiView.selectedRange = selectedRange
    }
    
    func makeCoordinator() -> TextBox.Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UITextViewDelegate {
        var parent: TextBox
        
        init(_ parent: TextBox) {
            self.parent = parent
        }
        
        func textViewDidChange(_ textView: UITextView) {
            parent.text = textView.text
        }
    }
}

struct TextBoxView: View {
    let title: String
    @Binding var text: String
    
    init(_ title: String, text: Binding<String>) {
        self.title = title
        self._text = text
    }
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            TextBox(text: $text)
            if text.isEmpty {
                Text(title)
                    .font(Font.custom("Inter", size: 14))
                    .foregroundColor(Color(red: 200/255, green: 200/255, blue: 200/255))
                    .padding(.top, 12)
                    .padding(.horizontal, 16)
            }
        }
        .overlay(RoundedRectangle(cornerRadius: 4).stroke(Color("bgGray"), lineWidth: 1))
    }
}
