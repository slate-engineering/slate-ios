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
        let url = URL(string: Env.serverURL)!
        guard let encoded = try? JSONEncoder().encode(["data": ["username": username, "password": password]]) else {
            print("Failed to encode body")
            return
        }
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
            if let json = try? JSON(data: data) {
                let subscribers = json["subscribers"]
                print(subscribers)
                let subscriptions = json["subscriptions"]
                print(subscriptions)
            }
            
            
            if let decoded = try? JSONDecoder().decode(Response.self, from: data) {
                let user = decoded.data
                print(user)
                completion(user)
            } else {
                print("failed")
            }
        }
    }
}
//{"id":"d7906b2f-eed1-42b3-bf96-1e4c173c9bdd","owner_user_id":"5172dd8b-6b11-40d3-8c9f-b4cbaa0eb8e7","target_slate_id":null,"target_user_id":"296e0692-209d-4bd3-b736-43cdb8e07a3f","data":null,"created_at":"2020-11-09T01:51:44.683Z","user":{"type":"USER","id":"296e0692-209d-4bd3-b736-43cdb8e07a3f","username":"gndclouds","slates":[],"data":{"name":"","photo":"https://hub.textile.io/ipfs/bafybeic25subftulrkrxrw2ggpjblamofj3uemi2vaoqmlqzyzg2lfji5q","body":""}},"owner":{"type":"USER","id":"5172dd8b-6b11-40d3-8c9f-b4cbaa0eb8e7","username":"martina","slates":[],"data":{"name":"Martina Long","photo":"https://slate.textile.io/ipfs/bafkreibgcxe7kpkvgwycv557wiw4adpfreqbvql36hzlcedqhjdyzvr2ei","body":"My name is Martina. Working at @slate right now todayaaaaaaa"}},"slate":null},{"id":"04fa2aa8-5097-4a04-935b-d39d24d8e854","owner_user_id":"5172dd8b-6b11-40d3-8c9f-b4cbaa0eb8e7","target_slate_id":null,"target_user_id":"f9cc7b00-ce59-4b49-abd1-c7ef7253e258","data":null,"created_at":"2020-12-03T00:10:05.808Z","user":{"type":"USER","id":"f9cc7b00-ce59-4b49-abd1-c7ef7253e258","username":"martinatest","slates":[],"data":{"name":"","photo":"https://slate.textile.io/ipfs/bafkreick3nscgixwfpq736forz7kzxvvhuej6kszevpsgmcubyhsx2pf7i","body":""}},"owner":{"type":"USER","id":"5172dd8b-6b11-40d3-8c9f-b4cbaa0eb8e7","username":"martina","slates":[],"data":{"name":"Martina Long","photo":"https://slate.textile.io/ipfs/bafkreibgcxe7kpkvgwycv557wiw4adpfreqbvql36hzlcedqhjdyzvr2ei","body":"My name is Martina. Working at @slate right now todayaaaaaaa"}},"slate":null},{"id":"0aefa016-f3e6-4bef-bc0c-69cf8676fb13","owner_user_id":"5172dd8b-6b11-40d3-8c9f-b4cbaa0eb8e7","target_slate_id":null,"target_user_id":"754c4847-b710-4674-addb-5a4a0d79fb2c","data":null,"created_at":"2020-12-03T00:10:21.987Z","user":{"type":"USER","id":"754c4847-b710-4674-addb-5a4a0d79fb2c","username":"martinatest1","slates":[],"data":{"name":"","photo":"https://slate.textile.io/ipfs/bafkreick3nscgixwfpq736forz7kzxvvhuej6kszevpsgmcubyhsx2pf7i","body":""}},"owner":{"type":"USER","id":"5172dd8b-6b11-40d3-8c9f-b4cbaa0eb8e7","username":"martina","slates":[],"data":{"name":"Martina Long","photo":"https://slate.textile.io/ipfs/bafkreibgcxe7kpkvgwycv557wiw4adpfreqbvql36hzlcedqhjdyzvr2ei","body":"My name is Martina. Working at @slate right now todayaaaaaaa"}},"slate":null}
//,{"id":"75c8bfc1-70a9-4fb8-95d6-9ccaa365350a","owner_user_id":"5172dd8b-6b11-40d3-8c9f-b4cbaa0eb8e7","target_slate_id":"8d319e2d-f22f-4a7c-a977-924583521936","target_user_id":null,"data":null,"created_at":"2020-12-15T01:49:43.305Z","user":null,"owner":{"type":"USER","id":"5172dd8b-6b11-40d3-8c9f-b4cbaa0eb8e7","username":"martina","slates":[],"data":{"name":"Martina Long","photo":"https://slate.textile.io/ipfs/bafkreibgcxe7kpkvgwycv557wiw4adpfreqbvql36hzlcedqhjdyzvr2ei","body":"My name is Martina. Working at @slate right now todayaaaaaaa"}},"slate":{"type":"SLATE","id":"8d319e2d-f22f-4a7c-a977-924583521936","slatename":"meta","data":{"ownerId":"be6d00ba-678c-48c3-a975-a2440cea4578","name":"Meta","body":"Our experience of digital objects and substances provides a further basis for understanding. Once we can identify our experiences as entities or substances, we can refer to them, categorize them, group them and quantify them—and, by this means, reason about them.","objects":[{"id":"data-09772be3-ce84-4fe2-a180-aa80ef7f5130","cid":"bafybeig3gcirazf2hgzlkg7uvhbw6wu52hlnf5mrgpltf2ldscopoejzqq","url":"https://slate.textile.io/ipfs/bafybeig3gcirazf2hgzlkg7uvhbw6wu52hlnf5mrgpltf2ldscopoejzqq","name":"data-7d02c494-d727-43ad-b5dd-91826b76cb97","size":626626,"type":"image/jpeg","ownerId":"be6d00ba-678c-48c3-a975-a2440cea4578"},{"id":"data-70be7af7-a6f0-4462-8796-ca0ec1220b62","cid":"bafybeibldkar7jxigru6fuwerro3sqxyh7afivp4vdthgjc52h4dxvn3my","url":"https://slate.textile.io/ipfs/bafybeibldkar7jxigru6fuwerro3sqxyh7afivp4vdthgjc52h4dxvn3my","name":"data-f64e3605-c96e-4193-80c8-0fa84994433d","size":527949,"type":"image/jpeg","ownerId":"be6d00ba-678c-48c3-a975-a2440cea4578"},{"id":"data-5f7e777d-0ed3-4438-abd3-60d151c7e3c4","cid":"bafkreihbqztfcwyt34kzrwzgb5ftmtucbjspeox4qeqh4ei5kg4sf5kliu","url":"https://slate.textile.io/ipfs/bafkreihbqztfcwyt34kzrwzgb5ftmtucbjspeox4qeqh4ei5kg4sf5kliu","name":"data-43e74437-1352-4fb8-886a-930e8decf514","size":55442,"type":"image/png","ownerId":"be6d00ba-678c-48c3-a975-a2440cea4578"},{"id":"data-721c5149-b246-4bdb-adf6-0ba248639eae","cid":"bafkreicfa4kqxgfvijlbjglojd4wkxr2gkalcacbshvos4ivj3eauqhwz4","url":"https://slate.textile.io/ipfs/bafkreicfa4kqxgfvijlbjglojd4wkxr2gkalcacbshvos4ivj3eauqhwz4","name":"data-3d94c57c-3beb-4849-96ee-a7521d3b4a3d","size":52366,"type":"image/png","ownerId":"be6d00ba-678c-48c3-a975-a2440cea4578"},{"id":"data-91227202-6825-46e6-ad8e-476a2118be9b","cid":"bafkreifjyqhlajkgckesqskpkn5ssxmlhkepw7rggfo7cdc2ibd2mc4pgi","url":"https://slate.textile.io/ipfs/bafkreifjyqhlajkgckesqskpkn5ssxmlhkepw7rggfo7cdc2ibd2mc4pgi","name":"data-682e2ea9-e59a-4daf-964b-16a175332260","size":70016,"type":"image/png","ownerId":"be6d00ba-678c-48c3-a975-a2440cea4578"},{"id":"data-25cfb6d7-3153-4260-8de3-02a6f42681bb","cid":"bafkreiax3b4qkzyvsvl7vslvytlgnl2zlzcg4dsglq7wn7ue22kko32czu","url":"https://slate.textile.io/ipfs/bafkreiax3b4qkzyvsvl7vslvytlgnl2zlzcg4dsglq7wn7ue22kko32czu","name":"data-fa1bd28e-604b-4e06-aff8-76d99611e5b4","size":53173,"type":"image/png","ownerId":"be6d00ba-678c-48c3-a975-a2440cea4578"},{"id":"data-0a9ba020-4a11-4c7c-9c16-30f39ce7be44","cid":"bafkreiatbw5rfnrig7nm5blnjdygbyrnjt6nyeh6ywiz3rxa6ztcwban64","url":"https://slate.textile.io/ipfs/bafkreiatbw5rfnrig7nm5blnjdygbyrnjt6nyeh6ywiz3rxa6ztcwban64","name":"data-35d6883e-98be-432a-9379-16922e994d21","size":33082,"type":"image/jpeg","ownerId":"be6d00ba-678c-48c3-a975-a2440cea4578"},{"id":"data-3b2f2d6b-fd87-4ef6-8099-62317dd7e6c7","cid":"bafkreidpyqdxevhc3hrzjezpoffqlquy6i37dk3xfmwthnd4nakk5f2ika","url":"https://slate.textile.io/ipfs/bafkreidpyqdxevhc3hrzjezpoffqlquy6i37dk3xfmwthnd4nakk5f2ika","name":"data-4aab36e6-e0bc-46bf-9764-f2e42861538c","size":150312,"type":"image/png","ownerId":"be6d00ba-678c-48c3-a975-a2440cea4578"},{"id":"data-b9c042e3-dfda-4eb0-a1a2-d855f058870f","cid":"bafkreihuchwzdpc5jse4l7hwyxyw6t5qxoxln4stddlyzewfhurmuu32c4","url":"https://slate.textile.io/ipfs/bafkreihuchwzdpc5jse4l7hwyxyw6t5qxoxln4stddlyzewfhurmuu32c4","name":"data-534a0de4-5aac-466f-bf0d-c585eab96258","size":151146,"type":"image/png","ownerId":"be6d00ba-678c-48c3-a975-a2440cea4578"},{"id":"data-20567ba5-03a4-43ef-9145-2fb7ca831a51","cid":"bafkreiehlemmware22ukbljcavn7zotxu2iytkk2hje3lylxkbyvnb6mja","url":"https://slate.textile.io/ipfs/bafkreiehlemmware22ukbljcavn7zotxu2iytkk2hje3lylxkbyvnb6mja","name":"data-eee758d4-0955-42b1-8a81-a22d938fed1c","size":17423,"type":"image/jpeg","ownerId":"be6d00ba-678c-48c3-a975-a2440cea4578"},{"id":"data-bc8332d2-de11-4763-b4a6-9888b5876213","cid":"bafkreieuspjcad5hxjp5tgffmeoz7tkgyx44xrbdti2ypf5sd4lqwrsura","url":"https://slate.textile.io/ipfs/bafkreieuspjcad5hxjp5tgffmeoz7tkgyx44xrbdti2ypf5sd4lqwrsura","name":"data-227ed6b1-32bb-4098-b535-09b245c07152","size":10032,"type":"image/jpeg","ownerId":"be6d00ba-678c-48c3-a975-a2440cea4578"},{"id":"data-83a671c9-1e93-49fb-8fad-cd43debb49e5","cid":"bafkreietkbuy2pnazsvvobnwhmbx2re357inqmyjmbndcywvdk6t3ksvwm","url":"https://slate.textile.io/ipfs/bafkreietkbuy2pnazsvvobnwhmbx2re357inqmyjmbndcywvdk6t3ksvwm","name":"data-f93682ef-7b46-4fa0-9028-17fffae669c4","size":16954,"type":"image/jpeg","ownerId":"be6d00ba-678c-48c3-a975-a2440cea4578"},{"id":"data-411de40f-497c-4855-b198-037ec2cb5598","cid":"bafybeihulakzyr3fixeeykcjolteleisrl25ta66hyy2zwrxbexcnjpe4a","url":"https://slate.textile.io/ipfs/bafybeihulakzyr3fixeeykcjolteleisrl25ta66hyy2zwrxbexcnjpe4a","name":"original_6affa64983f9d42bcc5b610bbb29efbf.png","size":274046,"type":"image/png","title":"original_6affa64983f9d42bcc5b610bbb29efbf.png","ownerId":"be6d00ba-678c-48c3-a975-a2440cea4578"}],"layouts":{"ver":"2.0","layout":[{"h":197.33333333333334,"w":200,"x":0,"y":0,"z":0,"id":"data-09772be3-ce84-4fe2-a180-aa80ef7f5130"},{"h":169.34306569343065,"w":200,"x":220,"y":0,"z":0,"id":"data-70be7af7-a6f0-4462-8796-ca0ec1220b62"},{"h":200,"w":200,"x":440,"y":0,"z":0,"id":"data-5f7e777d-0ed3-4438-abd3-60d151c7e3c4"},{"h":200,"w":200,"x":660,"y":0,"z":0,"id":"data-721c5149-b246-4bdb-adf6-0ba248639eae"},{"h":200,"w":200,"x":880,"y":0,"z":0,"id":"data-91227202-6825-46e6-ad8e-476a2118be9b"},{"h":200,"w":200,"x":0,"y":217.33333333333334,"z":0,"id":"data-25cfb6d7-3153-4260-8de3-02a6f42681bb"},{"h":133.5064935064935,"w":200,"x":220,"y":189.34306569343065,"z":0,"id":"data-0a9ba020-4a11-4c7c-9c16-30f39ce7be44"},{"h":143.11111111111111,"w":200,"x":440,"y":220,"z":0,"id":"data-3b2f2d6b-fd87-4ef6-8099-62317dd7e6c7"},{"h":141.07142857142858,"w":200,"x":660,"y":220,"z":0,"id":"data-b9c042e3-dfda-4eb0-a1a2-d855f058870f"},{"h":200,"w":200,"x":880,"y":220,"z":0,"id":"data-20567ba5-03a4-43ef-9145-2fb7ca831a51"},{"h":200,"w":200,"x":0,"y":437.33333333333337,"z":0,"id":"data-bc8332d2-de11-4763-b4a6-9888b5876213"},{"h":200,"w":200,"x":220,"y":342.84955919992416,"z":0,"id":"data-83a671c9-1e93-49fb-8fad-cd43debb49e5"},{"h":202.78745644599303,"w":200,"x":440,"y":383.1111111111111,"z":0,"id":"data-411de40f-497c-4855-b198-037ec2cb5598"}],"fileNames":false,"defaultLayout":true},"public":true}}},{"id":"905dd4cd-a054-45c5-af24-61f4b94a94c4","owner_user_id":"5172dd8b-6b11-40d3-8c9f-b4cbaa0eb8e7","target_slate_id":null,"target_user_id":"be6d00ba-678c-48c3-a975-a2440cea4578","data":null,"created_at":"2021-01-16T20:23:47.211Z","user":{"type":"USER","id":"be6d00ba-678c-48c3-a975-a2440cea4578","username":"haris","slates":[],"data":{"name":"Haris Butt","photo":"https://slate.host/static/a1.jpg","body":"Object oriented."}},"owner":{"type":"USER","id":"5172dd8b-6b11-40d3-8c9f-b4cbaa0eb8e7","username":"martina","slates":[],"data":{"name":"Martina Long","photo":"https://slate.textile.io/ipfs/bafkreibgcxe7kpkvgwycv557wiw4adpfreqbvql36hzlcedqhjdyzvr2ei","body":"My name is Martina. Working at @slate right now todayaaaaaaa"}},"slate":null}],"subscribers":[{"id":"d94dd0b0-b4db-4ecb-abcf-c0d08c747371","owner_user_id":"ee4817fb-5b57-4a6c-b762-9127a2cdc04f","target_slate_id":null,"target_user_id":"5172dd8b-6b11-40d3-8c9f-b4cbaa0eb8e7","data":null,"created_at":"2020-10-24T06:05:57.677Z","user":{"type":"USER","id":"5172dd8b-6b11-40d3-8c9f-b4cbaa0eb8e7","username":"martina","slates":[],"data":{"name":"Martina Long","photo":"https://slate.textile.io/ipfs/bafkreibgcxe7kpkvgwycv557wiw4adpfreqbvql36hzlcedqhjdyzvr2ei","body":"My name is Martina. Working at @slate right now todayaaaaaaa"}},"owner":{"type":"USER","id":"ee4817fb-5b57-4a6c-b762-9127a2cdc04f","username":"tuna","slates":[],"data":{"name":"","photo":"https://bafybeiabcoa7egpafljp6rnfhdbz7ifhnc27hpocu7clgld5oxsbjjimri.ipfs.slate.textile.io","body":"A user of Slate."}},"slate":null}]}}
