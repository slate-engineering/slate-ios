////
////  Websocket.swift
////  Slate iOS (iOS)
////
////  Created by Martina Long on 2/9/21.
////
//
////import Foundation
////import Starscream
////
////
////class Pubsub: WebSocketDelegate {
////    var socket: WebSocket
////
////    init() {
////        var request = URLRequest(url: URL(string: Env.pubsubURL)!)
////        request.timeoutInterval = 5
////        socket = WebSocket(request: request)
////        socket.connect()
////    }
////
////    deinit {
////        socket.disconnect()
////    }
////
////    func didReceive(event: WebSocketEvent, client: WebSocket) {
////      switch event {
////      case .connected(let headers):
////        print("connected \(headers)")
////      case .disconnected(let reason, let closeCode):
////        print("disconnected \(reason) \(closeCode)")
////      case .text(let text):
////        print("received text: \(text)")
////      case .binary(let data):
////        print("received data: \(data)")
////      case .pong(let pongData):
////        print("received pong: \(pongData)")
////      case .ping(let pingData):
////        print("received ping: \(pingData)")
////      case .error(let error):
////        print("error \(error)")
////      case .viabilityChanged:
////        print("viabilityChanged")
////      case .reconnectSuggested:
////        print("reconnectSuggested")
////      case .cancelled:
////        print("cancelled")
////      }
////    }
////}
//
//
//import UIKit
//import SwiftUI
//import Starscream
//
////struct StarscreamWebSocket: UIViewControllerRepresentable {
////    func makeUIViewController(context: UIViewControllerRepresentableContext<StarscreamWebSocket>) -> UIViewController {
////        let socket = UIViewController
////        viewer.
////    }
////
////    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<StarscreamWebSocket>) {
////        //
////    }
////}
//
//class ViewController: UIViewController, WebSocketDelegate {
//    var socket: WebSocket!
//    var isConnected = false
//    let server = WebSocketServer()
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
////        let err = server.start(address: "localhost", port: 8080)
////        if err != nil {
////            print("server didn't start!")
////        }
////        server.onEvent = { event in
////            switch event {
////            case .text(let conn, let string):
////                let payload = string.data(using: .utf8)!
////                conn.write(data: payload, opcode: .textFrame)
////            default:
////                break
////            }
////        }
//        //https://echo.websocket.org
//        var request = URLRequest(url: URL(string: "http://localhost:8080")!) //https://localhost:8080
//        request.timeoutInterval = 5
//        socket = WebSocket(request: request)
//        socket.delegate = self
//        socket.connect()
//    }
//    
//    // MARK: - WebSocketDelegate
//    func didReceive(event: WebSocketEvent, client: WebSocket) {
//        switch event {
//        case .connected(let headers):
//            isConnected = true
//            print("websocket is connected: \(headers)")
//        case .disconnected(let reason, let code):
//            isConnected = false
//            print("websocket is disconnected: \(reason) with code: \(code)")
//        case .text(let string):
//            print("Received text: \(string)")
//        case .binary(let data):
//            print("Received data: \(data.count)")
//        case .ping(_):
//            break
//        case .pong(_):
//            break
//        case .viabilityChanged(_):
//            break
//        case .reconnectSuggested(_):
//            break
//        case .cancelled:
//            isConnected = false
//        case .error(let error):
//            isConnected = false
//            handleError(error)
//        }
//    }
//    
//    func handleError(_ error: Error?) {
//        if let e = error as? WSError {
//            print("websocket encountered an error: \(e.message)")
//        } else if let e = error {
//            print("websocket encountered an error: \(e.localizedDescription)")
//        } else {
//            print("websocket encountered an error")
//        }
//    }
//    
//    // MARK: Write Text Action
//    
//    @IBAction func writeText(_ sender: UIBarButtonItem) {
//        socket.write(string: "hello there!")
//    }
//    
//    // MARK: Disconnect Action
//    
//    @IBAction func disconnect(_ sender: UIBarButtonItem) {
//        if isConnected {
//            sender.title = "Connect"
//            socket.disconnect()
//        } else {
//            sender.title = "Disconnect"
//            socket.connect()
//        }
//    }
//    
//}
