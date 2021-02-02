//
//  UserView.swift
//  Slate iOS (iOS)
//
//  Created by Martina Long on 1/29/21.
//

import SwiftUI

struct UserView: View {
    @ObservedObject var viewer: User
    
    var body: some View {
        //profile picture
        if viewer.data.name != nil {
            Text(viewer.data.name!)
        }
        Text("@\(viewer.username)")
        //description (edit)
        //chnage password
        //other settings
        //directory
    }
}

//struct UserView_Previews: PreviewProvider {
//    static var previews: some View {
//        UserView()
//    }
//}
