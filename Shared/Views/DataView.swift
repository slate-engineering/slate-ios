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
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
//                if viewIndex == 1 {
//                    ScrollView(.vertical) {
//                        Spacer()
//                            .frame(height: 64)
//                        LazyVStack {
//                            ForEach(0..<viewer.files.count) { index in
//                                MediaPreviewView(viewer.files[index], width: geo.size.width - 32)
//                                    .frame(width: geo.size.width - 32, height: geo.size.width - 32)
//                                    .background(Color.white)
//                                    .shadow(color: Color(red: 178/255, green: 178/255, blue: 178/255).opacity(0.15), radius: 10, x: 0, y: 5)
//                                    .padding(.horizontal, 16)
//                                    .padding(.vertical, 8)
//                            }
//                        }
//                    }
//                }
                if viewIndex == 2 {
                    ScrollView(.vertical) {
                        Spacer()
                            .frame(height: 52)
                        LazyVStack(spacing: 1) {
                            ForEach(0..<(viewer.files?.count ?? 0)) { index in
                                HStack(spacing: 8) {
                                    FiletypeIconView(type: viewer.files![index].type)
                                        .frame(width: 24, height: 24)
                                        .foregroundColor(Color("black"))
                                    Text(viewer.files![index].name)
                                        .font(Font.custom("Inter", size: 14))
                                        .fontWeight(.medium)
                                        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .leading)
                                }
                                .padding(12)
                                .background(Color("white"))
                                .frame(height: 48)
                                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .topLeading)
                            }
                        }
                        .shadow(color: Color(red: 178/255, green: 178/255, blue: 178/255).opacity(0.15), radius: 10, x: 0, y: 5)
                        .padding(.horizontal, 16)
                        Spacer()
                            .frame(height: 96)
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
                        .padding(.horizontal, 16)
                        Spacer()
                            .frame(height: 96)
                    }
                }
                PageOverlayView(pickerOptions: views, pickerIndex: $viewIndex) {
                    TranslucentButtonView(type: .text, action: { print("Pressed button") }) {
                        Text("Upload")
                            .font(Font.custom("Inter", size: 14))
                            .fontWeight(.medium)
                    }
                }
//                VStack {
//                    HStack {
//                        TranslucentButtonView(type: .icon, action: { print("Pressed button") }) {
//                            Image("search-semibold")
//                                .resizable()
//                                .frame(width: 18, height: 18)
//                        }
//
//                        Spacer()
//                        TranslucentButtonView(type: .text, action: { print("Pressed button") }) {
//                            Text("Upload")
//                                .font(Font.custom("Inter", size: 14))
//                                .fontWeight(.medium)
//                        }
//                    }
//                    .padding(.top, 12)
//                    .padding(.horizontal, 20)
//                    Spacer()
//                    Picker("View", selection: $viewIndex) {
//                        ForEach(0..<views.count) {
//                            Text(views[$0])
//                        }
//                    }
//                    .background(Blur().clipShape(RoundedRectangle(cornerRadius: 8)))
//                    .pickerStyle(SegmentedPickerStyle())
//                    .padding(.bottom, 52)
//                    .padding(.horizontal, 16)
//                }
            }
        }
    }
}

struct DataView_Previews: PreviewProvider {
    static var previews: some View {
        DataView(viewer: User())
    }
}
