//
//  SlateView.swift
//  Slate iOS (iOS)
//
//  Created by Martina Long on 1/29/21.
//

import SwiftUI

struct SlateView: View {
    var user: User
    var slate: Slate
    var username: String? {
        if let username = slate.user?.data.name ?? slate.user?.username {
            return username
        }
        if slate.data.ownerId == user.id {
            return user.data.name ?? "@\(user.username)"
        }
        return nil
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            GeometryReader { geo in
                ScrollView(.vertical) {
                    Spacer()
                        .frame(height: Constants.bottomMargin)
                    VStack(alignment: .leading, spacing: 4) {
                        Text(slate.data.name).font(Font.custom("Inter", size: 22)).fontWeight(.medium)
                        if username != nil {
                            Text(username!).font(Font.custom("Inter", size: 14))
                        }
                        if slate.data.body != nil {
                            Text(slate.data.body!)
                                .font(Font.custom("Inter", size: 14))
                                .foregroundColor(Color("darkGray"))
                                .padding(.top, 4)
                        }
                    }
                    .padding(.bottom, 16)
                    .padding(.horizontal, Constants.sideMargin)
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .topLeading)
                    LazyVStack {
                        ForEach(0..<slate.data.objects.count) { index in
                            MediaPreviewView(slate.data.objects[index], width: geo.size.width - 32, contentMode: .fit)
//                                .shadow(color: Color(red: 178/255, green: 178/255, blue: 178/255).opacity(0.15), radius: 10, x: 0, y: 5)
                                .frame(width: geo.size.width - 32, height: geo.size.width - 32)
                                .padding(.vertical, 8)
                                .padding(.horizontal, Constants.sideMargin)
                        }
                    }
                    Spacer()
                        .frame(height: Constants.bottomMargin)
                }.frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .topLeading)
            }
            Spacer()
        }
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .topLeading)
        .background(Color("foreground"))
        .edgesIgnoringSafeArea(.all)
//        .navigationBarTitle(slate.data.name)
//        .navigationBarHidden(true)
    }
}

//struct SlateView_Previews: PreviewProvider {
//    static var previews: some View {
//        SlateView()
//    }
//}
