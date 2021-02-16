//
//  RadioButtonView.swift
//  Slate iOS (iOS)
//
//  Created by Martina Long on 2/10/21.
//

import SwiftUI

struct RadioButtonView: View {
    var options: [String]
    @Binding var selectedIndex: Int
    
    var body: some View {
        VStack {
            ForEach(0..<options.count) { index in
                HStack {
                    Text(options[index])
                        .textStyle()
                    Spacer()
                    ZStack {
                        Circle()
                            .foregroundColor(Color("bgGray"))
                            .frame(width: 24, height: 24)
                        if index == selectedIndex {
                            Circle()
                                .foregroundColor(Color("white"))
                                .frame(width: 16, height: 16)
                                .shadow(color: Color.black.opacity(0.3), radius: 2)
                        }
                    }
                    .clipShape(Circle())
                    .onTapGesture { selectedIndex = index }
                }
            }
        }
    }
}

struct RadioButtonView_Previews: PreviewProvider {
    static var previews: some View {
        RadioButtonView(options: ["Public", "Private"], selectedIndex: .constant(1))
    }
}
