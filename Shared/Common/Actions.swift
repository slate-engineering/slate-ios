//
//  Actions.swift
//  Slate iOS (iOS)
//
//  Created by Martina Long on 1/22/21.
//

import Foundation
import SwiftyJSON

struct Actions {
    static func toString(data: Data) -> String {
        return String(decoding: data, as: UTF8.self)
    }
    
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
    
    static func deleteCookies(forURL url: URL) {
        let cookieStorage = HTTPCookieStorage.shared

        for cookie in readCookie(forURL: url) {
            cookieStorage.deleteCookie(cookie)
        }
    }
    
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
    
    static func signIn(username: String, password: String) {
        let url = URL(string: Env.serverURL)!
        let cookies = readCookie(forURL: url)
        print("Cookies before request: ", cookies)
        guard let encoded = try? JSONEncoder().encode(["data": ["username": username, "password": password]]) else {
            print("Failed to encode body")
            return
        }
        makeRequest(route: "/api/sign-in", body: encoded) { data in
            if let json = try? JSON(data: data) {
                if let token = json["token"].string {
                    let responseCookies = HTTPCookie.cookies(withResponseHeaderFields: ["Set-Cookie": "WEB_SERVICE_SESSION_KEY=\(token)"], for: url)
                    storeCookies(responseCookies, forURL: url)
                    
                    hydrateAuthenticatedUser()
                }
            }
            
        }
    }
    
    static func hydrateAuthenticatedUser() {
        struct Response: Codable {
            enum CodingKeys: String, CodingKey {
                case data
            }
            
            let data: User
        }
        
        makeRequest(route: "/api/hydrate", body: nil) { data in
//            if let json = try? JSON(data: data) {
//                let user = json["data"]
//                let library = user["library"]
//                print("library:")
//                print(library)
//                let first = library[0]
//                print("first:")
//                print(first)
//                let files = first["children"]
//                print("files:")
//                print(files)
//            }
            
            if let decoded = try? JSONDecoder().decode(Response.self, from: data) {
                let user = decoded.data
                print(user)
            } else {
                print("failed")
            }
//            if let json = try? JSON(data: data) {
//                let user = json["data"]
//                print("got to after json[data]")
//                do {
//                    let rawUser = try user.rawData()
//                    if let decoded = try? JSONDecoder().decode(User.self, from: rawUser) {
//                        print("decoded raw user")
//                        print(decoded)
//                    } else {
//                        print("Unable to decode serer response to User object")
//                    }
//                } catch {
//                    print("Error \(error)")
//                }
//
//            }
//            if let response = data as? [String: Any] {
//                if let user = response["data"] as? User {
//                    print(user)
//                }
//            }
//            if let decoded = try? JSONDecoder().decode(User.self, from: data) {
//                print(decoded)
//            } else {
//                print("Invalid response from server")
//            }
        }
    }
    
//    static func testEncoding() {
//        let children = [File(cid: "cid here", id: "id here", file: "filename here", name: "name here", size: 28, type: "type here", blurhash: "blurhash here")]
//        let library = Library(children: children)
//        let libraries = [library]
//        let data = UserData(body: "My name is martina", library: libraries, name: "Martina Long", photo: "photolinkhere")
//        let user = User(id: "2093u0923ur", username: "martina", data: data)
//    }
}
