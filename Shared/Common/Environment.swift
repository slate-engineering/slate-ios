//
//  Environment.swift
//  Slate iOS (iOS)
//
//  Created by Martina Long on 1/25/21.
//

import Foundation

struct Env {
    static var serverURL: String {
        return "http://192.168.86.162:1337" //slateProcessInfo.processInfo.environment["RESOURCE_URI_SERVER"] ?? ""
    }
}
