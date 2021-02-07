//
//  EmptyStateView.swift
//  Slate iOS (iOS)
//
//  Created by Martina Long on 2/6/21.
//

import SwiftUI

struct EmptyStateView: View {
    var text: String
    var icon: Image
    
    init(text: String, icon: Image) {
        self.text = text
        self.icon = icon
    }
    
    var body: some View {
        GeometryReader { geo in
            VStack(spacing: 16) {
                icon
                    .resizable()
                    .frame(width: 24, height: 24)
                    .foregroundColor(Color("darkGray"))
                Text(text)
                    .textStyle()
                    .foregroundColor(Color("darkGray"))
            }
                .padding(32)
            .frame(width: geo.size.width, height: geo.size.width)
//                .overlay(RoundedRectangle(cornerRadius: 4).stroke(Color("border"), lineWidth: 1))
        }
        
    }
}
