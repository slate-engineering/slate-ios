//
//  CarouselView.swift
//  Slate iOS (iOS)
//
//  Created by Martina Long on 2/11/21.
//

import SwiftUI

struct CarouselCardView: View {
    var cid: String?
    var url: String
    var id: String
    var fileExtension: String
    var name: String
    var size: Int?
    var fileType: Constants.FileType
    var coverImage: CoverImage?
    @Binding var isPresented: Bool
    
    init(_ file: File, isPresented: Binding<Bool>) {
        id = file.id
        cid = file.cid
        url = file.url ?? "\(Env.textileURL)/\(file.cid ?? "")" 
        coverImage = file.coverImage
        fileType = Utilities.getFileType(file.type)
        name = file.title ?? file.name ?? file.file ?? ""
        size = file.size
        coverImage = file.coverImage
        fileExtension = Strings.getFileExtension(file.file ?? file.name ?? "")
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

struct CarouselView: View {
    @Binding var isPresented: Bool
    @Binding var currentIndex: Int
    @Binding var files: [File]
    @State var dragOffset: CGFloat = .zero
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                Blur()
                    .edgesIgnoringSafeArea(.top)
                    .onTapGesture {
                        isPresented = false
                    }
                LazyHStack(spacing: 0) {
                    ForEach(files, id: \.id) { file in
                        MediaPreviewView(file, width: UIScreen.main.bounds.size.width - Constants.sideMargin * 2, height: geo.size.height - Constants.sideMargin * 2, contentMode: .fit, fullView: true, nonImagesSquare: true)
                            .padding(Constants.sideMargin)
                            .frame(width: UIScreen.main.bounds.size.width)
                            .onAppear { print("carousel item appear") }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .offset(x: -UIScreen.main.bounds.size.width * CGFloat(currentIndex) + dragOffset)
                .animation(.easeOut(duration: 0.3))
            }
            .gesture(
                DragGesture()
                    .onChanged({ gesture in
                        dragOffset = gesture.translation.width
                    })
                    .onEnded({ gesture in
                        if dragOffset > 50 && currentIndex > 0 {
                            currentIndex -= 1
                        } else if dragOffset < -50 && currentIndex < files.count - 1 {
                            currentIndex += 1
                        }
                        dragOffset = 0
                    })
            )
        }
    }
}

//struct CarouselView_Previews: PreviewProvider {
//    static var previews: some View {
//        CarouselView()
//    }
//}
