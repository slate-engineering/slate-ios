//
//  ComponentStyles.swift
//  Slate iOS (iOS)
//
//  Created by Martina Long on 1/21/21.
//

import SwiftUI

//extension View {
//    @ViewBuilder
//    func `if`<Content: View>(_ condition: Bool, content: (Self) -> Content) -> some View {
//        if condition {
//            content(self)
//        }
//        else {
//            self
//        }
//    }
//}

//extension Button {
//    func buttonPrimary() -> some View {
//        self
//            .frame(height: 40)
//            .background(Color("brand"))
//            .foregroundColor(Color("white"))
//            .cornerRadius(4)
//    }
//}

extension Text {
    func textStyle() -> Text {
        self
            .font(Font.custom("Inter", size: 14))
    }
    
    func sectionHeaderStyle() -> Text {
        self
            .font(Font.custom("Inter", size: 12))
            .foregroundColor(Color("grayBlack"))
            .fontWeight(.semibold)
    }
}
