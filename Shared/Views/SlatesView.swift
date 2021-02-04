//
//  SlatesView.swift
//  Slate iOS (iOS)
//
//  Created by Martina Long on 1/29/21.
//

import SwiftUI

struct SlatesView: View {
    @ObservedObject var viewer: User
    let views = ["My Slates", "Following"]
    @State private var viewIndex = 0
    var slatesFollowing: [Slate] {
        if let subscriptions = viewer.subscriptions {
            return subscriptions.filter { return $0.slate != nil }
                .map { $0.slate! }
        }
        return [Slate]()
    }
    
    var body: some View {
        ZStack {
            GeometryReader { geo in
                if viewIndex == 0 {
                    ScrollView(.vertical) {
                        Spacer()
                            .frame(height: 52)
                        VStack(spacing: 16) {
                            ForEach(0..<(viewer.slates?.count ?? 0)) { index in
                                NavigationLink(destination: SlateView(viewer: viewer, slate: viewer.slates![index])) {
                                    SlatePreviewView(slate: viewer.slates![index])
                                        .padding(.horizontal, Constants.sideMargin)
                                        .frame(width: geo.size.width, height: 0.75 * geo.size.width + 46)
                                }
                            }
                        }
                        Spacer()
                            .frame(height: Constants.bottomMargin)
                    }
                } else {
                    ScrollView(.vertical) {
                        Spacer()
                            .frame(height: 52)
                        VStack(spacing: 16) {
                            ForEach(0..<slatesFollowing.count) { index in
                                NavigationLink(destination: SlateView(viewer: viewer, slate: slatesFollowing[index])) {
                                    SlatePreviewView(slate: slatesFollowing[index])
                                        .padding(.horizontal, Constants.sideMargin)
                                        .frame(width: geo.size.width, height: 0.75 * geo.size.width + 46)
                                }
                            }
                        }
                        Spacer()
                            .frame(height: Constants.bottomMargin)
                    }
                }
            }
            PageOverlayView(pickerOptions: views, pickerIndex: $viewIndex) {
                TranslucentButtonView(type: .text, action: { print("Pressed button") }) {
                    Text("New Slate")
                        .font(Font.custom("Inter", size: 14))
                        .fontWeight(.medium)
                }
            }
        }
    }
}

struct SlatesView_Previews: PreviewProvider {
    static var previews: some View {
        SlatesView(viewer: User())
    }
}
