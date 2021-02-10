//
//  Environment.swift
//  Slate iOS (iOS)
//
//  Created by Martina Long on 1/25/21.
//

import Foundation

struct Env {
    static var serverURL: String {
        return "https://slate.host"
//        let url = Bundle.main.infoDictionary?["ServerURL"] as! String
//        return url
    }
    
    static var uploadURL: String {
        return "https://slate-api.onrender.com"
//        let url = Bundle.main.infoDictionary?["UploadURL"] as! String
//        return url
    }
    
    static var searchURL: String {
        return "https://lens.slate.host"
//        let url = Bundle.main.infoDictionary?["SearchURL"] as! String
//        return url
    }
    
    static var pubsubURL: String {
        return "wss://fiji.onrender.com"
//        let url = Bundle.main.infoDictionary?["PubsubURL"] as! String
//        return url
    }
}
