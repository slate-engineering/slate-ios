//
//  SlatesView.swift
//  Slate iOS (iOS)
//
//  Created by Martina Long on 1/29/21.
//

import SwiftUI

struct SlatesView: View {
    @EnvironmentObject var viewer: User
    let views = ["My Slates", "Following"]
    @State private var viewIndex = 0
    var slatesFollowing: [Slate] {
        if let subscriptions = viewer.subscriptions {
            return subscriptions.filter { return $0.slate != nil }
                .map { $0.slate! }
        }
        return [Slate]()
    }
    @State private var showingCreateSheet = false
    
    var body: some View {
        ZStack {
            GeometryReader { geo in
                if viewIndex == 0 {
                    ScrollView(.vertical) {
                        Spacer()
                            .frame(height: 52)
                        if viewer.slates != nil && viewer.slates!.count > 0 {
                            VStack(spacing: 16) {
                                ForEach(viewer.slates!, id: \.id) { slate in
                                    NavigationLink(destination: SlateView(slate: slate).environmentObject(viewer)) {
                                        SlatePreviewView(slate: slate)
                                            .padding(.horizontal, Constants.sideMargin)
                                            .frame(width: geo.size.width, height: 0.75 * geo.size.width + 46)
                                    }
                                }
                            }
                        } else {
                            EmptyStateView(text: "Make your first slate by pressing \"New Slate\"", icon: Image("box"))
                                .padding(.horizontal, 16)
                        }
                        Spacer()
                            .frame(height: Constants.bottomMargin)
                    }
                } else {
                    ScrollView(.vertical) {
                        Spacer()
                            .frame(height: 52)
                        if slatesFollowing.count > 0 {
                            VStack(spacing: 16) {
                                ForEach(slatesFollowing, id: \.id) { slate in
                                    NavigationLink(destination: SlateView(slate: slate).environmentObject(viewer)) {
                                        SlatePreviewView(slate: slate)
                                            .padding(.horizontal, Constants.sideMargin)
                                            .frame(width: geo.size.width, height: 0.75 * geo.size.width + 46)
                                    }
                                }
                            }
                        } else {
                            EmptyStateView(text: "Slates you follow will be shown here", icon: Image("box"))
                                .padding(.horizontal, 16)
                        }
                        Spacer()
                            .frame(height: Constants.bottomMargin)
                    }
                }
            }
            PageOverlayView(pickerOptions: views, pickerIndex: $viewIndex) {
                TranslucentButtonView(type: .text, action: { showingCreateSheet = true }) {
                    Text("New Slate")
                        .font(Font.custom("Inter", size: 14))
                        .fontWeight(.medium)
                }
                .sheet(isPresented: $showingCreateSheet) {
                    CreateSlateView()
                        .environmentObject(viewer)
                }
            }
            .padding(.bottom, 52)
        }
    }
}
