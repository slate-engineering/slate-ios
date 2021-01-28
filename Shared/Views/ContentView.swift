//
//  ContentView.swift
//  Shared
//
//  Created by Martina Long on 1/21/21.
//

import SwiftUI
import Foundation

struct ContentView: View {
    @State private var id = UserDefaults.standard.string(forKey: "USER_ID")
    @State private var scene: Navigation = .signIn
    
    var body: some View {
        switch scene {
        case .signIn:
            SignInView()
        default:
            DataView()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
