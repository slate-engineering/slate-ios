//
//  CarouselView.swift
//  Slate iOS (iOS)
//
//  Created by Martina Long on 2/11/21.
//

import SwiftUI

struct CarouselView: View {
    var cid: String?
    var url: String
    var id: String
    var fileExtension: String
    var name: String
    var size: Int?
    var fileType: Constants.FileType
    var coverImage: CoverImage?
    @Binding var isPresented: Bool
    
    init(_ file: SlateFile, isPresented: Binding<Bool>) {
        id = file.id
        cid = file.cid
        url = file.url
        coverImage = file.coverImage
        fileType = Utilities.getFileType(file.type)
        name = file.title ?? file.name
        size = file.size
        coverImage = file.coverImage
        fileExtension = Strings.getFileExtension(file.name)
        self._isPresented = isPresented
    }
    
    init(_ file: LibraryFile, isPresented: Binding<Bool>) {
        id = file.id
        cid = file.cid
        url = Strings.cidToUrl(file.cid)
        coverImage = file.coverImage
        fileType = Utilities.getFileType(file.type)
        name = file.name
        size = file.size
        coverImage = file.coverImage
        fileExtension = Strings.getFileExtension(file.file)
        self._isPresented = isPresented
    }
    
    var body: some View {
        ZStack {
            Blur()
                .onTapGesture { isPresented = false }
            if fileType == .image {
                ImageView(withURL: self.url, width: 200, height: 200)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
