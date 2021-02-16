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
    
    init() {
        let appearance = UITabBar.appearance()
        appearance.backgroundColor = UIColor(Color("white").opacity(0))
        UISegmentedControl.appearance().backgroundColor = UIColor(Color("white").opacity(0.1))
        UISegmentedControl.appearance().selectedSegmentTintColor = UIColor(Color("grayBlack").opacity(0.5))
        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor(Color("grayBlack"))], for: .normal)
    }
    
    var body: some View {
        if viewer.id.isEmpty {
            SignInView()
                .environmentObject(viewer)
                .background(Color("foreground"))
                .edgesIgnoringSafeArea(.all)
        } else {
            NavigationView {
                TabView(selection: $scene) {
                    DataView()
                        .environmentObject(viewer)
                        .padding(.vertical, 40)
                        .background(Color("foreground"))
                        .clipped()
                        .edgesIgnoringSafeArea(.all)
                        .navigationBarTitle("")
                        .navigationBarHidden(true)
                        .tabItem {
                            Image("folder-light")
                            Text("Files")
                        }
                        .tag(Navigation.data)
                    SlatesView()
                        .environmentObject(viewer)
                        .padding(.vertical, 40)
                        .background(Color("foreground"))
                        .edgesIgnoringSafeArea(.all)
                        .navigationBarTitle("")
                        .navigationBarHidden(true)
                        .tabItem {
                            Image("box-light")
                            Text("Slates")
                        }
                        .tag(Navigation.slates)
                    ActivityView()
                        .environmentObject(viewer)
                        .padding(.vertical, 40)
                        .background(Color("foreground"))
                        .edgesIgnoringSafeArea(.all)
                        .navigationBarTitle("")
                        .navigationBarHidden(true)
                        .tabItem {
                            Image("globe-light")
                            Text("Explore")
                        }
                        .tag(Navigation.activity)
                    UserView()
                        .environmentObject(viewer)
                        .padding(.vertical, 40)
                        .background(Color("foreground"))
                        .edgesIgnoringSafeArea(.all)
                        .navigationBarTitle("")
                        .navigationBarHidden(true)
                        .tabItem {
                            Image("user-light")
                            Text("User")
                        }
                        .tag(Navigation.user)
                    FilecoinView()
                        .environmentObject(viewer)
                        .padding(.vertical, 40)
                        .background(Color("foreground"))
                        .edgesIgnoringSafeArea(.all)
                        .navigationBarTitle("")
                        .navigationBarHidden(true)
                        .tabItem {
                            Image("wallet-light")
                            Text("Filecoin")
                        }
                        .tag(Navigation.filecoin)
                }
                .accentColor(Color("brand"))
                .clipped()
                .edgesIgnoringSafeArea(.all)
            }
            .clipped()
            .edgesIgnoringSafeArea(.all)
            .onAppear { print("Content view on appear called") }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
