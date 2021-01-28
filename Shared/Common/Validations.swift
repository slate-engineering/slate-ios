//
//  Validations.swift
//  Slate iOS (iOS)
//
//  Created by Martina Long on 1/22/21.
//

import Foundation

struct Validations {
    static let usernameRegex = "^[a-zA-Z0-9_]{0,}[a-zA-Z]+[0-9]*$"
    
    static let rejectList = [
        "..",
        "$",
        "#",
        "_",
        "_next",
        "next",
        "webpack",
        "system",
        "experience",
        "root",
        "www",
        "website",
        "index",
        "api",
        "public",
        "static",
        "admin",
        "administrator",
        "webmaster",
        "download",
        "downloads",
        "403",
        "404",
        "500",
        "maintenance",
        "guidelines",
        "updates",
        "login",
        "authenticate",
        "sign-in",
        "sign_in",
        "signin",
        "log-in",
        "log_in",
        "logout",
        "terms",
        "terms-of-service",
        "community",
        "privacy",
        "reset-password",
        "reset",
        "logout",
        "dashboard",
        "analytics",
        "data",
        "timeout",
        "please-dont-use-timeout",
      ]
    
    static func userRoute(_ string: String) -> Bool {
        if string.range(of: usernameRegex, options: .regularExpression, range: nil, locale: nil) == nil {
            return false
        }
        
        if rejectList.contains(string) {
            return false
        }
        
        return true
    }
    
    static func username(_ string: String) -> Bool {
        if string.isEmpty || string.count > 48 {
            return false
        }
        
        if !userRoute(string) {
            return false
        }
        
        return true
    }
    
    static func password(_ string: String) -> Bool {
        if string.isEmpty || string.count < 8 {
            return false
        }
        
        return true
    }
}
