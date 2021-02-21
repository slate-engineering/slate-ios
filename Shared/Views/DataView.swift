//
//  DataView.swift
//  Slate iOS (iOS)
//
//  Created by Martina Long on 1/25/21.
//

import SwiftUI
import AssetsPickerViewController
import Photos
import MobileCoreServices

struct DataView: View {
    @EnvironmentObject var viewer: User
    let views = ["Gallery", "Column", "List"]
    @State private var viewIndex = 0
    @State private var showingActionSheet = false
    @State private var showingImagePicker = false
    @State private var showingDocumentPicker = false
    let singleColumn: [GridItem] = [
        GridItem(.flexible())
    ]
    let doubleColumn: [GridItem] = [
        GridItem(.flexible(), spacing: Constants.sideMargin),
        GridItem(.flexible(), spacing: Constants.sideMargin)
    ]
    @State private var images = [Image]()
    @State private var assets = [PHAsset]()
    @State private var documents = [URL]()
    
    var body: some View {
        let showingPicker = Binding<Bool>(
            get: {
                showingImagePicker || showingDocumentPicker
            },
            set: {
                if !$0 {
                    showingImagePicker = false
                    showingDocumentPicker = false
                }
            }
        )
        GeometryReader { geo in
            ZStack {
                if viewer.files == nil || viewer.files!.count == 0 {
                    EmptyStateView(text: "Add files using the upload button", icon: Image("folder"))
                        .padding(.horizontal, 16)
                        .padding(.top, 52)
                } else if viewIndex == 2 {
                    ScrollView(.vertical) {
                        Spacer()
                            .frame(height: 52)
                        LazyVStack(spacing: 1) {
                            if viewer.files != nil {
                                ForEach(viewer.files!, id: \.id) { file in
                                    HStack(spacing: 8) {
                                        FiletypeIconView(type: file.type)
                                            .frame(width: 20, height: 20)
                                            .foregroundColor(Color("black"))
                                        Text(file.name)
                                            .font(Font.custom("Inter", size: 14))
    //                                        .fontWeight(.medium)
                                            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .leading)
                                    }
                                    .padding(10)
                                    .background(Color("white"))
                                    .frame(height: 40)
                                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .topLeading)
                                }
                            }
                        }
                        .shadow(color: Color(red: 178/255, green: 178/255, blue: 178/255).opacity(0.15), radius: 10, x: 0, y: 5)
                        .padding(.horizontal, Constants.sideMargin)
                        Spacer()
                            .frame(height: Constants.bottomMargin)
                    }
                } else {
                    ScrollView(.vertical) {
                        Spacer()
                            .frame(height: 8)
                        LazyVGrid(columns: viewIndex == 0 ? doubleColumn : singleColumn, alignment: .center, spacing: 16) {
                            if viewer.files != nil {
                                ForEach(viewer.files!, id: \.id) { file in
                                    MediaPreviewView(file, width: (viewIndex == 0 ? (geo.size.width - 48) / 2 : geo.size.width - 32))
                                        .background(Color.white)
                                        .shadow(color: Color(red: 178/255, green: 178/255, blue: 178/255).opacity(0.15), radius: 10, x: 0, y: 5)
                                }
                            }
                        }
                        .padding(.horizontal, Constants.sideMargin)
                        Spacer()
                            .frame(height: Constants.bottomMargin)
                    }
                }
                PageOverlayView(pickerOptions: views, pickerIndex: $viewIndex) {
                    TranslucentButtonView(type: .text, action: { showingActionSheet = true }) {
                        Text("Upload")
                            .font(Font.custom("Inter", size: 14))
                            .fontWeight(.medium)
                    }
                }
                .actionSheet(isPresented: $showingActionSheet) {
                    ActionSheet(title: Text("Upload from"), buttons: [
                        .default(Text("Files")) { showingDocumentPicker = true },
                        .default(Text("Photo library")) { showingImagePicker = true },
                        .cancel()
                    ])
                }
                .sheet(isPresented: showingPicker, onDismiss: loadImages) {
                    if showingImagePicker {
                        AssetsPicker(assets: $assets)
                    } else {
                        DocumentPicker(documents: $documents)
                    }
                }
                .padding(.bottom, 52)
            }
        }
    }
    
    func loadImages() {
        var files = [Upload]()
        
        let manager = PHImageManager.default()
        let option = PHImageRequestOptions()
        for asset in assets {
//            var uiImage = UIImage()
//            option.isSynchronous = true
//            manager.requestImage(for: asset, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFit, options: option) { result, info in
//                uiImage = result!
//            }
//            images.append(Image(uiImage: uiImage))
            
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
//            print(fileName)
//            print(mimeType)
            
            let mediaType = asset.mediaType
            if mediaType == .image {
                manager.requestImageDataAndOrientation(for: asset, options: nil) { imageData, dataUTI, orientation, info in
//                    print("imageData")
//                    print(imageData)
//                    print(dataUTI)
                    if imageData != nil {
                        fileData = imageData!
                        Actions.upload(item: Upload(fileData: fileData!, fileName: fileName, mimeType: mimeType)) {
                            Actions.rehydrateViewer(viewer: viewer)
                            print("upload complete for file named \(fileName) of type \(mimeType)")
                        }
                    } else {
                        print("Request image data and orientation failed")
                    }
                }
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
                })
                
                guard let data = try? Data(contentsOf: localURL) else {
                    print("Could not read data from localURL")
                    continue
                }
                fileData = data
                
                Actions.upload(item: Upload(fileData: fileData!, fileName: fileName, mimeType: mimeType)) {
                    Actions.rehydrateViewer(viewer: viewer)
                    print("upload complete for file named \(fileName) of type \(mimeType)")
                }
                
//                let options = PHVideoRequestOptions()
//                        options.deliveryMode = .highQualityFormat
//                        options.isNetworkAccessAllowed = true
//                manager.requestExportSession(forVideo: asset, options: options, exportPreset: AVAssetExportPresetHighestQuality) { exportSession, info in
//                    if exportSession == nil {
//                        print("could not export video properly")
//                    } else {
//                        exportSession.outputURL = ""
//                        exportSession!.outputFileType = AVFileType.mp4
//
//                        exportSession!.exportAsynchronously() {
//                            print("EXPORT DONE")
//                        }
//
//                        print("progress: \(exportSession!.progress)")
//                        print("error: \(exportSession!.error)")
//                        print("status: \(exportSession!.status.rawValue)")
//                    }
//
//                    print("exportSession:")
//                    print(exportSession)
//                    //set export preset name, output file type
//                    exportSession?.exportAsynchronously {
//
//                    }
//
//                    //left off figuring out how to get the data out here and assign to filedata
//                    if exportSession != nil {
//                        print(exportSession!.outputFileType)
//                    } else {
//                        print("export session is nil")
//                    }
//                }
            }
//            print("fileData")
//            print(fileData)
//            
//            if fileData != nil {
////                files.append(Upload(fileData: fileData!, fileName: fileName, mimeType: mimeType))
//                print("actions.upload calling")
//                Actions.upload(item: Upload(fileData: fileData!, fileName: fileName, mimeType: mimeType)) {
//                    print("upload complete for file named \(fileName) of type \(mimeType)")
//                }
//            } else {
//                print("File data was nil")
//            }
        }
        //do something with files
    }
}
