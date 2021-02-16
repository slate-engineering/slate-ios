//
//  User.swift
//  Slate iOS (iOS)
//
//  Created by Martina Long on 1/25/21.
//

import Foundation
import SwiftyJSON

class User: ObservableObject, Codable, Identifiable {
    enum CodingKeys: String, CodingKey {
        case id, username, data, library, slates, subscribers, subscriptions, onboarding, status
    }
    
    var id: String
    @Published var username: String
    @Published var data: UserData
    @Published var library: [Library]?
    @Published var slates: [Slate]?
    @Published var subscribers: [Subscription]?
    @Published var subscriptions: [Subscription]?
    var onboarding: [String: Bool]?
    var status: [String: Bool]?
    var files: [LibraryFile]? {
        library?[0].children ?? [LibraryFile]()
    }
    
    init(id: String) {
        self.id = id
        username = ""
        data = UserData()
    }
    
    init(isViewer: Bool = false) {
        if isViewer {
            let decoder = JSONDecoder()
            id = UserDefaults.standard.string(forKey: "id") ?? ""
            username = UserDefaults.standard.string(forKey: "username") ?? ""
            if let data = UserDefaults.standard.data(forKey: "data") {
                if let decoded = try? decoder.decode(UserData.self, from: data) {
                    self.data = decoded
                } else {
                    self.data = UserData()
                }
            } else {
                self.data = UserData()
            }
            if let library = UserDefaults.standard.data(forKey: "library") {
                if let decoded = try? decoder.decode([Library].self, from: library) {
                    self.library = decoded
                } else {
                    self.library = nil
                }
            } else {
                self.library = nil
            }
            if let slates = UserDefaults.standard.data(forKey: "slates") {
                if let decoded = try? decoder.decode([Slate].self, from: slates) {
                    self.slates = decoded
                } else {
                    self.slates = nil
                }
            } else {
                self.slates = nil
            }
            if let subscribers = UserDefaults.standard.data(forKey: "subscribers") {
                if let decoded = try? decoder.decode([Subscription].self, from: subscribers) {
                    self.subscribers = decoded
                } else {
                    self.subscribers = nil
                }
            } else {
                self.subscribers = nil
            }
            if let subscriptions = UserDefaults.standard.data(forKey: "subscriptions") {
                if let decoded = try? decoder.decode([Subscription].self, from: subscriptions) {
                    self.subscriptions = decoded
                } else {
                    self.subscriptions = nil
                }
            } else {
                self.subscriptions = nil
            }
            if let onboarding = UserDefaults.standard.data(forKey: "onboarding") {
                if let decoded = try? decoder.decode([String: Bool].self, from: onboarding) {
                    self.onboarding = decoded
                } else {
                    self.onboarding = nil
                }
            } else {
                self.onboarding = nil
            }
            if let status = UserDefaults.standard.data(forKey: "status") {
                if let decoded = try? decoder.decode([String: Bool].self, from: status) {
                    self.status = decoded
                } else {
                    self.status = nil
                }
            } else {
                self.status = nil
            }
        } else {
            id = ""
            username = ""
            data = UserData()
        }
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decodeIfPresent(String.self, forKey: .id) ?? ""
        username = try values.decodeIfPresent(String.self, forKey: .username) ?? ""
        data = try values.decodeIfPresent(UserData.self, forKey: .data) ?? UserData()
        library = try values.decodeIfPresent([Library].self, forKey: .library)
        slates = try values.decodeIfPresent([Slate].self, forKey: .slates)
        subscribers = try values.decodeIfPresent([Subscription].self, forKey: .subscribers)
        subscriptions = try values.decodeIfPresent([Subscription].self, forKey: .subscriptions)
        onboarding = try values.decodeIfPresent([String: Bool].self, forKey: .onboarding)
        status = try values.decodeIfPresent([String: Bool].self, forKey: .status)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(username, forKey: .username)
        try container.encode(data, forKey: .data)
        try container.encode(library, forKey: .library)
        try container.encode(slates, forKey: .slates)
        try container.encode(subscribers, forKey: .subscribers)
        try container.encode(subscriptions, forKey: .subscriptions)
        try container.encode(onboarding, forKey: .onboarding)
        try container.encode(status, forKey: .status)
    }
    
    func saveToUserDefaults() {
        UserDefaults.standard.set(id, forKey: "id")
        UserDefaults.standard.set(username, forKey: "username")
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(data) {
            UserDefaults.standard.set(encoded, forKey: "data")
        }
        if let encoded = try? encoder.encode(library) {
            UserDefaults.standard.set(encoded, forKey: "library")
        }
        if let encoded = try? encoder.encode(slates) {
            UserDefaults.standard.set(encoded, forKey: "slates")
        }
        if let encoded = try? encoder.encode(subscribers) {
            UserDefaults.standard.set(encoded, forKey: "subscribers")
        }
        if let encoded = try? encoder.encode(subscriptions) {
            UserDefaults.standard.set(encoded, forKey: "subscriptions")
        }
        if let encoded = try? encoder.encode(onboarding) {
            UserDefaults.standard.set(encoded, forKey: "onboarding")
        }
        if let encoded = try? encoder.encode(status) {
            UserDefaults.standard.set(encoded, forKey: "status")
        }
    }
    
    func copyUserDetails(from source: User) {
        id = source.id
        username = source.username
        data = source.data
        library = source.library
        slates = source.slates
        onboarding = source.onboarding
        status = source.status
        subscriptions = source.subscriptions
        subscribers = source.subscribers
    }
    
    func copySocial(subscriptions: [Subscription], subscribers: [Subscription]) {
        self.subscriptions = subscriptions
        self.subscribers = subscribers
    }
    
    func clearUserDetails() {
        id = ""
        username = ""
        data = UserData()
        library = nil
        slates = nil
        onboarding = nil
        status = nil
        subscriptions = nil
        subscribers = nil
    }
}

struct UserData: Codable {
    enum CodingKeys: String, CodingKey {
        case body, name, photo
    }
    
    var body: String?
    var name: String?
    var photo: String?
}

struct Library: Codable {
    enum CodingKeys: String, CodingKey {
        case children
    }
    
    var children: [LibraryFile]?
}

struct LibraryFile: Codable, Identifiable {
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

struct Subscription: Codable {
    enum CodingKeys: String, CodingKey {
        case id, slate, owner, user
    }
    
    var id: String?
    var owner: User?
    var slate: Slate?
    var user: User?
}
