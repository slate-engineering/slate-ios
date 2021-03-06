//
//  ImageLoaderView.swift
//  Slate iOS (iOS)
//
//  Created by Martina Long on 1/28/21.
//

import SwiftUI
import Combine
import Foundation

class ImageLoader: ObservableObject {
    var didChange = PassthroughSubject<Data, Never>()
    var data = Data() {
        didSet {
            didChange.send(data)
        }
    }

    init(urlString:String) {
        guard let url = URL(string: urlString) else { return }
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else { return }
            DispatchQueue.main.async {
                self.data = data
            }
        }
        task.resume()
    }
}

struct ImageView: View {
    @ObservedObject var imageLoader:ImageLoader
    @State var image: UIImage = UIImage()
    var width: CGFloat
    var height: CGFloat
    var contentMode: ContentMode

    init(withURL url: String, width: CGFloat, height: CGFloat, contentMode: ContentMode = .fill) {
        imageLoader = ImageLoader(urlString:url)
        self.width = max(width, 0)
        self.height = max(height, 0)
        self.contentMode = contentMode
    }

    var body: some View {
        if contentMode == .fit {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: contentMode)
                .background(Color("white"))
                .frame(maxWidth: width, maxHeight: height)
                .clipped()
                .onReceive(imageLoader.didChange) { data in
                    self.image = UIImage(data: data) ?? UIImage()
                }
        } else {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: contentMode)
                .background(Color("white"))
                .frame(width: width, height: height)
                .clipped()
                .onReceive(imageLoader.didChange) { data in
                    self.image = UIImage(data: data) ?? UIImage()
                }
        }
    }
}
