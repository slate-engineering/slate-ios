//
//  UserView.swift
//  Slate iOS (iOS)
//
//  Created by Martina Long on 1/29/21.
//

import SwiftUI

struct UserView: View {
    enum Sheet: Identifiable {
        case edit, user
        
        var id: Int { hashValue }
    }
    
    @EnvironmentObject var viewer: User
    @Binding var authenticated: Bool
    
    @State private var showingEditSheet = false
    @State private var selectedUser: User? = nil
    let views = ["Following", "Followers"]
    @State private var viewIndex = 0
    var following: [User] {
        if let subscriptions = viewer.subscriptions {
            return subscriptions.filter { return $0.user != nil }
                .map { $0.user! }
        }
        return [User]()
    }
    var followers: [User] {
        if let subscribers = viewer.subscribers {
            return subscribers.filter { return $0.owner != nil }
                .map { $0.owner! }
        }
        return [User]()
    }
    
    var body: some View {
        ZStack {
            Color("foreground")
                .edgesIgnoringSafeArea(.all)
            
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
                            .multilineTextAlignment(.center)
                            .padding(.top, 2)
                    }
                }
                .padding(.horizontal, Constants.sideMargin)
                .padding(.bottom, 24)
                .frame(maxWidth: .infinity)
                .contentShape(Rectangle())
                .onTapGesture {
                    self.showingEditSheet = true
                }
                .sheet(isPresented: $showingEditSheet) {
                    UserEditView(authenticated: $authenticated, viewer: viewer)
                        .environmentObject(viewer)
                }
                
                if viewIndex == 0 {
                    if following.count > 0 {
                        ScrollView(.vertical) {
                            VStack {
                                ForEach(0..<following.count) { index in
                                    UserEntryView(user: following[index])
                                        .onTapGesture {
                                            self.selectedUser = following[index]
                                        }
                                }
                            }
                            .padding(.horizontal, Constants.sideMargin)
                            .sheet(item: $selectedUser) { user in
                                NavigationView {
                                    ProfileView(user: user)
                                        .environmentObject(viewer)
                                }
                            }
                            Spacer()
                                .frame(height: Constants.bottomMargin)
                        }
                    } else {
                        EmptyStateView(text: "Users you follow will be displayed here", icon: Image("user"))
                            .padding(.horizontal, 16)
                    }
                } else {
                    if followers.count > 0 {
                        ScrollView(.vertical) {
                            VStack {
                                ForEach(0..<followers.count) { index in
                                    UserEntryView(user: followers[index])
                                        .onTapGesture {
                                            self.selectedUser = followers[index]
                                        }
                                }
                            }
                            .padding(.horizontal, Constants.sideMargin)
                            .sheet(item: $selectedUser) { user in
                                NavigationView {
                                    ProfileView(user: user)
                                        .environmentObject(viewer)
                                }
                            }
                            Spacer()
                                .frame(height: Constants.bottomMargin)
                        }
                    } else {
                        EmptyStateView(text: "Users who follow you will be displayed here", icon: Image("user"))
                            .padding(.horizontal, 16)
                    }
                }
            }
            PageOverlayView(pickerOptions: views, pickerIndex: $viewIndex) {
                TranslucentButtonView(type: .text, action: {
                    Actions.signOut() {
                        DispatchQueue.main.async {
                            authenticated = false
                            viewer.clearUserDetails()
                            viewer.saveToUserDefaults()
                        }
                    }
                }) {
                    Text("Sign out")
                        .font(Font.custom("Inter", size: 14))
                        .fontWeight(.medium)
                }
            }
            .padding(.bottom, 8)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct UserEditView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewer: User
    @Binding var authenticated: Bool
    
    @State private var name: String
    @State private var username: String
    @State private var description: String
    @State private var password: String = ""
    @State private var passwordConfirm: String = ""
    @State private var alert: AlertMessage? = nil
    
    init(authenticated: Binding<Bool>, viewer: User) {
        self._authenticated = authenticated
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
        })
        VStack(spacing: 32) {
            ZStack {
                ImageView(withURL: viewer.data.photo ?? Constants.profileImageDefault, width: 96, height: 96)
                    .background(Color("foreground"))
                Color.black.opacity(0.2)
                Image("edit")
                    .foregroundColor(Color.white)
            }
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .frame(width: 96, height: 96)
            VStack(alignment: .leading) {
                Text("ACCOUNT DETAILS")
                    .sectionHeaderStyle()
                    .padding(.bottom, 4)
                InputView("Name", text: $name)
                InputView("Username", text: $username)
                TextBoxView("Description", text: $description)
                    .frame(height: 120)
            }
            VStack(alignment: .leading) {
                Text("CHANGE PASSWORD")
                    .sectionHeaderStyle()
                    .padding(.bottom, 4)
                SecureInputView("New password", text: $password)
                SecureInputView("Confirm password", text: $passwordConfirm)
            }
            VStack(alignment: .leading) {
                Text("DELETE ACCOUNT")
                    .sectionHeaderStyle()
                    .padding(.bottom, 4)
                ButtonView(.warning, action: deleteAccount) {
                    Text("Delete account")
                        .font(Font.custom("Inter", size: 14))
                        .fontWeight(.semibold)
                }
            }
            Spacer()
        }
        .padding(.vertical, 24)
        .padding(.horizontal, Constants.sideMargin)
        .alert(item: $alert) {
            Alert(title: Text($0.title), message: Text($0.message), dismissButton: .default(Text("OK")))
        }
    }
    
    func save() {
        if (!password.isEmpty && passwordConfirm.isEmpty) || (password.isEmpty && !passwordConfirm.isEmpty) {
            if passwordConfirm.isEmpty {
                alert = AlertMessage(title: "No password confirmation", message: "To update your password, please make sure both the password and password confirmation fields are filled in")
                return
            }
        }
        viewer.data.name = name
        viewer.username = username
        viewer.data.body = description
        if !password.isEmpty && !passwordConfirm.isEmpty {
            if password != passwordConfirm {
                alert = AlertMessage(title: "Passwords do not match", message: "To update your password, please make sure the passwords match")
                return
            }
            Actions.editUser(name: name, username: username, description: description, password: password)
        } else {
            Actions.editUser(name: name, username: username, description: description)
        }
    }
    
    func deleteAccount() {
        Actions.deleteAccount() {
            Actions.signOut() {
                DispatchQueue.main.async {
                    presentationMode.wrappedValue.dismiss()
                    authenticated = false
                    viewer.clearUserDetails()
                    viewer.saveToUserDefaults()
                }
            }
        }
    }
}

struct UserEntryView: View {
    var user: User
    
    var body: some View {
        HStack(spacing: 16) {
            ImageView(withURL: user.data.photo ?? Constants.profileImageDefault, width: 32, height: 32)
                .clipShape(RoundedRectangle(cornerRadius: 4))
            Text(user.data.name != nil && !user.data.name!.isEmpty ? user.data.name! : "@\(user.username)")
                .font(Font.custom("Inter", size: 14))
                .fontWeight(.medium)
                .foregroundColor(Color("black"))
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
