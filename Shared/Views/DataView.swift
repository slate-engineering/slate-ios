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
import Promises

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
                Color("foreground")
                    .edgesIgnoringSafeArea(.all)
                
                if viewer.library?[0].children == nil || viewer.library?[0].children?.count == 0 {
                    EmptyStateView(text: "Add files using the upload button", icon: Image("folder"))
                        .padding(.horizontal, 16)
                        .padding(.top, 52)
                } else if viewIndex == 2 {
                    ScrollView(.vertical) {
                        Spacer()
                            .frame(height: 52)
                        LazyVStack(spacing: 1) {
                            if viewer.library?[0].children != nil {
                                ForEach(viewer.library![0].children!, id: \.id) { file in
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
//                        Spacer()
//                            .frame(height: Constants.bottomMargin)
                    }
                } else {
                    ScrollView(.vertical) {
                        Spacer()
                            .frame(height: 8)
                        LazyVGrid(columns: viewIndex == 0 ? doubleColumn : singleColumn, alignment: .center, spacing: 16) {
                            if viewer.library?[0].children != nil {
                                ForEach(viewer.library![0].children!, id: \.id) { file in
                                    MediaPreviewView(file, width: (viewIndex == 0 ? (geo.size.width - 48) / 2 : geo.size.width - 32))
                                        .background(Color.white)
                                        .shadow(color: Color(red: 178/255, green: 178/255, blue: 178/255).opacity(0.15), radius: 10, x: 0, y: 5)
                                }
                            }
                        }
                        .padding(.horizontal, Constants.sideMargin)
//                        Spacer()
//                            .frame(height: Constants.bottomMargin)
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
                .sheet(isPresented: showingPicker, onDismiss: showingImagePicker ? uploadFromPhotoLibrary : {}) {
                    if showingImagePicker {
                        AssetsPicker(assets: $assets)
                            .edgesIgnoringSafeArea(.bottom)
                    } else {
                        DocumentPicker(documents: $documents, completion: uploadFromDocuments)
                            .edgesIgnoringSafeArea(.bottom)
                    }
                }
                .padding(.bottom, 8)
            }
        }
    }
    
    func uploadFromPhotoLibrary() {
        Uploads.upload(assets: assets) { Actions.rehydrateViewer(viewer: viewer) }
    }
    
    func uploadFromDocuments() {
        Uploads.upload(documents: documents) { Actions.rehydrateViewer(viewer: viewer) }
    }
}
