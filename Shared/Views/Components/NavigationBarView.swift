//
//  NavigationBarView.swift
//  Slate iOS (iOS)
//
//  Created by Martina Long on 2/3/21.
//

import SwiftUI

struct NavigationBarView<LeftContent: View, RightContent: View>: View {
    var title: String?
    var left: LeftContent
    var right: RightContent
    
    init(title: String? = nil, @ViewBuilder left: () -> LeftContent, @ViewBuilder right: () -> RightContent) {
        self.title = title
        self.left = left()
        self.right = right()
    }
    
    var body: some View {
        HStack {
            left
            Spacer()
            if title != nil {
                Text(title!)
                    .font(Font.custom("Inter", size: 14))
                    .fontWeight(.medium)
            }
            Spacer()
            right
        }
        .padding(12)
        .frame(height: 48)
        .overlay(Rectangle().fill(Color("border")).frame(height: 0.75, alignment: .bottom), alignment: .bottom)
    }
}

//struct NavigationBarView_Previews: PreviewProvider {
//    static var previews: some View {
//        NavigationBarView()
//    }
//}
