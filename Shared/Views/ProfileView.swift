//
//  ProfileView.swift
//  Slate iOS (iOS)
//
//  Created by Martina Long on 2/6/21.
//

import SwiftUI

struct ProfileView: View {
    @ObservedObject var user: User
    var slatesFollowing: [Slate] {
        if let subscriptions = user.subscriptions {
            return subscriptions.filter { return $0.slate != nil }
                .map { $0.slate! }
        }
        return [Slate]()
    }
    let pickerOptions = ["Files", "Slates", "Favorited"]
    let doubleColumn: [GridItem] = [
        GridItem(.flexible(), spacing: Constants.sideMargin),
        GridItem(.flexible(), spacing: Constants.sideMargin)
    ]
    @State private var pickerIndex = 0
    @State private var loading = true
    @State private var socialLoading = true
    
    var body: some View {
        NavigationView {
            ZStack {
                GeometryReader { geo in
                    VStack {
                        VStack {
                            Spacer()
                                .frame(height: Constants.topMargin)
                            ImageView(withURL: user.data.photo ?? Constants.profileImageDefault, width: 64, height: 64)
                                .background(Color("white"))
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                            Text(user.data.name != nil && !user.data.name!.isEmpty ? user.data.name! : "@\(user.username)")
                                .font(Font.custom("Inter", size: 18))
                                .fontWeight(.medium)
                            if user.data.body != nil && !user.data.body!.isEmpty {
                                Text(user.data.body!)
                                    .font(Font.custom("Inter", size: 14))
                                    .multilineTextAlignment(.center)
                                    .foregroundColor(Color("darkGray"))
                                    .padding(.top, 2)
                            }
                            HStack(spacing: 16) {
                                Text("\(user.files?.count ?? 0) file\(user.files?.count ?? 0 == 1 ? "" : "s")")
                                    .font(Font.custom("Inter", size: 14))
                                    .foregroundColor(Color("grayBlack"))
                                    .frame(minWidth: 64, alignment: .trailing)
                                TranslucentButtonView(type: .text) {
                                    Text("Peers")
                                        .font(Font.custom("Inter", size: 14))
                                }
                                .frame(minWidth: 64, alignment: .leading)
                            }
                            .padding(.top, 4)
                        }
                        .padding(.horizontal, Constants.sideMargin)
                        .padding(.bottom, 24)
                        .frame(maxWidth: .infinity)
                        
                        if pickerIndex == 0 {
                            if user.files != nil && user.files!.count > 0 {
                                ScrollView(.vertical) {
                                    Spacer()
                                        .frame(height: 8)
                                    LazyVGrid(columns: doubleColumn, alignment: .center, spacing: 16) {
                                        ForEach(user.files!) { file in
                                            MediaPreviewView(file, width: (geo.size.width - 48) / 2)
                                                .background(Color.white)
                                                .shadow(color: Color(red: 178/255, green: 178/255, blue: 178/255).opacity(0.15), radius: 10, x: 0, y: 5)
                                        }
                                    }
                                    .padding(.horizontal, Constants.sideMargin)
                                    Spacer()
                                        .frame(height: Constants.bottomMargin)
                                }
                            } else if !loading {
                                EmptyStateView(text: "This user has no public files", icon: Image("folder"))
                                    .padding(.horizontal, 16)
                            }
                        } else if pickerIndex == 1 {
                            if user.slates != nil && user.slates!.count > 0 {
                                ScrollView(.vertical) {
                                    Spacer()
                                        .frame(height: 8)
                                    VStack(spacing: 16) {
                                        ForEach(user.slates!) { slate in
                                            NavigationLink(destination: SlateView(user: user, slate: slate)) {
                                                SlatePreviewView(slate: slate)
                                                    .padding(.horizontal, Constants.sideMargin)
                                                    .frame(width: geo.size.width, height: 0.75 * geo.size.width + 46)
                                            }
                                        }
                                    }
                                    Spacer()
                                        .frame(height: Constants.bottomMargin)
                                }
                            } else if !loading {
                                EmptyStateView(text: "This user has no public slates", icon: Image("box"))
                                    .padding(.horizontal, 16)
                            }
                        } else {
                            if !socialLoading && slatesFollowing.count == 0 {
                                EmptyStateView(text: "This user is not following any slates", icon: Image("box"))
                                    .padding(.horizontal, 16)
                            } else {
                                ScrollView(.vertical) {
                                    Spacer()
                                        .frame(height: 8)
                                    VStack(spacing: 16) {
                                        ForEach(slatesFollowing) { slate in
                                            NavigationLink(destination: SlateView(user: user, slate: slate)) {
                                                SlatePreviewView(slate: slate)
                                                    .padding(.horizontal, Constants.sideMargin)
                                                    .frame(width: geo.size.width, height: 0.75 * geo.size.width + 46)
                                            }
                                        }
                                    }
                                    Spacer()
                                        .frame(height: Constants.bottomMargin)
                                }
                                .onAppear {
                                    if socialLoading {
                                        Actions.getUserSocial(id: user.id, completion: saveUserSocial)
                                    }
                                }
                            }
                        }
                    }
                }
                
                PageOverlayView(pickerOptions: pickerOptions, pickerIndex: $pickerIndex) {
                    TranslucentButtonView(type: .text, action: {
                                            print("follow button clicked")
                    }) {
                        Text("Follow")
                            .font(Font.custom("Inter", size: 14))
                            .fontWeight(.medium)
                    }
                }
                .padding(.bottom, 32)
                
                if loading || (socialLoading && pickerIndex == 2) {
                    LoaderView("Loading")
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color("foreground"))
            .edgesIgnoringSafeArea(.all)
            .onAppear { Actions.getSerializedProfile(id: user.id, completion: saveUserData) }
            .navigationBarTitle("")
            .navigationBarHidden(true)
        }
        .edgesIgnoringSafeArea(.all)
    }
    
    func saveUserData(_ user: User) {
        DispatchQueue.main.async {
            self.user.library = user.library
            self.user.slates = user.slates
            self.loading = false
        }
    }
    
    func saveUserSocial(_ subscriptions: [Subscription], _ subscribers: [Subscription]) {
        print("save user social")
        DispatchQueue.main.async {
            print(subscriptions)
            print(subscribers)
            self.user.subscriptions = subscriptions
            self.user.subscribers = subscribers
            self.socialLoading = false
        }
    }
}

