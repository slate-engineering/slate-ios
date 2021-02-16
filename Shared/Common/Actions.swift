//
//  Actions.swift
//  Slate iOS (iOS)
//
//  Created by Martina Long on 1/22/21.
//

import Foundation
import SwiftyJSON

struct Actions {
    // MARK: - Cookies
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
    
    // MARK: Make request
    static func makeRequest(route: String, body: Data?, completion: @escaping (Data) -> Void) {
        let url = URL(string: "\(Env.serverURL)\(route)")!
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        if let body = body {
            request.httpBody = body
//            print(body.toString())
        }
        
        
        URLSession.shared.dataTask(with: request) { data, response, error in
//            print(data.toString())
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
    
    // MARK: - Rehydrate (temp till websockets added)
    static func rehydrateViewer(viewer: User) {
        getSerializedUser(id: viewer.id) { user in
            DispatchQueue.main.async {
                viewer.copyUserDetails(from: user)
                viewer.saveToUserDefaults()
            }
        }
    }
    
    static func rehydrateSocial(viewer: User) {
        getUserSocial(id: viewer.id) { subscriptions, subscribers in
            DispatchQueue.main.async {
                viewer.copySocial(subscriptions: subscriptions, subscribers: subscribers)
                viewer.saveToUserDefaults()
            }
        }
    }
    
    // MARK: - Authentication
    
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
            if let json = try? JSON(data: data) {
                if let token = json["token"].string {
                    let responseCookies = HTTPCookie.cookies(withResponseHeaderFields: ["Set-Cookie": "WEB_SERVICE_SESSION_KEY=\(token)"], for: url)
                    storeCookies(responseCookies, forURL: url)
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
        makeRequest(route: "/api/hydrate", body: nil) { data in
            if let decoded = try? JSONDecoder().decode(Response.self, from: data) {
                let user = decoded.data
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
    
    // MARK: - Users
    
    static func getSerializedUser(id: String, completion: @escaping (User) -> Void) {
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
            if let decoded = try? JSONDecoder().decode(Response.self, from: data) {
                let user = decoded.data
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
    
    static func subscribeUser(id: String, completion: @escaping () -> Void) {
        guard let encoded = try? JSONEncoder().encode(["data": ["userId": id]]) else {
            print("Failed to encode body")
            return
        }
        
        makeRequest(route: "/api/subscribe", body: encoded) { data in
            completion()
        }
    }
    
    static func editUser(name: String, username: String, description: String, password: String? = nil) {
        struct Request: Codable {
            let username: String
            let password: String?
            let data: Data
            
            struct Data: Codable {
                enum CodingKeys: String, CodingKey {
                    case description = "body"
                    case name
                }
                
                let description: String
                let name: String
            }
        }
        
        guard let encoded = try? JSONEncoder().encode(["data": Request(username: username, password: password, data: Request.Data(description: description, name: name))]) else {
            print("Failed to encode body")
            return
        }
        
        makeRequest(route: "/api/users/update", body: encoded) { data in
        }
    }
    
    // MARK: - Slates
    
//    static func getSlate
    
    static func getSerializedSlate(id: String, completion: @escaping (Slate) -> Void) {
        struct Response: Codable {
            enum CodingKeys: String, CodingKey {
                case data
            }
            
            let data: Slate
        }
        
        guard let encoded = try? JSONEncoder().encode(["data": ["id": id]]) else {
            print("Failed to encode body")
            return
        }
        makeRequest(route: "/api/slates/get-serialized", body: encoded) { data in
            if let decoded = try? JSONDecoder().decode(Response.self, from: data) {
                let slate = decoded.data
                completion(slate)
            } else {
                print("failed")
            }
        }
    }
    
    static func subscribeSlate(id: String, completion: @escaping () -> Void) {
        guard let encoded = try? JSONEncoder().encode(["data": ["slateId": id]]) else {
            print("Failed to encode body")
            return
        }
        
        makeRequest(route: "/api/subscribe", body: encoded) { data in
            completion()
        }
    }
    
    static func createSlate(name: String, description: String, isPublic: Bool, completion: @escaping () -> Void) {
        struct Request: Codable {
            enum CodingKeys: String, CodingKey {
                case isPublic = "public"
                case description = "body"
                case name
            }
            
            let name: String
            let description: String
            let isPublic: Bool
        }
        
        guard let encoded = try? JSONEncoder().encode(["data": Request(name: name, description: description, isPublic: isPublic)]) else {
            print("Failed to encode body")
            return
        }
        
        makeRequest(route: "/api/slates/create", body: encoded) { data in
            completion()
        }
    }
    
    static func editSlate(id: String, name: String, description: String, isPublic: Bool, completion: @escaping () -> Void) {
        struct Request: Codable {
            let id: String
            let data: Data
            
            struct Data: Codable {
                enum CodingKeys: String, CodingKey {
                    case isPublic = "public"
                    case description = "body"
                    case name
                }
                
                let name: String
                let description: String
                let isPublic: Bool
            }
        }
        
        guard let encoded = try? JSONEncoder().encode(["data": Request(id: id, data: Request.Data(name: name, description: description, isPublic: isPublic))]) else {
            print("Failed to encode body")
            return
        }
        
        makeRequest(route: "/api/slates/update", body: encoded) { data in
            completion()
        }
    }
    
    static func deleteSlate(id: String, completion: @escaping () -> Void) {
        guard let encoded = try? JSONEncoder().encode(["data": ["id": id]]) else {
            print("Failed to encode body")
            return
        }
        
        makeRequest(route: "/api/slates/delete", body: encoded) { data in
            completion()
        }
    }
    
    // MARK: - Data
    
    func convertFileData(fieldName: String, fileName: String, mimeType: String, fileData: Data, using boundary: String) -> Data {
      let data = NSMutableData()

      data.appendString("--\(boundary)\r\n")
      data.appendString("Content-Disposition: form-data; name=\"\(fieldName)\"; filename=\"\(fileName)\"\r\n")
      data.appendString("Content-Type: \(mimeType)\r\n\r\n")
      data.append(fileData)
      data.appendString("\r\n")

      return data as Data
    }
    
    static func upload(file: Data, completion: @escaping () -> Void) {
        let fileName = "get the filename of the file"
        
        makeUploadRequest(url: "\(Env.uploadURL)/api/data/\(fileName)", fileData: file) {
            completion()
        }
    }
    
//    static func storageDeal(files: [Data], completion: @escaping () -> Void) {
//        //use RESOURCE_URI_STORAGE_UPLOAD for storageUploadURL
//        makeUploadRequest(url: "\(Env.storageUploadURL)/api/data", body: encoded) { data in
//            completion()
//        }
//    }
    
    static func makeUploadRequest(url: String, fileData: Data, completion: @escaping () -> Void) {
        let boundary = "Boundary-\(UUID().uuidString)"
        let url = URL(string: url)!
        var request = URLRequest(url: url)
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        
        
        let fieldName = "data"
        let fileName = "get the filename of the file"
        let mimeType = "get the mimetype of the file"
        
        let data = NSMutableData()
        data.appendString("--\(boundary)\r\n")
        data.appendString("Content-Disposition: form-data; name=\"\(fieldName)\"; filename=\"\(fileName)\"\r\n")
        data.appendString("Content-Type: \(mimeType)\r\n\r\n")
        data.append(fileData)
        data.appendString("\r\n")
        
        let httpBody = NSMutableData()
        httpBody.append(data as Data)
//        httpBody.appendString("--\(boundary)--")
//        request.httpBody = httpBody as Data
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            print(data.toString())
            print(error)
            guard let data = data else {
                print("No data in response: \(error?.localizedDescription ?? "Unknown error").")
                return
            }
            completion()
        }.resume()
    }
}
