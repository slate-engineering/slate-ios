//
//  Constants.swift
//  Slate iOS (iOS)
//
//  Created by Martina Long on 1/21/21.
//

import SwiftUI
import Foundation

struct Constants {
    static let gatewayURL = "https://slate.textile.io/ipfs"
    static let profileImageDefault = "https://slate.textile.io/ipfs/bafkreifvdvygknj66bfqdximxmxobqelwhd3xejiq3vfplhzkopcfdetrq"
    static let topMargin: CGFloat = 52
    static let bottomMargin: CGFloat = 96
    static let sideMargin: CGFloat = 16
    
    enum FileType {
        case image, video, audio, pdf, epub, other
    }
}

