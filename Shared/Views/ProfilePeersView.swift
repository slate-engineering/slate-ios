//
//  ProfilePeersView.swift
//  Slate iOS (iOS)
//
//  Created by Martina Long on 2/9/21.
//

import SwiftUI

struct ProfilePeersView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var viewer: User
    @ObservedObject var user: User
    @Binding var socialLoading: Bool
    var following: [User] {
        if let subscriptions = user.subscriptions {
            return subscriptions.filter { return $0.user != nil }
                .map { $0.user! }
        }
        return [User]()
    }
    var followers: [User] {
        if let subscribers = user.subscribers {
            return subscribers.filter { return $0.owner != nil }
                .map { $0.owner! }
        }
        return [User]()
    }
    let views = ["Following", "Followers"]
    @State private var viewIndex = 0
    
    
    var body: some View {
        ZStack {
            if viewIndex == 0 {
                if following.count > 0 {
                    ScrollView(.vertical) {
                        Spacer()
                            .frame(height: 64)
                        VStack {
                            ForEach(0..<following.count) { index in
                                NavigationLink(destination: ProfileView(user: following[index]).environmentObject(viewer)) {
                                    UserEntryView(user: following[index])
                                }
                            }
                        }
                        .padding(.horizontal, Constants.sideMargin)
                        Spacer()
                            .frame(height: Constants.bottomMargin)
                    }
                } else {
                    EmptyStateView(text: "This user is not following anyone", icon: Image("user"))
                        .padding(.horizontal, 16)
                }
            } else {
                if followers.count > 0 {
                    ScrollView(.vertical) {
                        Spacer()
                            .frame(height: 64)
                        VStack {
                            ForEach(0..<followers.count) { index in
                                NavigationLink(destination: ProfileView(user: followers[index]).environmentObject(viewer)) {
                                    UserEntryView(user: followers[index])
                                }
                            }
                        }
                        .padding(.horizontal, Constants.sideMargin)
                        Spacer()
                            .frame(height: Constants.bottomMargin)
                    }
                } else {
                    EmptyStateView(text: "This user has no followers", icon: Image("user"))
                        .padding(.horizontal, 16)
                }
            }
            
            PageOverlayView(pickerOptions: views, pickerIndex: $viewIndex, style: .hideTop) { Spacer() }
                .padding(.bottom, 32)
            
            if socialLoading {
                LoaderView("Loading")
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color("foreground"))
        .edgesIgnoringSafeArea(.all)
//        .navigationBarBackButtonHidden(true)
//        .navigationBarItems {
//            Text("Back").onTapGesture { presentationMode.wrappedValue.dismiss() }
//        }
        .onAppear {
            if socialLoading {
                Actions.getUserSocial(id: user.id, completion: saveUserSocial)
            }
        }
    }
    
    func saveUserSocial(_ subscriptions: [Subscription], _ subscribers: [Subscription]) {
        DispatchQueue.main.async {
            self.user.subscriptions = subscriptions
            self.user.subscribers = subscribers
            self.socialLoading = false
        }
    }
}
