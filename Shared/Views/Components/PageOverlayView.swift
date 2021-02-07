//
//  PageOverlayView.swift
//  Slate iOS (iOS)
//
//  Created by Martina Long on 1/29/21.
//

import SwiftUI

struct PageOverlayView<Content: View>: View {
    let pickerOptions: [String]?
    @Binding var pickerIndex: Int
    var topRight: Content
    var hideTop: Bool
    
    init(pickerOptions: [String]?, pickerIndex: Binding<Int>?, hideTop: Bool = false, @ViewBuilder withTopRight topRight: () -> Content) {
        self.pickerOptions = pickerOptions
        self._pickerIndex = pickerIndex ?? Binding.constant(0)
        self.topRight = topRight()
        self.hideTop = hideTop
    }
    
    var body: some View {
        VStack {
            if !hideTop {
                HStack {
                    TranslucentButtonView(type: .icon) {
                        Image("search-semibold")
                            .resizable()
                            .frame(width: 18, height: 18)
                    }
                    Spacer()
                    topRight
                }
                .padding(.top, 12)
                .padding(.horizontal, 20)
            }
            Spacer()
            if pickerOptions != nil {
                Picker("View", selection: $pickerIndex) {
                    ForEach(0..<pickerOptions!.count) {
                        Text(pickerOptions![$0])
                    }
                }
                .background(Blur().clipShape(RoundedRectangle(cornerRadius: 8)))
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal, Constants.sideMargin)
            }
        }
//        .background(Color.red)
    }
}

//struct PageOverlayView_Previews: PreviewProvider {
//    static var previews: some View {
//        PageOverlayView()
//    }
//}
