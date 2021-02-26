//
//  Uploads.swift
//  Slate iOS (iOS)
//
//  Created by Martina Long on 2/25/21.
//

import Foundation
import SwiftyJSON
import Promises
import Photos
import MobileCoreServices

struct Uploads {
    static func upload(assets: [PHAsset], completion: @escaping () -> Void) {
        let uploads = formatPHAssetForUpload(assets: assets)
   
        Promise<Bool>(on: .global()) { fulfill, reject in
            for upload in uploads {
                let result = try await(Uploads.upload(item: upload))
            }
            fulfill(true)
        }.then { result in
            processPendingFiles(completion: completion)
        }.catch { error in
            print(error)
        }
    }
    
    static func formatPHAssetForUpload(assets: [PHAsset]) -> [Upload] {
        var uploads = [Upload]()
        for asset in assets {
            var isGIF = false
            var fileData: Data? = nil
            var mimeType = "application/octet-stream"
            let fileName = asset.value(forKey: "filename") as? String ?? "file"
            if let fileExtension = fileName.components(separatedBy: ".").last {
                if let extUTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, fileExtension as CFString, nil)?.takeUnretainedValue() {
                    if extUTI == kUTTypeGIF {
                        isGIF = true
                    }
                    if let mimeUTI = UTTypeCopyPreferredTagWithClass(extUTI, kUTTagClassMIMEType) {
                        mimeType = mimeUTI.takeRetainedValue() as String
                    }
                }
            }
            let mediaType = asset.mediaType
            if mediaType == .video || isGIF {
                guard let resource = PHAssetResource.assetResources(for: asset).first else {
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
                    
                    uploads.append(Upload(fileData: fileData!, fileName: fileName, mimeType: mimeType))
                })
            } else if mediaType == .image {
                print("inside image part of function")
                let manager = PHImageManager.default()
                let options = PHImageRequestOptions()
                options.isSynchronous = true
                if isGIF {
                    manager.requestImageDataAndOrientation(for: asset, options: options) { imageData, dataUTI, orientation, info in
                        if imageData != nil {
                            fileData = imageData!
                        } else {
                            print("Request image data and orientation failed")
                        }
                    }
                }
                manager.requestImage(for: asset, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFit, options: options) { result, info in
                    if result != nil {
                        var uiImage = result!
                        fileData = uiImage.jpegData(compressionQuality: 1.0)
                        uploads.append(Upload(fileData: fileData!, fileName: fileName, mimeType: mimeType))
                    } else {
                        print("Request image jpeg data failed")
                    }
                }
            }
        }
        print(uploads.count)
        return uploads
    }
    
    static func upload(documents: [URL], completion: @escaping () -> Void) {
        let uploads = Uploads.formatDocumentsForUpload(documents: documents)
   
        Promise<Bool>(on: .global()) { fulfill, reject in
            for upload in uploads {
                let result = try await(Uploads.upload(item: upload))
            }
            fulfill(true)
        }.then { result in
            processPendingFiles(completion: completion)
        }.catch { error in
            print(error)
        }
    }
    
    static func formatDocumentsForUpload(documents: [URL]) -> [Upload] {
        var uploads = [Upload]()
        for documentURL in documents {
            guard let data = try? Data(contentsOf: documentURL) else {
                print("Could not read data from documentURL")
                continue
            }
            
            let fileName = documentURL.lastPathComponent
            
            var mimeType: String? = nil
            let pathExtension = documentURL.pathExtension
            if let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, pathExtension as NSString, nil)?.takeRetainedValue() {
                if let type = UTTypeCopyPreferredTagWithClass(uti, kUTTagClassMIMEType)?.takeRetainedValue() {
                    mimeType = type as String
                } else {
                    print("failed at let type =")
                    continue
                }
            } else {
                print("failed at let uti =")
                continue
            }
            uploads.append(Upload(fileData: data, fileName: fileName, mimeType: mimeType!))
        }
        return uploads
    }
    
    static func upload(item: Upload) -> Promise<Data> {
        return Promise<Data>(on: .main) { fulfill, reject in
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
            
            URLSession.shared.uploadTask(with: request, from: data, completionHandler: { data, response, error in
                if data != nil {
                    var data = data!.toJSON()
                    print(data)
                    var json = JSON()
                    json.dictionaryObject = ["data": data]
                    print(json)
                    if let rawData = try? json.rawData() {
                        fulfill(rawData)
                        createPendingFiles(data: rawData, completion: { fulfill(rawData) })
                    }
                }
            }).resume()
        }
    }
    
    static func createPendingFiles(data: Data, completion: @escaping () -> Void) {
        //add blurhash here
        Actions.makeRequest(route: "/api/data/create-pending", body: data) { data in
            print("finished uploading and making pending")
            completion()
        }
    }
    
    static func processPendingFiles(completion: @escaping () -> Void) {
        Actions.makeRequest(route: "/api/data/process-pending", body: nil) { data in
            completion()
        }
    }
    
//    static func storageDeal(files: [Data], completion: @escaping () -> Void) {
//        //use RESOURCE_URI_STORAGE_UPLOAD for storageUploadURL
//        makeUploadRequest(url: "\(Env.storageUploadURL)/api/data", body: encoded) { data in
//            completion()
//        }
//    }
}
