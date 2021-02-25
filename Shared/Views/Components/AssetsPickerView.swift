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
        return picker
    }
    
    func updateUIViewController(_ uiViewController: AssetsPickerViewController, context: Context) {
        
    }
}
