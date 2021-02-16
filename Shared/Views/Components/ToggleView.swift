//
//  ToggleView.swift
//  Slate iOS (iOS)
//
//  Created by Martina Long on 2/10/21.
//

import SwiftUI

struct ToggleView: View {
    let title: String
    @Binding var isOn: Bool
    
    init(_ title: String, isOn: Binding<Bool>) {
        self.title = title
        self._isOn = isOn
    }
    
    var body: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 14)
                .fill(isOn ? Color(red: 51/255, green: 51/255, blue: 51/255) : Color(red: 221/255, green: 221/255, blue: 221/255))
                .frame(width: 44, height: 28)
                .clipShape(RoundedRectangle(cornerRadius: 14))
            Circle()
                .fill(Color.white)
                .frame(width: 20, height: 20)
                .padding(4)
                .offset(x: isOn ? 16 : 0)
        }
        .animation(.easeOut(duration: 0.1))
        .onTapGesture { self.isOn.toggle() }
    }
}
