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
    var createdAt: String? 
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
        case name, ownerId, body, objects, layouts
        case isPublic = "public"
    }
    
    var body: String?
    var name: String
    var ownerId: String
    var isPublic: Bool
    var layouts: SlateLayout?
    var objects: [File]
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        body = try values.decodeIfPresent(String.self, forKey: .body)
        name = try values.decode(String.self, forKey: .name)
        ownerId = try values.decodeIfPresent(String.self, forKey: .ownerId) ?? ""
        isPublic = try values.decodeIfPresent(Bool.self, forKey: .isPublic) ?? false
        layouts = try values.decodeIfPresent(SlateLayout.self, forKey: .layouts)
        objects = try values.decodeIfPresent([File].self, forKey: .objects) ?? [File]()
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(body, forKey: .body)
        try container.encode(name, forKey: .name)
        try container.encode(ownerId, forKey: .ownerId)
        try container.encode(isPublic, forKey: .isPublic)
        try container.encode(layouts, forKey: .layouts)
        try container.encode(objects, forKey: .objects)
    }
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
        case id, h, w, x, z, y
    }
    
    let id: String
    var h: Double?
    var w: Double?
    var x: Double?
    var y: Double?
    var z: Double?
}
