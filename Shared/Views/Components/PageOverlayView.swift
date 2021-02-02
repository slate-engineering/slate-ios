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
    
    init(pickerOptions: [String]?, pickerIndex: Binding<Int>?, @ViewBuilder withTopRight topRight: () -> Content) {
        self.pickerOptions = pickerOptions
        self._pickerIndex = pickerIndex ?? Binding.constant(0)
        self.topRight = topRight()
    }
    
    var body: some View {
        VStack {
            HStack {
                TranslucentButtonView(type: .icon, action: { print("Pressed button") }) {
                    Image("search-semibold")
                        .resizable()
                        .frame(width: 18, height: 18)
                }
                Spacer()
                topRight
            }
            .padding(.top, 12)
            .padding(.horizontal, 20)
            Spacer()
            if pickerOptions != nil {
                Picker("View", selection: $pickerIndex) {
                    ForEach(0..<pickerOptions!.count) {
                        Text(pickerOptions![$0])
                    }
                }
                .background(Blur().clipShape(RoundedRectangle(cornerRadius: 8)))
                .pickerStyle(SegmentedPickerStyle())
                .padding(.bottom, 52)
                .padding(.horizontal, 16)
            }
        }
    }
}

//struct PageOverlayView_Previews: PreviewProvider {
//    static var previews: some View {
//        PageOverlayView()
//    }
//}
