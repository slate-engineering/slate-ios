//
//  AssetsPickerView.swift
//  Slate iOS (iOS)
//
//  Created by Martina Long on 2/11/21.
//

import SwiftUI
import Photos
import AssetsPickerViewController

struct AssetsPicker: UIViewControllerRepresentable {
    class Coordinator: NSObject, AssetsPickerViewControllerDelegate, UINavigationControllerDelegate {
        var parent: AssetsPicker
        
        init(_ parent: AssetsPicker) {
            self.parent = parent
        }
        
//        func pressedPick(_ sender: Any) {
//            logi("SUCCESS")
//            print("hit pressed pick")
////            let picker = AssetsPickerViewController()
////            picker.isShowLog = true
////            picker.pickerDelegate = self
////            present(picker, animated: true, completion: nil)
//        }
        
        func assetsPicker(controller: AssetsPickerViewController, selected assets: [PHAsset]) {
            logi("SUCCESS")
            print("hit function 1 - selected")
            print(assets)
            self.parent.assets = assets
        }
        
//        func assetsPicker(controller: AssetsPickerViewController, shouldSelect asset: PHAsset, at indexPath: IndexPath) -> Bool {
//            logi("SUCCESS")
//            print("hit function 2 - shouldselect")
////                logi("shouldSelect: \(indexPath.row)")
////
////                // can limit selection count
////                if controller.selectedAssets.count > 3 {
////                    // do your job here
////                }
//                return true
//        }
//
//        func assetsPicker(controller: AssetsPickerViewController, didSelect asset: PHAsset, at indexPath: IndexPath) {
//            logi("SUCCESS")
//            print("hit function 3 - didselect")
//            //                logi("didSelect: \(indexPath.row)")
//        }
//
//        func assetsPicker(controller: AssetsPickerViewController, shouldDeselect asset: PHAsset, at indexPath: IndexPath) -> Bool {
//            logi("SUCCESS")
//            print("hit function 4 - shouldselect")
//            //                logi("shouldDeselect: \(indexPath.row)")
//            return true
//        }
//
//        func assetsPicker(controller: AssetsPickerViewController, didDeselect asset: PHAsset, at indexPath: IndexPath) {
//            logi("SUCCESS")
//            print("hit function 5 - didselect")
//            //                logi("didDeselect: \(indexPath.row)")
//        }
//
//        func assetsPicker(controller: AssetsPickerViewController, didDismissByCancelling byCancel: Bool) {
//            logi("SUCCESS")
//            print("hit function 6 - diddismiss")
//            //                logi("dismiss completed - byCancel: \(byCancel)")
//        }
    }
    
    @Binding var assets: [PHAsset]
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIViewController(context: Context) -> AssetsPickerViewController {
        let picker = AssetsPickerViewController()
        picker.pickerDelegate = context.coordinator
        print("in make uiview controller")
        print(picker)
        print(picker.pickerDelegate)
        return picker
    }
    
    func updateUIViewController(_ uiViewController: AssetsPickerViewController, context: Context) {
        print("update ui view controller")
        print(assets.count)
    }
}

struct DocumentPicker: UIViewControllerRepresentable {
    class Coordinator: NSObject, UIDocumentPickerDelegate {
        var parent: DocumentPicker
        
        init(_ parent: DocumentPicker) {
            self.parent = parent
        }
        
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            self.parent.documents = urls
        }
    }
    
    @Binding var documents: [URL]
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(documentTypes: ["com.apple.iwork.pages.pages", "com.apple.iwork.numbers.numbers", "com.apple.iwork.keynote.key","public.image", "com.apple.application", "public.item","public.data", "public.content", "public.audiovisual-content", "public.movie", "public.audiovisual-content", "public.video", "public.audio", "public.text", "public.data", "public.zip-archive", "com.pkware.zip-archive", "public.composite-content", "public.text"], in: .import)
        picker.allowsMultipleSelection = true
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {
        
    }
}

//struct ImagePickerView: UIViewControllerRepresentable {
//    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
//        var parent: ImagePickerView
//
//        init(_ parent: ImagePickerView) {
//            self.parent = parent
//        }
//        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
//
//            if let uiImage = info[.originalImage] as? UIImage {
//                parent.images.append(uiImage)
//            }
//            parent.presentationMode.wrappedValue.dismiss()
//        }
//    }
//
//    @Binding var images: [UIImage]
//    @Environment(\.presentationMode) var presentationMode
//
//    func makeCoordinator() -> Coordinator {
//        Coordinator(self)
//    }
//
//    func makeUIViewController(context: Context) -> UIImagePickerController {
//        let picker = UIImagePickerController()
//        picker.delegate = context.coordinator
//                //optional stuff:
//                //pickerController.allowsEditing = true
//                //pickerController.mediaTypes = ["public.image", "public.movie"]
//                //pickerController.sourceType = .camera must enable camera usage in plist
//        return picker
//    }
//
//    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
//
//    }
//
//    typealias UIViewControllerType = UIImagePickerController
//}
