//
//  TabGroupView.swift
//  Slate iOS (iOS)
//
//  Created by Martina Long on 2/6/21.
//

import SwiftUI

struct TabGroupView: View {
    @Binding var tabOptions: [String]
    @Binding var tabIndex: Int
    
    var body: some View {
        GeometryReader { geo in
            HStack {
                ForEach(tabOptions) {
                    Text($0)
                }
            }
        }
    }
}

struct TabGroupView_Previews: PreviewProvider {
    static var previews: some View {
        TabGroupView(tabOptions: .constant(["Files", "Slates", "Peers"]), tabIndex: .constant(0))
    }
}
