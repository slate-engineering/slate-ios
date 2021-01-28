//
//  AlertMessage.swift
//  Slate iOS (iOS)
//
//  Created by Martina Long on 1/22/21.
//

import Foundation

struct AlertMessage: Identifiable {
    let id = UUID()
    let title: String
    let message: String
}
