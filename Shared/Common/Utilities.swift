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
    
    static func copyUserDetails(to target: User, from source: User) {
        DispatchQueue.main.async {
            target.id = source.id
            target.username = source.username
            target.data = source.data
            target.library = source.library
            target.slates = source.slates
            target.onboarding = source.onboarding
            target.status = source.status
            target.subscriptions = source.subscriptions
            target.subscribers = source.subscribers
        }
    }
    
    static func copyUserSocial(to target: User, subscriptions: [Subscription], subscribers: [Subscription]) {
        DispatchQueue.main.async {
            target.subscriptions = subscriptions
            target.subscribers = subscribers
        }
    }
    
    static func copySlateDetails(to target: Slate, from source: Slate) {
        DispatchQueue.main.async {
            target.slatename = source.slatename
            target.createdAt = source.createdAt
            target.updatedAt = source.updatedAt
            target.publishedAt = source.publishedAt
            target.data = source.data
            target.user = source.user
        }
    }
}
