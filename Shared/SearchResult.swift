//
//  SearchResult.swift
//  Slate iOS (iOS)
//
//  Created by Martina Long on 3/1/21.
//

import Foundation

struct SearchResult: Codable, Identifiable {
    var id: String {
        switch type {
        case .file:
            return self.file?.id ?? ownerId
        case .slate:
            return self.slate?.id ?? ownerId
        case .user:
            return self.user?.id ?? ownerId
        }
    }
    
    var file: File?
    var slate: Slate?
    var user: User?
    var type: ResultType
    var ownerId: String
    
    enum ResultType: String, Codable {
        case file = "FILE"
        case slate = "SLATE"
        case user = "USER"
    }
}

struct FileSearchResult: Codable, Identifiable {
    enum CodingKeys: String, CodingKey {
        case item, ownerId
    }
    
    var id: String {
        item.id
    }
    var item: FileSearchItem
    var ownerId: String
}

struct FileSearchItem: Codable {
    var id: String
    var data: FileSearchData
}

struct FileSearchData: Codable {
    var file: File
    var slate: Slate?
}


struct SlateSearchResult: Codable, Identifiable {
    enum CodingKeys: String, CodingKey {
        case item, ownerId
    }
    
    var id: String {
        item.id
    }
    var item: Slate
    var ownerId: String
}

struct SlateSearchItem: Codable {
    var id: String
    var data: FileSearchData
}

struct SlateSearchData: Codable {
    var file: File
    var slate: Slate?
}
