//
//  Activity.swift
//  Slate iOS (iOS)
//
//  Created by Martina Long on 2/16/21.
//

import Foundation

struct Activity: Codable, Identifiable {
    enum CodingKeys: String, CodingKey {
        case createdAt = "created_at"
        case id, data
    }
    
    var createdAt: String
    var id: String
    var data: ActivityData
}

struct ActivityData: Codable {
    enum CodingKeys: String, CodingKey {
        case rawType = "type"
        case context
    }
    
    enum ActivityType {
        case addToSlate, newSlate
    }
    
    var rawType: String
    var context: ActivityContext
    var type: ActivityType {
        switch rawType {
        case "SUBSCRIBED_ADD_TO_SLATE":
            return .addToSlate
        default:
            return .newSlate
        }
    }
}

struct ActivityContext: Codable {
    var file: SlateFile?
    var slate: Slate
    var user: User
}
