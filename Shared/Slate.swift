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
        case id, slatename, data, user
    }
    
    var id: String
    @Published var slatename: String
    @Published var data: SlateData
    var createdAt: String? //these are not getting decoded properly
    var updatedAt: String?
    var publishedAt: String?
    @Published var user: User?
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(String.self, forKey: .id)
        slatename = try values.decode(String.self, forKey: .slatename)
        data = try values.decode(SlateData.self, forKey: .data)
        createdAt = try values.decodeIfPresent(String.self, forKey: .createdAt)
        updatedAt = try values.decodeIfPresent(String.self, forKey: .updatedAt)
        publishedAt = try values.decodeIfPresent(String.self, forKey: .publishedAt)
        user = try values.decodeIfPresent(User.self, forKey: .user)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(slatename, forKey: .slatename)
        try container.encode(data, forKey: .data)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(updatedAt, forKey: .updatedAt)
        try container.encode(publishedAt, forKey: .publishedAt)
        try container.encode(user, forKey: .user)
    }
    
    func copySlateDetails(from source: Slate) {
        id = source.id
        slatename = source.slatename
        createdAt = source.createdAt
        updatedAt = source.updatedAt
        publishedAt = source.publishedAt
        data = source.data
        if let sourceUser = source.user {
            if user == nil {
                user = sourceUser
            } else {
                user!.copyUserDetails(from: sourceUser)
            }
        }
    }
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
