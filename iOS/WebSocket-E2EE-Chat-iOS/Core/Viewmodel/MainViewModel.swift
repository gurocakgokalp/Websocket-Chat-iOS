//
//  MainViewModel.swift
//  WebSocket-E2EE-Chat-iOS
//
//  Created by Gökalp Gürocak on 23.02.2026.
//
import Foundation
import Combine

class MainViewModel: ObservableObject {
    @Published var roomStatus: RoomManagerState?
    @Published var roomMemberCount: Int = 0
    @Published var peerUsername: String = ""
    @Published var username: String = ""
    @Published var messages: [Message] = []
    
    private var webSocketTask: URLSessionWebSocketTask?
    
    func connect(username: String, pin: String, createOrJoin: roomChoice) {
        guard let deviceId = IDManager.shared.getDeviceId() else {
            print("connection canceled, cannot find deviceId")
            return
        }
        guard let url = URL(string: "ws://127.0.0.1:8080/room/\(pin)/\(createOrJoin.pathComponent)") else {
            return
        }
        
        let session = URLSession(configuration: .default)
        webSocketTask = session.webSocketTask(with: url)
        
        webSocketTask?.resume()
        //önce resume olacak
        sendParticipantData(deviceId: deviceId, username: username)
        DispatchQueue.main.async{
            self.username = username
        }
        
        
        listenForMessages()
    }
    
    func disconnect() {
        webSocketTask?.cancel(with: .goingAway, reason: nil)
        DispatchQueue.main.async{
            self.username = ""
            self.messages = []
        }
    }
    
    func sendMessage(message: Message) {
        let jsonText = JSONManager.shared.prepareMessage(message: message)
        let message = URLSessionWebSocketTask.Message.string(jsonText)
        
        webSocketTask?.send(message) { err in
            if let err = err {
                print("[sendMessage] failure when sending message: \(err.localizedDescription)")
            } else {
                print("chat message sent successfully")
            }
        }
    }
    
    private func listenForMessages() {
        webSocketTask?.receive { message in
            switch message {
            case .success(let success):
                switch success {
                case .string(let text):
                    if let state = RoomManagerState(rawValue: text) {
                        DispatchQueue.main.async {
                            self.roomStatus = state
                        }
                        print(state.rawValue)
                    } else {
                        if let memberCount = Int(text) {
                            DispatchQueue.main.async {
                                self.roomMemberCount = memberCount
                            }
                        } else {
                            if let model = JSONManager.shared.decodeReadyCallAndGetPeerName(jsonText: text) {
                                // handshake islemini baslatacagiz. ama once chat ux ui oturt.
                                if model.status == "ready" {
                                    CryptoManager.shared.setSalt(saltS: model.sharedSalt)
                                    self.sendClientKeyData()
                                }
                                DispatchQueue.main.async {
                                    self.peerUsername = model.peerName
                                }
                                
                            } else {
                                if let message = JSONManager.shared.decodeChatMessage(text: text) {
                                    if let deviceId = IDManager.shared.getDeviceId() {
                                        // mesaj bana aitse ignorela
                                        if message.deviceId != deviceId {
                                            DispatchQueue.main.async {
                                                self.messages.append(message)
                                            }
                                        }
                                    }
                                } else {
                                    if let peerKeyData = JSONManager.shared.decodePeerKeyData(text: text) {
                                        print("recevied peer key data, starting handshake")
                                        CryptoManager.shared.handshake(peerKeyData: peerKeyData)
                                    } else {
                                        print("unknown chat message received")
                                    }
                                }
                            }
                        }
                    }
                case .data(let data):
                    print("data format coming: \(data)")
                @unknown default:
                    break
                }
                
                self.listenForMessages()
            case .failure(let failure):
                print("websocket listenin' error: \(failure.localizedDescription)")
            }
        }
    }
    
    func sendParticipantData(deviceId: String, username: String) {
        do {
            let jsonData = try JSONEncoder().encode(ParticipantData(username: username, deviceID: deviceId))
            guard let jsonText = String(data: jsonData, encoding: .utf8) else {
                print("error when converting json data to string")
                return
            }
            let message = URLSessionWebSocketTask.Message.string(jsonText)
            webSocketTask?.send(message) { err in
                if let err = err {
                    print("[sendParticipantData] failure when sending message: \(err.localizedDescription)")
                } else {
                    print("message (participant data) sent successfully")
                }
            }
        } catch {
            print("error when encode participantData: \(error.localizedDescription)")
            return
        }
    }
    
    func sendClientKeyData() {
        if let clientKeyData = CryptoManager.shared.getClientKeyData() {
            print("key datas ready.")
            let jsonClientKeyData = JSONManager.shared.prepareClientKeyData(data: clientKeyData)
            let message = URLSessionWebSocketTask.Message.string(jsonClientKeyData)
            
            webSocketTask?.send(message) { err in
                if let err = err {
                    print("[sendClientKeyData] failure when sending message: \(err.localizedDescription)")
                } else {
                    print("key data sent successfully")
                    print("waiting for peer data to start handshake...")
                }
            }
        }
    }
}

