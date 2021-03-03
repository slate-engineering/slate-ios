//
//  ContentView.swift
//  Shared
//
//  Created by Martina Long on 1/21/21.
//

import SwiftUI
import Foundation
import Starscream

struct ContentView: View {
    @ObservedObject var viewer = User(isViewer: true)
    @State private var scene: Navigation = .data
    @State private var loading = true
    @State private var authenticated = false
    
    init() {
        let appearance = UITabBar.appearance()
        appearance.backgroundColor = UIColor(Color("white").opacity(0))
        UISegmentedControl.appearance().backgroundColor = UIColor(Color("white").opacity(0.1))
        UISegmentedControl.appearance().selectedSegmentTintColor = UIColor(Color("grayBlack").opacity(0.5))
        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor(Color("grayBlack"))], for: .normal)
    }
    
    var body: some View {
        if loading {
            VStack {
                Image("logotype")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 100)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color("foreground"))
            .edgesIgnoringSafeArea(.all)
            .onAppear {
                checkSignedIn()
            }
        } else if !authenticated {
            SignInView(authenticated: $authenticated) 
                .environmentObject(viewer)
                .background(Color("foreground"))
                .edgesIgnoringSafeArea(.all)
        } else {
            NavigationView {
                TabView(selection: $scene) {
                    DataView()
                        .environmentObject(viewer)
                        .navigationBarTitle("")
                        .navigationBarHidden(true)
                        .tabItem {
                            Image("folder-light")
                            Text("Files")
                        }
                        .tag(Navigation.data)
                    SlatesView()
                        .environmentObject(viewer)
                        .navigationBarTitle("")
                        .navigationBarHidden(true)
                        .tabItem {
                            Image("box-light")
                            Text("Slates")
                        }
                        .tag(Navigation.slates)
                    ActivityView()
                        .environmentObject(viewer)
                        .navigationBarTitle("")
                        .navigationBarHidden(true)
                        .tabItem {
                            Image("globe-light")
                            Text("Explore")
                        }
                        .tag(Navigation.activity)
                    SearchView()
                        .environmentObject(viewer)
                        .navigationBarTitle("")
                        .navigationBarHidden(true)
                        .tabItem {
                            Image("search-light")
                            Text("Search")
                        }
                        .tag(Navigation.search)
                    UserView(authenticated: $authenticated)
                        .environmentObject(viewer)
                        .navigationBarTitle("")
                        .navigationBarHidden(true)
                        .tabItem {
                            Image("user-light")
                            Text("User")
                        }
                        .tag(Navigation.user)
                }
                .accentColor(Color("brand"))
            }
        }
    }
    
    func checkSignedIn() {
        Actions.checkSignedIn() { authenticated in
            self.authenticated = authenticated
            if authenticated {
                Actions.hydrateAuthenticatedUser{ user in
                    saveViewerData(user)
                    loading = false
                }
            } else {
                viewer.clearUserDetails()
                viewer.saveToUserDefaults()
                loading = false
            }
        }
    }
    
    func saveViewerData(_ user: User) {
        DispatchQueue.main.async {
            viewer.copyUserDetails(from: user)
            viewer.saveToUserDefaults()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
