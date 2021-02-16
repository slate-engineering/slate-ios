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
                } else if viewIndex == 2 {
                    ScrollView(.vertical) {
                        Spacer()
                            .frame(height: 52)
                        LazyVStack(spacing: 1) {
                            ForEach(0..<(viewer.files?.count ?? 0)) { index in
                                HStack(spacing: 8) {
                                    FiletypeIconView(type: viewer.files![index].type)
                                        .frame(width: 20, height: 20)
                                        .foregroundColor(Color("black"))
                                    Text(viewer.files![index].name)
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
                            ForEach(0..<(viewer.files?.count ?? 0)) { index in
                                MediaPreviewView(viewer.files![index], width: (viewIndex == 0 ? (geo.size.width - 48) / 2 : geo.size.width - 32))
                                    .background(Color.white)
                                    .shadow(color: Color(red: 178/255, green: 178/255, blue: 178/255).opacity(0.15), radius: 10, x: 0, y: 5)
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
        
        print("got to load images")
        print(assets.count)
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
            
            let mediaType = asset.mediaType
            if mediaType == .image {
                mimeType = "image/jpeg"
                manager.requestImageDataAndOrientation(for: asset, options: nil) { imageData, dataUTI, orientation, info in
                    if imageData != nil {
                        fileData = imageData!
                    }
                }
            } else if mediaType == .video {
                mimeType = "video/mov"
                manager.requestExportSession(forVideo: asset, options: nil, exportPreset: "video") { exportSession, info in
                    print(exportSession)
                    print(type(of: exportSession))
                    //left off figuring out how to get the data out here and assign to filedata
                    if exportSession != nil {
                        print(exportSession!.outputFileType)
                    }
                }
            }
            
            let fileName = asset.value(forKey: "filename") as? String ?? "file"
            if let fileExtension = fileName.components(separatedBy: ".").last {
                if let extUTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, fileExtension as CFString, nil)?.takeUnretainedValue() {
                    if let mimeUTI = UTTypeCopyPreferredTagWithClass(extUTI, kUTTagClassMIMEType) {
                        mimeType = mimeUTI.takeRetainedValue() as String
                    }
                }
            }
            
            if fileData != nil {
                files.append(Upload(fileData: fileData!, fileName: fileName, mimeType: mimeType))
            }
        }
    }
}
