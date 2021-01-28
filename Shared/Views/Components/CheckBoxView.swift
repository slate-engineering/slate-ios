//
//  CheckBoxView.swift
//  Slate iOS (iOS)
//
//  Created by Martina Long on 1/22/21.
//

import SwiftUI

struct CheckBoxView: View {
    @Binding var isChecked: Bool
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 4)
                .fill(Color(isChecked ? "brand" : "white"))
                .frame(width: 24, height: 24)
                .overlay(RoundedRectangle(cornerRadius: 4).stroke(Color(isChecked ? "transparent" : "darkGray"), lineWidth: 1))
                .onTapGesture { isChecked.toggle() }
            if isChecked {
                Image("check")
                    .resizable()
                    .frame(width: 16, height: 16)
                    .foregroundColor(Color("white"))
            }
        }
    }
}

struct CheckBoxView_Previews: PreviewProvider {
    static var previews: some View {
        CheckBoxView(isChecked: .constant(true))
    }
}
