//
//  SlateView.swift
//  Slate iOS (iOS)
//
//  Created by Martina Long on 1/29/21.
//

import SwiftUI

struct SlateView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var viewer: User
    @ObservedObject var slate: Slate
    var username: String? {
        if let username = slate.user?.data.name ?? slate.user?.username {
            return username
        }
        if slate.data.ownerId == viewer.id {
            return viewer.data.name ?? "@\(viewer.username)"
        }
        return nil
    }
    @State private var isFollowing: Bool = false
    var isOwner: Bool {
        slate.data.ownerId == viewer.id
    }
    @State private var showingEditSheet = false
    @State private var showingCarousel = false
    @State private var carouselIndex = 0
    
    var body: some View {
        VStack(alignment: .leading) {
            ZStack {
                GeometryReader { geo in
                    ScrollView(.vertical) {
                        Spacer()
                            .frame(height: Constants.bottomMargin)
                        VStack(alignment: .leading, spacing: 6) {
                            Text(slate.data.name).font(Font.custom("Inter", size: 22)).fontWeight(.medium)
                            if username != nil {
                                if !isOwner {
                                    NavigationLink(destination: ProfileView(user: slate.user ?? User(id: slate.data.ownerId))) {
                                        Text(username!).font(Font.custom("Inter", size: 14)).foregroundColor(Color("brand"))
                                    }
                                } else {
                                    Text(username!).font(Font.custom("Inter", size: 14))
                                }
                            }
                            if slate.data.body != nil {
                                Text(slate.data.body!)
                                    .font(Font.custom("Inter", size: 14))
                                    .foregroundColor(Color("darkGray"))
                                    .padding(.top, 4)
                            }
                        }
                        .padding(.bottom, 16)
                        .padding(.horizontal, Constants.sideMargin)
                        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .topLeading)
                        LazyVStack {
                            ForEach(slate.data.objects, id: \.id) { file in
                                MediaPreviewView(file, width: geo.size.width - 32, contentMode: .fit)
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, Constants.sideMargin)
                                    .onTapGesture { openCarousel(file) }
                            }
                        }
                        Spacer()
                            .frame(height: Constants.bottomMargin)
                    }.frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .topLeading)
                }
                
                if showingCarousel && slate.data.objects.count > 0 {
                    CarouselView(isPresented: $showingCarousel, currentIndex: $carouselIndex, files: $slate.data.objects)
                }
            }
        }
        .navigationBarItems(trailing:
                                HStack {
                                    if isOwner {
                                        TranslucentButtonView(type: .icon, action: { print("clicked upload")}) {
                                            Image("plus")
                                                .resizable()
                                                .frame(width: 18, height: 18)
                                        }
                                        TranslucentButtonView(type: .icon, action: { showingEditSheet = true }) {
                                            Image("settings")
                                                .resizable()
                                                .frame(width: 18, height: 18)
                                        }
                                        .sheet(isPresented: $showingEditSheet) {
                                            EditSlateView(slate: slate, parentPresentationMode: presentationMode)
                                                .environmentObject(viewer)
                                        }
                                    } else {
                                        TranslucentButtonView(type: .text, action: {
                                            isFollowing = !isFollowing
                                            Actions.subscribeSlate(id: slate.id) {
                                                Actions.rehydrateSocial(viewer: viewer)
                                            }
                                        }) {
                                            Text(isFollowing ? "Unfollow" : "Follow")
                                                .font(Font.custom("Inter", size: 14))
                                                .fontWeight(.medium)
                                        }
                                    }
                                }
        )
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .topLeading)
        .background(Color("foreground"))
        .edgesIgnoringSafeArea(.all)
        .onAppear {
            determineFollowing()
            fetchSlate()
        }
    }
    
    func openCarousel(_ file: File) {
        print("open carousel")
        for index in 0..<slate.data.objects.count {
            if slate.data.objects[index].id == file.id {
                print("found id")
                carouselIndex = index
                showingCarousel = true
                return
            }
        }
    }
    
    func determineFollowing() {
        var isFollowing = false
        if let subscriptions = viewer.subscriptions {
            for sub in subscriptions {
                if let subSlate = sub.slate {
                    if subSlate.id == slate.id {
                        isFollowing = true
                        break
                    }
                }
            }
        }
        self.isFollowing = isFollowing
    }
    
    func fetchSlate() {
        if slate.user != nil || isOwner {
            // NOTE(martina): if already have user (or user is self), no need to fetch to get the username
            return
        }
        
        Actions.getSerializedSlate(id: slate.id) { fetchedSlate in
            DispatchQueue.main.async {
                slate.copySlateDetails(from: fetchedSlate)
            }
        }
    }
}

//struct SlateView_Previews: PreviewProvider {
//    static var previews: some View {
//        SlateView()
//    }
//}
