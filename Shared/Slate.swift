//
//  Slate.swift
//  Slate iOS (iOS)
//
//  Created by Martina Long on 1/28/21.
//

import Foundation

class Slate: ObservableObject, Codable, Identifiable {
    enum CodingKeys: String, CodingKey {
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case publishedAt = "published_at"
        case id, slatename, data
    }
    
    var id: String
    var slatename: String
    var createdAt: String?
    var updatedAt: String?
    var publishedAt: String?
    var data: SlateData
    var user: User?
}

struct SlateData: Codable {
    enum CodingKeys: String, CodingKey {
        case name, ownerId, body, layouts, objects
        case isPublic = "public"
    }
    
    var body: String?
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
    
    var cid: String?
    let id: String
    var name: String
    var title: String?
    var size: Int?
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
