//
//  Actions.swift
//  Slate iOS (iOS)
//
//  Created by Martina Long on 1/22/21.
//

import Foundation
import SwiftyJSON
import Promises
import Photos
import MobileCoreServices

struct Actions {
    // MARK: - Cookies
    static func readCookies(forURL url: URL) -> [HTTPCookie] {
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
        hydrateAuthenticatedUser() { user in
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
    
    static func checkSignedIn(completion: @escaping (Bool) -> Void) {
        let url = URL(string: Env.serverURL)!
        let cookies = readCookies(forURL: url)
        for cookie in cookies {
            if cookie.name == Env.sessionKey {
                completion(true)
                return
            }
        }
        completion(false)
    }
    
    static func signUp(username: String, password: String, accepted: Bool, completion: @escaping (User) -> Void) {
        struct Request: Codable {
            let username: String
            let password: String
            let accepted: Bool
        }
        guard let encoded = try? JSONEncoder().encode(["data": Request(username: username, password: password, accepted: accepted)]) else {
            print("Failed to encode body in signUp")
            return
        }
        makeRequest(route: "/api/users/create", body: encoded) { data in
            signIn(username: username, password: password, completion: completion)
        }
    }
    
    static func signIn(username: String, password: String, completion: @escaping (User) -> Void) {
        deleteCookies()
        let url = URL(string: Env.serverURL)!
        guard let encoded = try? JSONEncoder().encode(["data": ["username": username, "password": password]]) else {
            print("Failed to encode body in signIn")
            return
        }
        makeRequest(route: "/api/sign-in", body: encoded) { data in
            print(data.toJSON())
            if let json = try? JSON(data: data) {
                if let token = json["token"].string {
                    let expiry = NSDate(timeIntervalSinceNow: 3600 * 24 * 7)
                    print(url)
                    let properties: [HTTPCookiePropertyKey : Any] = [
                        HTTPCookiePropertyKey.domain: Env.cookieDomain,
                        HTTPCookiePropertyKey.path: "/",
                        HTTPCookiePropertyKey.name: Env.sessionKey,
                        HTTPCookiePropertyKey.value: token,
                        HTTPCookiePropertyKey.expires: expiry,
                    ]
                    let cookie = HTTPCookie(properties: properties)!
                    HTTPCookieStorage.shared.setCookie(cookie)
                    
                    //old version
//                    let responseCookies = HTTPCookie.cookies(withResponseHeaderFields: ["Set-Cookie": "WEB_SERVICE_SESSION_KEY_OLD=\(token)"], for: url)
//                    storeCookies(responseCookies, forURL: url)
                    
                    printCookies()
                    hydrateAuthenticatedUser(completion: completion)
                } else {
                    print("Could not get token from json in signIn")
                }
            } else {
                print("Could not get JSON from data in signIn")
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
                print("Failed in hydrateAuthenticatedUser while decoding")
            }
        }
    }
    
    static func signOut(completion: @escaping () -> Void) {
        deleteCookies()
        completion()
    }
    
    static func deleteAccount(completion: @escaping () -> Void) {
        makeRequest(route: "/api/users/delete", body: nil) { data in
            completion()
        }
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
            print("Failed to encode body in getSerializedUser")
            return
        }
        makeRequest(route: "/api/users/get-serialized", body: encoded) { data in
            if let decoded = try? JSONDecoder().decode(Response.self, from: data) {
                let user = decoded.data
                completion(user)
            } else {
                print("Failed in getSerializedUser while decoding")
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
            print("Failed to encode body in getUserSocial")
            return
        }
        
        makeRequest(route: "/api/users/get-social", body: encoded) { data in
            if let decoded = try? JSONDecoder().decode(Response.self, from: data) {
                completion(decoded.subscriptions ?? [Subscription](), decoded.subscribers ?? [Subscription]())
            } else {
                print("Failed in getUserSocial while decoding")
            }
        }
    }
    
    static func subscribeUser(id: String, completion: @escaping () -> Void) {
        guard let encoded = try? JSONEncoder().encode(["data": ["userId": id]]) else {
            print("Failed to encode body in subscribeUser")
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
            print("Failed to encode body in editUser")
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
            print("Failed to encode body in getSerializedSlate")
            return
        }
        makeRequest(route: "/api/slates/get-serialized", body: encoded) { data in
            if let decoded = try? JSONDecoder().decode(Response.self, from: data) {
                let slate = decoded.data
                completion(slate)
            } else {
                print("Failed in getSerializedSlate while decoding")
            }
        }
    }
    
    static func subscribeSlate(id: String, completion: @escaping () -> Void) {
        guard let encoded = try? JSONEncoder().encode(["data": ["slateId": id]]) else {
            print("Failed to encode body in subscribeSlate")
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
            print("Failed to encode body in createSlate")
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
            print("Failed to encode body in editSlate")
            return
        }
        
        makeRequest(route: "/api/slates/update", body: encoded) { data in
            completion()
        }
    }
    
    static func deleteSlate(id: String, completion: @escaping () -> Void) {
        guard let encoded = try? JSONEncoder().encode(["data": ["id": id]]) else {
            print("Failed to encode body in deleteSlate")
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
    
    static func uploadImagesAndVideos(assets: [PHAsset], completion: @escaping () -> Void) {
        for asset in assets {
            var fileData: Data? = nil
            var mimeType = "application/octet-stream"
            
            let fileName = asset.value(forKey: "filename") as? String ?? "file"
            if let fileExtension = fileName.components(separatedBy: ".").last {
                if let extUTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, fileExtension as CFString, nil)?.takeUnretainedValue() {
                    if let mimeUTI = UTTypeCopyPreferredTagWithClass(extUTI, kUTTagClassMIMEType) {
                        mimeType = mimeUTI.takeRetainedValue() as String
                    }
                }
            }
            
            let mediaType = asset.mediaType
            if mediaType == .image {
                let manager = PHImageManager.default()
                let option = PHImageRequestOptions()
                option.isSynchronous = true
                manager.requestImage(for: asset, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFit, options: option) { result, info in
                    if result != nil {
                        var uiImage = result!
                        fileData = uiImage.jpegData(compressionQuality: 1.0)
                        Actions.upload(item: Upload(fileData: fileData!, fileName: fileName, mimeType: mimeType), completion: completion)
                    } else {
                        print("Request image jpeg data failed")
                    }
                }
//                manager.requestImageDataAndOrientation(for: asset, options: nil) { imageData, dataUTI, orientation, info in
//                    if imageData != nil {
//                        fileData = imageData!
//                        Actions.upload(item: Upload(fileData: fileData!, fileName: fileName, mimeType: mimeType)) {
//                            Actions.rehydrateViewer(viewer: viewer)
//                            print("upload complete for file named \(fileName) of type \(mimeType)")
//                        }
//                    } else {
//                        print("Request image data and orientation failed")
//                    }
//                }
            } else if mediaType == .video {
                guard let resource = PHAssetResource.assetResources(for: asset).first else {
                    print("Could not get assetResources for video")
                    continue
                }
                let fileName = resource.originalFilename
                var writeURL: URL? = nil
                if #available(iOS 10.0, *) {
                    writeURL = FileManager.default.temporaryDirectory.appendingPathComponent("\(fileName)")
                } else {
                    writeURL = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true).appendingPathComponent("\(fileName)")
                }
                guard let localURL = writeURL else {
                    print("Could not get writeURL for video")
                    continue
                }
                let options = PHAssetResourceRequestOptions()
                options.isNetworkAccessAllowed = false
                PHAssetResourceManager.default().writeData(for: resource, toFile: localURL, options: options, completionHandler: { error in
                    if let error = error {
                        print("Error while writing data: \n\(error.localizedDescription)")
                    }
                    print(localURL)
                    
                    guard let data = try? Data(contentsOf: localURL) else {
                        print("Could not read data from localURL")
                        return
                    }
                    fileData = data
                    
                    Actions.upload(item: Upload(fileData: fileData!, fileName: fileName, mimeType: mimeType), completion: completion)
                })
            }
        }
    }
    
    static func upload(item: Upload, completion: @escaping () -> Void) {
        var authorization = ""
        let cookieStorage = HTTPCookieStorage.shared
        for cookie in cookieStorage.cookies! {
            if cookie.name == Env.sessionKey {
                authorization = cookie.value
            }
        }
        let fileData = item.fileData
        let fileName = item.fileName
        let mimeType = item.mimeType
        let boundary = UUID().uuidString
        let url = URL(string: "\(Env.uploadURL)/api/data/\(item.fileName)")!
        var request = URLRequest(url: url)
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.setValue(authorization, forHTTPHeaderField: "authorization")
        request.httpMethod = "POST"
        
        let fieldName = "data"
        var data = Data()
        
        data.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
        data.append("Content-Disposition: form-data; name=\"\(fieldName)\"; filename=\"\(fileName)\"\r\n".data(using: .utf8)!)
        data.append("Content-Type: \(mimeType)\r\n\r\n".data(using: .utf8)!)
        data.append(fileData)
        data.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        
//        request.httpBody = data
//        URLSession.shared.dataTask(with: request) { data, response, error in
//            //also, shoudl convert heic to another format before uploading
//            print("upload task complete")
//            if data != nil {
//                createPendingFiles(data: data!, completion: completion)
//            }
////            var data = data!.toJSON()
////            print(data)
////            data = data["data"]
////            print(data)
////            var json = JSON()
////            json.dictionaryObject = ["data": data]
////            print(json)
////            if let rawData = try? json.rawData() {
////                print("converted to raw data")
//////                createPendingFiles(data: rawData)
////            }
//
//        }.resume()
        URLSession.shared.uploadTask(with: request, from: data, completionHandler: { data, response, error in
            if data != nil {
                var data = data!.toJSON()
                print(data)
                var json = JSON()
                json.dictionaryObject = ["data": data]
                print(json)
                if let rawData = try? json.rawData() {
                    createPendingFiles(data: rawData, completion: completion)
                }
            }
        }).resume()
        
        
        //optimize with this https://medium.com/livefront/uploading-data-in-the-background-in-ios-f93722013c6a#:~:text=The%20key%20difference%20Apple%20describes,continue%20execution%20in%20the%20background.
    }
    
    static func createPendingFiles(data: Data, completion: @escaping () -> Void) {
        //add blurhash here
        makeRequest(route: "/api/data/create-pending", body: data) { data in
            processPendingFiles(completion: completion)
        }
    }
    
    static func processPendingFiles(completion: @escaping () -> Void) {
        makeRequest(route: "/api/data/process-pending", body: nil) { data in
            completion()
        }
    }
    
//    static func storageDeal(files: [Data], completion: @escaping () -> Void) {
//        //use RESOURCE_URI_STORAGE_UPLOAD for storageUploadURL
//        makeUploadRequest(url: "\(Env.storageUploadURL)/api/data", body: encoded) { data in
//            completion()
//        }
//    }
    
    static func makeUploadRequest(url: String, item: Upload, completion: @escaping () -> Void) {
        var authorization = ""
        let cookieStorage = HTTPCookieStorage.shared
        for cookie in cookieStorage.cookies! {
            if cookie.name == Env.sessionKey {
                authorization = cookie.value
            }
        }
        let fileData = item.fileData
        let fileName = item.fileName
        let mimeType = item.mimeType
        let boundary = UUID().uuidString
        let url = URL(string: url)!
        var request = URLRequest(url: url)
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.setValue(authorization, forHTTPHeaderField: "authorization")
        request.httpMethod = "POST"
        
        let fieldName = "data"
        var data = Data()
        
        data.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
        data.append("Content-Disposition: form-data; name=\"\(fieldName)\"; filename=\"\(fileName)\"\r\n".data(using: .utf8)!)
        data.append("Content-Type: \(mimeType)\r\n\r\n".data(using: .utf8)!)
        data.append(fileData)
        data.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = data
        URLSession.shared.dataTask(with: request) { data, response, error in
            completion()
        }.resume()
        
        URLSession.shared.uploadTask(with: request, from: data, completionHandler: { data, response, error in
            completion()
        }).resume()
        
        
//        let fieldName = "data"
//        let data = NSMutableData()
//        data.appendString("--\(boundary)\r\n")
//        data.appendString("Content-Disposition: form-data; name=\"\(fieldName)\"; filename=\"\(fileName)\"\r\n")
//        data.appendString("Content-Type: \(mimeType)\r\n\r\n")
//        data.append(fileData)
//        data.appendString("\r\n")
        
//        let httpBody = NSMutableData()
//        httpBody.append(data as Data)
//        httpBody.appendString("--\(boundary)--")
//        request.httpBody = httpBody as Data
        
//        URLSession.shared.dataTask(with: request) { data, response, error in
//            print(data.toString())
//            print(error)
//            guard let data = data else {
//                print("No data in response: \(error?.localizedDescription ?? "Unknown error").")
//                return
//            }
//            completion()
//        }.resume()
    }
    
    // MARK: - Activity
    
    static func getActivity(earliestTimestamp: String? = nil, latestTimestamp: String? = nil, completion: @escaping ([Activity]) -> Void) {
        struct Response: Codable {
            enum CodingKeys: String, CodingKey {
                case activity
            }
            
            let activity: [Activity]
        }
        
        guard let encoded = try? JSONEncoder().encode(["data": ["earliestTimestamp": earliestTimestamp, "latestTimestamp": latestTimestamp]]) else {
            print("Failed to encode body in getActivity")
            return
        }
        
        makeRequest(route: "/api/activity/get", body: encoded) { data in
            print(data.toJSON())
            if let decoded = try? JSONDecoder().decode(Response.self, from: data) {
                let activity = decoded.activity
                completion(activity)
            } else {
                print("Failed in getActivity while decoding")
            }
        }
    }
    
    static func getExplore(earliestTimestamp: String? = nil, latestTimestamp: String? = nil, completion: @escaping ([Activity]) -> Void) {
        struct Request: Codable {
            let earliestTimestamp: String?
            let latestTimestamp: String?
            let explore: Bool
        }
        
        struct Response: Codable {
            enum CodingKeys: String, CodingKey {
                case activity
            }
            
            let activity: [Activity]
        }
        
        guard let encoded = try? JSONEncoder().encode(["data": Request(earliestTimestamp: earliestTimestamp, latestTimestamp: latestTimestamp, explore: true)]) else {
            print("Failed to encode body in getExplore")
            return
        }
        
        makeRequest(route: "/api/activity/get", body: encoded) { data in
            if let decoded = try? JSONDecoder().decode(Response.self, from: data) {
                let activity = decoded.activity
                completion(activity)
            } else {
                print("Failed in getExplore while decoding")
            }
        }
    }
}
