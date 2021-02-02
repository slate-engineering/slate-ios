//
//  Utility.swift
//  Slate iOS (iOS)
//
//  Created by Martina Long on 1/28/21.
//

import Foundation

struct Utilities {
    static func getFileType(_ type: String) -> Constants.FileType {
        if type.hasPrefix("image/") {
            return .image
        }
        if type.hasPrefix("video/") {
            return .video
        }
        if type.hasPrefix("audio/") {
            return .audio
        }
        if type.hasPrefix("application/epub") {
            return .epub
        }
        if type.hasPrefix("application/pdf") {
            return .pdf
        }
        return .other
    }
}
