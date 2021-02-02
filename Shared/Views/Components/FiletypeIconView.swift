//
//  FiletypeIconView.swift
//  Slate iOS (iOS)
//
//  Created by Martina Long on 2/1/21.
//

import SwiftUI

struct FiletypeIconView: View {
    let type: Constants.FileType
    
    init(type: Constants.FileType) {
        self.type = type
    }
    
    init(type: String) {
        self.type = Utilities.getFileType(type)
    }
    
    var body: some View {
        Image(type == .pdf ? "pdf" : type == .audio ? "audio" : type == .video ? "video" : type == .epub ? "book" : "document")
            .resizable()
    }
}
