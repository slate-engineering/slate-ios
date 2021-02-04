//
//  DataView.swift
//  Slate iOS (iOS)
//
//  Created by Martina Long on 1/25/21.
//

import SwiftUI

struct DataView: View {
    @ObservedObject var viewer: User
    let views = ["Gallery", "Column", "List"]
    @State private var viewIndex = 0
    let singleColumn: [GridItem] = [
        GridItem(.flexible())
    ]
    let doubleColumn: [GridItem] = [
        GridItem(.flexible(), spacing: Constants.sideMargin),
        GridItem(.flexible(), spacing: Constants.sideMargin)
    ]
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                if viewIndex == 2 {
                    ScrollView(.vertical) {
                        Spacer()
                            .frame(height: 52)
                        LazyVStack(spacing: 1) {
                            ForEach(0..<(viewer.files?.count ?? 0)) { index in
                                HStack(spacing: 8) {
                                    FiletypeIconView(type: viewer.files![index].type)
                                        .frame(width: 20, height: 20)
                                        .foregroundColor(Color("black"))
                                    Text(viewer.files![index].name)
                                        .font(Font.custom("Inter", size: 14))
//                                        .fontWeight(.medium)
                                        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .leading)
                                }
                                .padding(10)
                                .background(Color("white"))
                                .frame(height: 40)
                                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .topLeading)
                            }
                        }
                        .shadow(color: Color(red: 178/255, green: 178/255, blue: 178/255).opacity(0.15), radius: 10, x: 0, y: 5)
                        .padding(.horizontal, Constants.sideMargin)
                        Spacer()
                            .frame(height: Constants.bottomMargin)
                    }
                } else {
                    ScrollView(.vertical) {
                        Spacer()
                            .frame(height: 8)
                        LazyVGrid(columns: viewIndex == 0 ? doubleColumn : singleColumn, alignment: .center, spacing: 16) {
                            ForEach(0..<(viewer.files?.count ?? 0)) { index in
                                MediaPreviewView(viewer.files![index], width: (viewIndex == 0 ? (geo.size.width - 48) / 2 : geo.size.width - 32))
                                    .background(Color.white)
                                    .shadow(color: Color(red: 178/255, green: 178/255, blue: 178/255).opacity(0.15), radius: 10, x: 0, y: 5)
                            }
                        }
                        .padding(.horizontal, Constants.sideMargin)
                        Spacer()
                            .frame(height: Constants.bottomMargin)
                    }
                }
                PageOverlayView(pickerOptions: views, pickerIndex: $viewIndex) {
                    TranslucentButtonView(type: .text, action: { print("Pressed button") }) {
                        Text("Upload")
                            .font(Font.custom("Inter", size: 14))
                            .fontWeight(.medium)
                    }
                }
            }
        }
    }
}

struct DataView_Previews: PreviewProvider {
    static var previews: some View {
        DataView(viewer: User())
    }
}
