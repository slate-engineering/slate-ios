//
//  UserView.swift
//  Slate iOS (iOS)
//
//  Created by Martina Long on 1/29/21.
//

import SwiftUI

struct UserView: View {
    @ObservedObject var viewer: User
    @State private var showEditSheet = false
    let views = ["Following", "Followers"]
    @State private var viewIndex = 0
    var following: [SubscriptionUser] {
        if let subscriptions = viewer.subscriptions {
            return subscriptions.filter { return $0.user != nil }
                .map { $0.user! }
        }
        return [SubscriptionUser]()
    }
    var followers: [SubscriptionUser] {
        if let subscribers = viewer.subscribers {
            return subscribers.filter { return $0.owner != nil }
                .map { $0.owner! }
        }
        return [SubscriptionUser]()
    }
    
    var body: some View {
        ZStack {
            VStack {
                VStack {
                    Spacer()
                        .frame(height: Constants.topMargin)
                    ImageView(withURL: viewer.data.photo ?? Constants.profileImageDefault, width: 64, height: 64)
                        .background(Color("white"))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    Text(viewer.data.name != nil && !viewer.data.name!.isEmpty ? viewer.data.name! : "@\(viewer.username)")
                        .font(Font.custom("Inter", size: 18))
                        .fontWeight(.medium)
                    if viewer.data.body != nil && !viewer.data.body!.isEmpty {
                        Text(viewer.data.body!)
                            .font(Font.custom("Inter", size: 14))
                            .foregroundColor(Color("darkGray"))
                            .padding(.top, 2)
                    }
                }
                .padding(.bottom, 24)
                .frame(maxWidth: .infinity)
                .contentShape(Rectangle())
                .onTapGesture { self.showEditSheet = true }
                ScrollView(.vertical) {
                    VStack {
                        if viewIndex == 0 {
                            ForEach(0..<following.count) { index in
                                UserEntryView(user: following[index])
                            }
                        } else {
                            ForEach(0..<followers.count) { index in
                                UserEntryView(user: followers[index])
                            }
                        }
                    }
                    .padding(.horizontal, Constants.sideMargin)
                    Spacer()
                        .frame(height: Constants.bottomMargin)
                }
            }
            PageOverlayView(pickerOptions: views, pickerIndex: $viewIndex, hideTop: true) {
                Text("Null")
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .sheet(isPresented: $showEditSheet) {
            UserEditView(viewer: viewer)
        }
    }
}

struct UserEditView: View {
    @Environment(\.presentationMode) var presentationMode
    
    @ObservedObject var viewer: User
    @State private var name: String
    @State private var username: String
    @State private var description: String
    @State private var password: String = ""
    @State private var passwordConfirm: String = ""
    
    init(viewer: User) {
        self.viewer = viewer
        self._name = State(initialValue: viewer.data.name ?? "")
        self._username = State(initialValue: viewer.username)
        self._description = State(initialValue: viewer.data.body ?? "")
    }
    
    var body: some View {
        NavigationBarView(title: "Profile settings", left: {
            Image("dismiss")
                .resizable()
                .frame(width: 24, height: 24)
                .foregroundColor(Color("grayBlack"))
                .onTapGesture { presentationMode.wrappedValue.dismiss() }
        }, right: {
            Image("check")
                .resizable()
                .frame(width: 24, height: 24)
                .foregroundColor(Color("grayBlack"))
                .onTapGesture {
                    save()
                    presentationMode.wrappedValue.dismiss()
                }
            //                Text("Save")
            //                    .font(Font.custom("Inter", size: 12))
            //                    .foregroundColor(Color("grayBlack"))
            //                    .fontWeight(.medium)
        })
        VStack(spacing: 16) {
            ZStack {
                ImageView(withURL: viewer.data.photo ?? Constants.profileImageDefault, width: 96, height: 96)
                    .background(Color("foreground"))
                Color.black.opacity(0.2)
                Image("edit")
                    .foregroundColor(Color.white)
            }
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .frame(width: 96, height: 96)
            .padding(.bottom, 16)
            VStack(alignment: .leading, spacing: 6) {
                Text("NAME")
                    .font(Font.custom("Inter", size: 10))
                    .foregroundColor(Color("grayBlack"))
                    .fontWeight(.semibold)
                InputView("Name", text: $name)
            }
            VStack(alignment: .leading, spacing: 6) {
                Text("USERNAME")
                    .font(Font.custom("Inter", size: 10))
                    .foregroundColor(Color("grayBlack"))
                    .fontWeight(.semibold)
                InputView("Username", text: $username)
            }
            VStack(alignment: .leading, spacing: 6) {
                Text("DESCRIPTION")
                    .font(Font.custom("Inter", size: 10))
                    .foregroundColor(Color("grayBlack"))
                    .fontWeight(.semibold)
                TextBoxView("Description", text: $description)
                    .frame(height: 120)
            }
            VStack(alignment: .leading, spacing: 6) {
                Text("CHANGE PASSWORD")
                    .font(Font.custom("Inter", size: 10))
                    .foregroundColor(Color("grayBlack"))
                    .fontWeight(.semibold)
                SecureInputView("New password", text: $password)
                SecureInputView("Confirm password", text: $passwordConfirm)
            }
            Spacer()
        }
        .padding(.vertical, 24)
        .padding(.horizontal, Constants.sideMargin)
    }
    
    func save() {
        print("saved")
    }
}

struct UserEntryView: View {
    var user: SubscriptionUser
    
    var body: some View {
        HStack(spacing: 16) {
            ImageView(withURL: user.data.photo ?? Constants.profileImageDefault, width: 32, height: 32)
                .clipShape(RoundedRectangle(cornerRadius: 4))
            Text(user.data.name != nil && !user.data.name!.isEmpty ? user.data.name! : "@\(user.username)")
                .font(Font.custom("Inter", size: 14))
                .fontWeight(.medium)
            Spacer()
        }
        .padding(8)
        .frame(height: 48)
        .background(Color("white"))
        .clipShape(RoundedRectangle(cornerRadius: 4))
    }
}

//struct UserView_Previews: PreviewProvider {
//    static var previews: some View {
//        UserView()
//    }
//}
