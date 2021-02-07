//
//  SignInView.swift
//  Slate iOS (iOS)
//
//  Created by Martina Long on 1/21/21.
//

import SwiftUI

struct SignInView: View {
    enum Page {
        case signUp, signIn
    }
    
    @ObservedObject var viewer: User
    @State private var username = ""
    @State private var password = ""
    @State private var status: Page? = nil
    @State private var agreedToTerms = false
    @State private var showPassword = false
    @State private var alert: AlertMessage? = nil
    @State private var loading = false
    
    var body: some View {
        let sanitizedUsername = Binding<String>(
            get: {
                self.username
            },
            set: {
                self.username = Strings.createSlug($0, base: "")
            }
        )
        ZStack {
            GeometryReader { geo in
                VStack {
                    Spacer()
                    VStack {
                        if status == nil {
                            VStack {
                                Spacer()
                                Image("logotype")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 100)
                                    .padding(.bottom, 20)
                                Text("An open-source file sharing network for research and collaboration")
                                    .font(Font.custom("Inter", size: 16))
                                    .lineSpacing(4)
                                    .multilineTextAlignment(.center)
                                Spacer()
                                ButtonView(.primary, action: { status = .signUp }) {
                                    Text("Sign up")
                                        .font(Font.custom("Inter", size: 14))
                                        .fontWeight(.semibold)
                                }
                                .padding(.vertical, 4)
                                
                                ButtonView(.secondary, action: { status = .signIn }) {
                                    Text("Sign in")
                                        .font(Font.custom("Inter", size: 14))
                                        .fontWeight(.semibold)
                                }
                                .padding(.vertical, 4)
                            }
                            .padding(36)
                        }
                        
                        if status == .signUp {
                            VStack {
                                Spacer()
                                Image("logotype")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 100)
                                    .padding(.bottom, 20)
                                Text("Create your account")
                                    .font(Font.custom("Inter", size: 16))
                                    .lineSpacing(4)
                                    .multilineTextAlignment(.center)
                                Spacer()
                                InputView("Username", text: sanitizedUsername)
                                    .padding(.vertical, 4)
                                ZStack {
                                    if showPassword {
                                        InputView("Password", text: $password)
                                            .padding(.vertical, 4)
                                    } else {
                                        SecureInputView("Password", text: $password)
                                            .padding(.vertical, 4)
                                    }
                                    HStack {
                                        Spacer()
                                        Image(showPassword ? "eye-off" : "eye")
                                            .resizable()
                                            .frame(width: 20, height: 20)
                                            .foregroundColor(Color("darkGray"))
                                            .padding(10)
                                            .onTapGesture { showPassword.toggle() }
                                    }
                                }
                                HStack(spacing: 0) {
                                    CheckBoxView(isChecked: $agreedToTerms)
                                        .padding(.trailing, 16)
                                    Text("I agree to the ")
                                        .font(Font.custom("Inter", size: 14))
                                    Link(destination: URL(string: "https://slate.host/terms")!, label: {
                                        Text("terms and conditions")
                                            .font(Font.custom("Inter", size: 14))
                                            .foregroundColor(Color.black)
                                            .underline()
                                    })
                                    Spacer()
                                }
                                .padding(.vertical, 12)
                                ButtonView(.primary, action: signUp) {
                                    Text("Sign up")
                                        .font(Font.custom("Inter", size: 14))
                                        .fontWeight(.semibold)
                                }
                                .padding(.vertical, 4)
                            }
                            .padding(36)
                        }
                        
                        if status == .signIn {
                            VStack {
                                Spacer()
                                Image("logotype")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 100)
                                    .padding(.bottom, 20)
                                Text("Welcome back")
                                    .font(Font.custom("Inter", size: 16))
                                    .lineSpacing(4)
                                    .multilineTextAlignment(.center)
                                Spacer()
                                InputView("Username", text: $username)
                                    .padding(.vertical, 4)
                                SecureInputView("Password", text: $password)
                                    .padding(.vertical, 4)
                                ButtonView(.primary, action: signIn) {
                                    Text("Sign in")
                                        .font(Font.custom("Inter", size: 14))
                                        .fontWeight(.semibold)
                                }
                                .padding(.vertical, 4)
                            }
                            .padding(36)
                        }
                    }
                    .frame(height: geo.size.height / 2)
                    .background(Color("white"))
                    .background(Color.black.opacity(0.05).shadow(radius: 30))
                    .padding(.horizontal, 12)
                    .padding(.bottom, 12)
                    Text(status == .signUp ? "Already have an account? Sign in" : status == .signIn ? "Not registered? Sign up instead" : "")
                        .font(Font.custom("Inter", size: 14))
                        .fontWeight(.medium)
                        .foregroundColor(Color("grayBlack"))
                        .onTapGesture {
                            if (status == .signIn) {
                                status = .signUp
                            } else {
                                status = .signIn
                            }
                        }
                    Spacer()
                    Spacer()
                }
                .frame(width: geo.size.width)
            }
            .alert(item: $alert) {
                Alert(title: Text($0.title), message: Text($0.message), dismissButton: .default(Text("OK")))
            }
            
            if loading {
                LoaderView("Authenticating")
            }
        }
    }
    
    func signIn() {
        if username.isEmpty {
            alert = AlertMessage(title: "No username provided", message: "Please provide a username to sign in")
            return
        }
        if password.isEmpty {
            alert = AlertMessage(title: "No password provided", message: "Please provide a password to sign in")
            return
        }
        loading = true
        Actions.signIn(username: username, password: password, completion: saveViewerData)
    }
    
    func signUp() {
        if !Validations.username(username) {
            alert = AlertMessage(title: "Username invalid", message: "Usernames must be between 1-48 characters and consist of only characters and numbers")
            return
        }
        if !Validations.password(password) {
            alert = AlertMessage(title: "Password invalid", message: "Passwords must be at least 8 characters long")
            return
        }
        if !agreedToTerms {
            alert = AlertMessage(title: "Please agree to the terms", message: "You must agree to the terms to register an account")
            return
        }
        loading = true
        Actions.signUp(username: username, password: password, accepted: agreedToTerms, completion: saveViewerData)
    }
    
    func saveViewerData(_ user: User) {
        print(viewer.id)
        print(viewer.username)
        DispatchQueue.main.async {
            viewer.id = user.id
            viewer.username = user.username
            viewer.data = user.data
            viewer.library = user.library
            viewer.slates = user.slates
            viewer.onboarding = user.onboarding
            viewer.status = user.status
            viewer.subscriptions = user.subscriptions
            viewer.subscribers = user.subscribers
            viewer.saveToUserDefaults()
            loading = false
            print("Info after save viewer data:")
            print(viewer.id)
            print(viewer.username)
        }
    }
}

//struct SignInView_Previews: PreviewProvider {
//    static var previews: some View {
//        SignInView()
//    }
//}
