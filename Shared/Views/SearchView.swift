//
//  SearchView.swift
//  Slate iOS (iOS)
//
//  Created by Martina Long on 1/29/21.
//

import SwiftUI

struct FileSearchResultView: View {
    var file: File
    var slate: Slate?
    var user: User?
    
    var body: some View {
        HStack {
            Image("image")
                .resizable()
                .frame(width: 24, height: 24)
                .foregroundColor(Color(red: 191/255, green: 191/255, blue: 191/255))
                .frame(width: 48, height: 48)
                .overlay(RoundedRectangle(cornerRadius: 4).stroke(Color("foreground"), lineWidth: 1))
            VStack(alignment: .leading) {
                Text(file.wrappedName)
                    .font(Font.custom("Inter", size: 14))
                    .fontWeight(.medium)
                    .foregroundColor(Color("textGray"))
                    .lineLimit(1)
                Text(Strings.getFileExtension(file.wrappedFilename).uppercased())
                    .font(Font.custom("Inter", size: 12))
                    .foregroundColor(Color("textGrayLight"))
                    .lineLimit(1)
            }
            Spacer()
        }
    }
}

struct SlateSearchResultView: View {
    var slate: Slate
    var user: User?
    
    var body: some View {
        HStack {
            Image("box")
                .resizable()
                .frame(width: 24, height: 24)
                .foregroundColor(Color(red: 191/255, green: 191/255, blue: 191/255))
                .frame(width: 48, height: 48)
                .overlay(RoundedRectangle(cornerRadius: 4).stroke(Color("foreground"), lineWidth: 1))
            VStack(alignment: .leading) {
                if user != nil {
                    Text(slate.data.name)
                        .font(Font.custom("Inter", size: 14))
                        .fontWeight(.medium)
                        .foregroundColor(Color("textGray"))
                        .lineLimit(1)
                    Text(user!.data.name != nil && user!.data.name!.count > 0 ? "\(user!.data.name!)" : "@\(user!.username)")
                        .font(Font.custom("Inter", size: 12))
                        .foregroundColor(Color("textGrayLight"))
                        .lineLimit(1)
                } else {
                    Text(slate.data.name)
                        .font(Font.custom("Inter", size: 14))
                        .fontWeight(.medium)
                        .foregroundColor(Color("textGray"))
                        .lineLimit(1)
                }
            }
            Spacer()
        }
    }
}

struct UserSearchResultView: View {
    var user: User
    
    var body: some View {
        HStack {
            Image("user")
                .resizable()
                .frame(width: 24, height: 24)
                .foregroundColor(Color(red: 191/255, green: 191/255, blue: 191/255))
                .frame(width: 48, height: 48)
                .overlay(RoundedRectangle(cornerRadius: 4).stroke(Color("foreground"), lineWidth: 1))
            VStack(alignment: .leading) {
                if user.data.name != nil || user.data.name!.count == 0 {
                    Text("has a name")
                    Text("\(user.data.name!)")
                        .font(Font.custom("Inter", size: 14))
                        .fontWeight(.medium)
                        .foregroundColor(Color("textGray"))
                        .lineLimit(1)
                    Text("@\(user.username)")
                        .font(Font.custom("Inter", size: 12))
                        .foregroundColor(Color("textGrayLight"))
                        .lineLimit(1)
                } else {
                    Text("has no name")
                    Text("@\(user.username)")
                        .font(Font.custom("Inter", size: 14))
                        .fontWeight(.medium)
                        .foregroundColor(Color("textGray"))
                        .lineLimit(1)
                }
            }
            Spacer()
        }
        .onAppear { print(}
    }
}

struct SearchView: View {
    @State private var query = ""
    @State private var results = [SearchResult]()
    
    var body: some View {
        VStack {
            HStack {
                InputView("Search...", text: $query)
                Image("search")
                    .resizable()
                    .frame(width: 24, height: 24)
                    .foregroundColor(Color("darkGray"))
                    .onTapGesture { Actions.search(query: query, type: nil) { results = $0 } }
            }
            .padding(.horizontal, Constants.sideMargin)
            
            ScrollView(.vertical) {
                VStack {
                    ForEach(results, id: \.id) { result in
                        if result.type == .file && result.file != nil{
                            FileSearchResultView(file: result.file!, slate: result.slate, user: result.user)
                        } else if result.type == .slate && result.slate != nil {
                            SlateSearchResultView(slate: result.slate!, user: result.user)
                        } else if result.type == .user && result.user != nil {
                            UserSearchResultView(user: result.user!)
                        }
                    }
                    Spacer()
                }
                .padding(.horizontal, Constants.sideMargin)
                .padding(.bottom, Constants.bottomMargin)
            }
        }
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView()
    }
}
