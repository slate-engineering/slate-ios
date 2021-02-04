//
//  ContentView.swift
//  Shared
//
//  Created by Martina Long on 1/21/21.
//

import SwiftUI
import Foundation

extension UIImage {
    class func colorForNavBar(color: UIColor) -> UIImage {
        let rect = CGRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0)
        //    Or if you need a thinner border :
        //    let rect = CGRect(x: 0.0, y: 0.0, width: 1.0, height: 0.5)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()

        context!.setFillColor(color.cgColor)
        context!.fill(rect)

        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return image!
    }
}

struct ContentView: View {
    @ObservedObject var viewer = User()
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
            SignInView(viewer: viewer)
                .background(Color("foreground"))
                .edgesIgnoringSafeArea(.all)
        } else {
            NavigationView {
                TabView(selection: $scene) {
                    DataView(viewer: viewer)
                        .padding(.vertical, 40)
                        .background(Color("foreground"))
                        .edgesIgnoringSafeArea(.all)
                        .tabItem {
                            Image("folder-light")
                            Text("Files")
                        }
                        .tag(Navigation.data)
                    SlatesView(viewer: viewer)
                        .padding(.vertical, 40)
                        .background(Color("foreground"))
                        .edgesIgnoringSafeArea(.all)
                        .tabItem {
                            Image("box-light")
                            Text("Slates")
                        }
                        .tag(Navigation.slates)
                    ActivityView()
                        .padding(.vertical, 40)
                        .background(Color("foreground"))
                        .edgesIgnoringSafeArea(.all)
                        .tabItem {
                            Image("globe-light")
                            Text("Explore")
                        }
                        .tag(Navigation.activity)
                    UserView(viewer: viewer)
                        .padding(.vertical, 40)
                        .background(Color("foreground"))
                        .edgesIgnoringSafeArea(.all)
                        .tabItem {
                            Image("user-light")
                            Text("User")
                        }
                        .tag(Navigation.user)
                    FilecoinView()
                        .padding(.vertical, 40)
                        .background(Color("foreground"))
                        .edgesIgnoringSafeArea(.all)
                        .tabItem {
                            Image("wallet-light")
                            Text("Filecoin")
                        }
                        .tag(Navigation.filecoin)
                }
                .accentColor(Color("brand"))
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
