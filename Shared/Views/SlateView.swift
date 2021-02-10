//
//  SlateView.swift
//  Slate iOS (iOS)
//
//  Created by Martina Long on 1/29/21.
//

import SwiftUI

struct SlateView: View {
    @EnvironmentObject var viewer: User
//    var user: User?
    @ObservedObject var slate: Slate
    var username: String? {
        if let username = slate.user?.data.name ?? slate.user?.username {
            return username
        }
        if slate.data.ownerId == viewer.id {
            return viewer.data.name ?? "@\(viewer.username)"
        }
        return nil
    }
    @State private var isFollowing: Bool = false
    var isOwner: Bool {
        slate.data.ownerId == viewer.id
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            GeometryReader { geo in
                ScrollView(.vertical) {
                    Spacer()
                        .frame(height: Constants.bottomMargin)
                    VStack(alignment: .leading, spacing: 6) {
                        HStack(spacing: 16) {
                            Text(slate.data.name).font(Font.custom("Inter", size: 22)).fontWeight(.medium)
                            if !isOwner {
                                TranslucentButtonView(type: .text, action: {}) {
                                    Text(isFollowing ? "Unfollow" : "Follow")
                                        .font(Font.custom("Inter", size: 14))
                                        .fontWeight(.medium)
                                        .onTapGesture {
                                            isFollowing = !isFollowing
                                            Actions.subscribeSlate(id: slate.id) {
                                                Actions.rehydrateSocial(viewer: viewer)
                                            }
                                        }
                                }
                            }
                        }
                        if username != nil && !isOwner {
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
        .onAppear {
            determineFollowing()
            Actions.getSerializedSlate(id: slate.id) { slate in
                Utilities.copySlateDetails(to: self.slate, from: slate)
            }
        }
//        .navigationBarTitle(slate.data.name)
//        .navigationBarHidden(true)
    }
    
    func determineFollowing() {
        var isFollowing = false
        if let subscriptions = viewer.subscriptions {
            for sub in subscriptions {
                if let subSlate = sub.slate {
                    if subSlate.id == slate.id {
                        isFollowing = true
                        break
                    }
                }
            }
        }
        self.isFollowing = isFollowing
    }
}

//struct SlateView_Previews: PreviewProvider {
//    static var previews: some View {
//        SlateView()
//    }
//}
