//
//  Actions.swift
//  Slate iOS (iOS)
//
//  Created by Martina Long on 1/22/21.
//

import Foundation
import SwiftyJSON

struct Actions {
    static func readCookie(forURL url: URL) -> [HTTPCookie] {
        let cookieStorage = HTTPCookieStorage.shared
        let cookies = cookieStorage.cookies(for: url) ?? []
        return cookies
    }
    
    static func storeCookies(_ cookies: [HTTPCookie], forURL url: URL) {
        let cookieStorage = HTTPCookieStorage.shared
        cookieStorage.setCookies(cookies,
                                 for: url,
                                 mainDocumentURL: nil)
    }
    
    static func deleteCookies() {
        let cookieStorage = HTTPCookieStorage.shared
        
        for cookie in cookieStorage.cookies! {
            cookieStorage.deleteCookie(cookie)
        }
    }
    
    static func printCookies() {
        let cookieStorage = HTTPCookieStorage.shared
        print("Cookies:")
        
        for cookie in cookieStorage.cookies! {
            print(cookie)
        }
    }
    
//    static func deleteCookies(forURL url: URL) {
//        let cookieStorage = HTTPCookieStorage.shared
//
//        for cookie in readCookie(forURL: url) {
//            cookieStorage.deleteCookie(cookie)
//        }
//    }
    
    static func makeRequest(route: String, body: Data?, completion: @escaping (Data) -> Void) {
        let url = URL(string: "\(Env.serverURL)\(route)")!
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        if let body = body {
            request.httpBody = body
            print(body.toString())
        }
        
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            print(data.toString())
            print(error)
            guard let data = data else {
                print("No data in response: \(error?.localizedDescription ?? "Unknown error").")
                return
            }
            
            completion(data)
            
//            if let json = try? JSON(data: data) {
//                completion(json)
//                return
//            }
            
            
//            if let json = try? JSONSerialization.jsonObject(with: data, options: []) {
//                print("Using JSONSerialization")
//                print(json)
//                return
//            }
            
//            if let decoded = try? JSONDecoder().decode(Order.self, from: data) {
//                return decoded
//            } else {
//                print("Invalid response from server")
//            }
        }.resume()
    }
    
    static func signUp(username: String, password: String, accepted: Bool, completion: @escaping (User) -> Void) {
        struct Request: Codable {
            let username: String
            let password: String
            let accepted: Bool
        }
        guard let encoded = try? JSONEncoder().encode(["data": Request(username: username, password: password, accepted: accepted)]) else {
            print("Failed to encode body")
            return
        }
        makeRequest(route: "/api/users/create", body: encoded) { data in
            signIn(username: username, password: password, completion: completion)
        }
    }
    
    static func signIn(username: String, password: String, completion: @escaping (User) -> Void) {
        printCookies()
        deleteCookies()
        let url = URL(string: Env.serverURL)!
        guard let encoded = try? JSONEncoder().encode(["data": ["username": username, "password": password]]) else {
            print("Failed to encode body")
            return
        }
        print("before sign in call")
        makeRequest(route: "/api/sign-in", body: encoded) { data in
            print(data.toString())
            if let json = try? JSON(data: data) {
                if let token = json["token"].string {
                    let responseCookies = HTTPCookie.cookies(withResponseHeaderFields: ["Set-Cookie": "WEB_SERVICE_SESSION_KEY=\(token)"], for: url)
                    storeCookies(responseCookies, forURL: url)
                    print("finished sign in successfully")
                    hydrateAuthenticatedUser(completion: completion)
                }
            }
        }
    }
    
    static func hydrateAuthenticatedUser(completion: @escaping (User) -> Void) {
        struct Response: Codable {
            enum CodingKeys: String, CodingKey {
                case data
            }
            
            let data: User
        }
        print("made it to hydrate authenticated user")
        makeRequest(route: "/api/hydrate", body: nil) { data in
            print(data.toString())
//            if let json = try? JSON(data: data) {
//                let data = json["data"]
//                let slates = data["slates"]
//                print(slates)
//            }
            
            if let decoded = try? JSONDecoder().decode(Response.self, from: data) {
                let user = decoded.data
                print(user)
                completion(user)
            } else {
                print("failed")
            }
        }
    }
    
    static func signOut(completion: @escaping () -> Void) {
        deleteCookies()
        completion()
    }
    
    static func getSerializedProfile(id: String, completion: @escaping (User) -> Void) {
        struct Response: Codable {
            enum CodingKeys: String, CodingKey {
                case data
            }
            
            let data: User
        }
        
        guard let encoded = try? JSONEncoder().encode(["data": ["id": id]]) else {
            print("Failed to encode body")
            return
        }
        makeRequest(route: "/api/users/get-serialized", body: encoded) { data in
            print(data.toString())
            if let decoded = try? JSONDecoder().decode(Response.self, from: data) {
                let user = decoded.data
                print(user)
                completion(user)
            } else {
                print("failed")
            }
        }
    }
    
    static func getUserSocial(id: String, completion: @escaping ([Subscription], [Subscription]) -> Void) {
        struct Response: Codable {
            enum CodingKeys: String, CodingKey {
                case subscribers, subscriptions
            }
            
            let subscriptions: [Subscription]?
            let subscribers: [Subscription]?
        }
        
        guard let encoded = try? JSONEncoder().encode(["data": ["userId": id]]) else {
            print("Failed to encode body")
            return
        }
        
        makeRequest(route: "/api/users/get-social", body: encoded) { data in
            if let decoded = try? JSONDecoder().decode(Response.self, from: data) {
                completion(decoded.subscriptions ?? [Subscription](), decoded.subscribers ?? [Subscription]())
            } else {
                print("failed")
            }
        }
    }
}
