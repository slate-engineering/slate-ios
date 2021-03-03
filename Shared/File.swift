//
//  File.swift
//  Slate iOS (iOS)
//
//  Created by Martina Long on 3/2/21.
//

import Foundation

struct File: Codable, Identifiable {
    enum CodingKeys: String, CodingKey {
        case blurhash, cid, id, name, ownerId, size, title, file, type, url, coverImage, date
        case isPublic = "public"
    }
    
    var wrappedName: String {
        title ?? name ?? file ?? ""
    }
    var wrappedFilename: String {
        file ?? name ?? title ?? ""
    }
    var cid: String?
    let id: String
    var date: String?
    var name: String?
    var title: String?
    var file: String?
    var size: Int?
    var type: String
    var blurhash: String?
    var coverImage: CoverImage?
    var url: String?
    var ownerId: String?
    var isPublic: Bool?
}

struct CoverImage: Codable {
    enum CodingKeys: String, CodingKey {
        case cid, id, file, name, size, type, blurhash, url, date
    }
    
    var cid: String
    var id: String
    var date: String
    var file: String
    var name: String
    var size: Int
    var type: String
    var blurhash: String?
    var url: String
}
