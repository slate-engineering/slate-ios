//
//  User.swift
//  Slate iOS (iOS)
//
//  Created by Martina Long on 1/25/21.
//

import Foundation
import SwiftyJSON

struct User: Codable {
    enum CodingKeys: String, CodingKey {
        case id, username, data, library, onboarding, status, slates
    }
    
    let id: UUID
    var username: String
    var data: UserData
    var library: [Library]?
    var slates: [Slate]?
    var onboarding: [String: Bool]?
    var status: [String: Bool]?
}

struct UserData: Codable {
    enum CodingKeys: String, CodingKey {
        case body, name, photo
    }
    
    @DecodableDefault.EmptyString var body: String
    @DecodableDefault.EmptyString var name: String
    var photo: String?
}

struct Library: Codable {
    enum CodingKeys: String, CodingKey {
        case children
    }
    
    var children: [LibraryFile]?
}

struct LibraryFile: Codable {
    enum CodingKeys: String, CodingKey {
        case cid, id, file, name, size, type, blurhash, coverImage, date
        case isPublic = "public"
    }
    
    var cid: String
    var id: String
    var date: String
    var file: String
    var name: String
    var size: Int
    var type: String
    var blurhash: String?
    var coverImage: CoverImage?
    @DecodableDefault.False var isPublic: Bool
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

struct Slate: Codable {
    enum CodingKeys: String, CodingKey {
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case publishedAt = "published_at"
        case id, slatename, data
    }
    
    let id: String
    var slatename: String
    var createdAt: String?
    var updatedAt: String?
    var publishedAt: String?
    var data: SlateData
}

struct SlateData: Codable {
    enum CodingKeys: String, CodingKey {
        case name, ownerId, body, objects, layouts//body, layouts, name, objects, ownerId
        case isPublic = "public"
    }
    
    @DecodableDefault.EmptyString var body: String
    var name: String
    var ownerId: String
    @DecodableDefault.False var isPublic: Bool
    var layouts: SlateLayout?
    var objects: [SlateFile]
}

struct SlateFile: Codable {
    enum CodingKeys: String, CodingKey {
        case blurhash, cid, id, name, ownerId, size, title, type, url, coverImage
    }
    
    var cid: String
    let id: String
    var name: String
    var title: String?
    var size: Int
    var type: String
    var blurhash: String?
    var coverImage: CoverImage?
    var url: String
    var ownerId: String
}

struct SlateLayout: Codable {
    enum CodingKeys: String, CodingKey {
        case ver, fileNames, defaultLayout, layout
    }
    
    var ver: String?
    var layout: [Placement]?
    var fileNames: Bool?
    var defaultLayout: Bool?
}

struct Placement: Codable {
    enum CodingKeys: String, CodingKey {
        case h, w, x, y, z, id
    }
    
    let id: String
    var h: Double
    var w: Double
    var x: Double
    var y: Double
    var z: Double
}

