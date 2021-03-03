//
//  SlatePreviewView.swift
//  Slate iOS (iOS)
//
//  Created by Martina Long on 1/29/21.
//

import SwiftUI

struct SlatePreviewView: View {
    var slate: Slate
    var imageObjects: [File]
    
    init(slate: Slate) {
        self.slate = slate
        var images = [File]()
        for obj in slate.data.objects {
            if Utilities.getFileType(obj.type) == .image {
                images.append(obj)
            }
            if images.count >= 4 {
                break
            }
        }
        self.imageObjects = images
    }
    
    var body: some View {
        Group {
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(slate.data.name)
                        .font(Font.custom("Inter", size: 18))
                        .fontWeight(.semibold)
                        .foregroundColor(Color("black"))
                    Text("\(slate.data.objects.count) files")
                        .font(Font.custom("Inter", size: 14))
                        .foregroundColor(Color("darkGray"))
                }
                .frame(height: 40)
                GeometryReader { geo in
//                    if imageObjects.count >= 4 {
//                        HStack(spacing: 4) {
//                            MediaPreviewView(imageObjects[0], width: (geo.size.width - 4) * 3 / 4, height: geo.size.height)
//                                .background(Color("foreground"))
//                            VStack(spacing: 4) {
//                                ForEach(1..<4) { index in
//                                    MediaPreviewView(imageObjects[index], width: (geo.size.width - 4) / 4, height: (geo.size.height - 8) / 3)
//                                        .background(Color("foreground"))
//                                }
//                            }
//                        }
//                    } else
                    if imageObjects.count > 0 {
                        MediaPreviewView(imageObjects[0], width: geo.size.width, height: geo.size.height)
                            .background(Color("foreground"))
                    } else if slate.data.objects.count > 0 {
                        MediaPreviewView(slate.data.objects[0], width: geo.size.width, height: geo.size.height, border: true)
                            .background(Color("foreground"))
                    } else {
                        VStack {
                            Text("No files in this slate")
                                .font(Font.custom("Inter", size: 14))
                                .foregroundColor(Color("white"))
                        }
                        .frame(width: geo.size.width, height: geo.size.height)
                        .background(Color(red: 209/255, green: 213/255, blue: 216/255))
                    }
                }
            }
            .padding(Constants.sideMargin)
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 4))
    }
}

//struct SlatePreviewView_Previews: PreviewProvider {
//    static var previews: some View {
//        SlatePreviewView()
//    }
//}
