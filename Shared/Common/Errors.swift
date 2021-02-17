//
//  Errors.swift
//  Slate iOS (iOS)
//
//  Created by Martina Long on 1/25/21.
//

import Foundation

struct Errors {
    static let messages: [String: String] = [
        "YOU_ARE_NOT_ALLOWED": "We're having trouble getting access to our servers at the moment",
        "SERVER_SIGN_IN": "You are not signed in. You must sign in to do this action",
    ]
    
    static func get(_ decorator: String) -> String {
        return messages[decorator] ?? "Something went wrong. Please try again later"
    }
}
