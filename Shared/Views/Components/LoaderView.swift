//
//  LoaderView.swift
//  Slate iOS (iOS)
//
//  Created by Martina Long on 2/6/21.
//

import SwiftUI

struct LoaderView: View {
    let text: String
    
    init(_ text: String) {
        self.text = text
    }
    
    var body: some View {
        ProgressView(text)
            .padding(16)
            .background(Blur(style: .systemMaterial))
            .clipShape(RoundedRectangle(cornerRadius: 4))
    }
}
