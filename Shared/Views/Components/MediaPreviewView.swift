//
//  MediaPreviewView.swift
//  Slate iOS (iOS)
//
//  Created by Martina Long on 1/28/21.
//

import SwiftUI

struct MediaPreviewView: View {
    var cid: String?
    var url: String
    var id: String
    var fileExtension: String
    var name: String
    var size: Int?
    var fileType: Constants.FileType
    var coverImage: CoverImage?
    var width: CGFloat
    var height: CGFloat
    var fontSize: CGFloat {
        let size = (10.0 + (width - 175.0) * 10.0 / 175.0).clamped(to: 10...16)
        return size
    }
    var contentMode: ContentMode
    var border: Bool
    var nonImagesSquare: Bool
    var fullView: Bool
    
    init(_ file: File, width: CGFloat, height: CGFloat? = nil, contentMode: ContentMode = .fill, fullView: Bool = false, border: Bool = false, nonImagesSquare: Bool = false) {
        if let height = height {
            self.height = max(height, 0)
        } else {
            self.height = max(width, 0)
        }
        self.width = max(width, 0)
        self.contentMode = contentMode
        self.border = border
        self.fullView = fullView
        self.nonImagesSquare = nonImagesSquare
        id = file.id
        cid = file.cid
        url = file.url ?? "\(Env.textileURL)/\(file.cid ?? "")" 
        coverImage = file.coverImage
        fileType = Utilities.getFileType(file.type)
        name = file.title ?? file.name ?? file.file ?? ""
        size = file.size
        coverImage = file.coverImage
        fileExtension = Strings.getFileExtension(file.file ?? file.name ?? "")
    }
    
//    init(_ file: LibraryFile, width: CGFloat, height: CGFloat? = nil, contentMode: ContentMode = .fill, border: Bool = false) {
//        if let height = height {
//            self.height = max(height, 0)
//        } else {
//            self.height = max(width, 0)
//        }
//        self.width = max(width, 0)
//        self.contentMode = contentMode
//        self.border = border
//        id = file.id
//        cid = file.cid
//        url = Strings.cidToUrl(file.cid)
//        coverImage = file.coverImage
//        fileType = Utilities.getFileType(file.type)
//        name = file.name
//        size = file.size
//        coverImage = file.coverImage
//        fileExtension = Strings.getFileExtension(file.file)
//    }
    
    var body: some View {
        if fileType == .image {
            ImageView(withURL: self.url, width: max(1, width), height: max(1, height), contentMode: contentMode)
        } else {
            if fullView && fileType == .pdf {
//                Text("hi")
//                    .frame(width: width, height: height)
                VStack {
                    PDFKitView(url: URL(string: url)!)
                }
                .frame(width: 200, height: 200)
            } else {
                ZStack {
                    Image("file")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: max(1, (width * 0.3).upperBounded(by: 75)), height: max(1, (width * 0.3).upperBounded(by: 75)))
                    FiletypeIconView(type: fileType)
                        .frame(width: max(1, (width * 0.09).upperBounded(by: 25)), height: max(1, (width * 0.09).upperBounded(by: 25)))
                        .foregroundColor(Color("textGray"))
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Spacer()
                            Text(name)
                                .font(Font.custom("Inter", size: fontSize))
                                .fontWeight(.medium)
                                .foregroundColor(Color("textGray"))
                                .lineLimit(2)
                            if fileExtension.count != 0 {
                                Text(fileExtension.uppercased())
                                    .font(Font.custom("Inter", size: fontSize))
                                    .fontWeight(.medium)
                                    .foregroundColor(Color("textGrayLight"))
                            }
                        }
                        .padding(fontSize)
                        Spacer()
                    }
                }
                .frame(width: max(1, width), height: nonImagesSquare ? max(1, width) : max(1, height))
                .background(Color.white)
                .border(Color(border ? "foreground" : "transparent"))
            }
        }
    }
}

struct MediaPreviewView_Previews: PreviewProvider {
    static var previews: some View {
        MediaPreviewView(File(cid: "2890239802892cc", id: "cm928c32983c28", name: "monet.jpg", title: "Monet", size: 253, type: "image/png", blurhash: "2389c283cn2", coverImage: nil, url: "https://slate.textile.io/ipfs/bafkreiedkj3myxzz63rsyyxgniujyzioljv7ncodbrzxvls7uj3w5lcxl4", ownerId: "823928c92cm92m29cm92m92m92"), width: 100)
            .frame(width: 200, height: 200)
    }
}
