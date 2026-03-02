//
//  DecodeManager.swift
//  WebsocketChatBackend
//
//  Created by Gökalp Gürocak on 23.02.2026.
//
import Vapor

actor JSONManager {
    static let shared = JSONManager()
    
    private init() {}
    
    func decodeParticipantData(ws: WebSocket, jsonText: String) -> Participant? {
        do {
            let jsonData = Data(jsonText.utf8)
            let participantData = try JSONDecoder().decode(ParticipantData.self, from: jsonData)
            return Participant(ws: ws, username: participantData.username, deviceId: participantData.deviceID)
        } catch {
            //print("[decodeParticipantData] decode error: \(error.localizedDescription)")
            return nil
        }
    }
    
    func prepareReadyMessage(peerName: String, sharedSalt: String) -> String {
        do {
            let jsonData = try JSONEncoder().encode(handshakeReady(peerName: peerName, status: "ready", sharedSalt: sharedSalt))
            guard let jsonText = String(data: jsonData, encoding: .utf8) else {
                return "unknown"
            }
            return jsonText
        } catch {
            //error modeli olusturup yollanabilir, ios tarafinda decode edilerek
            print("encode error: \(error.localizedDescription)")
            return "unknown"
        }
    }
    
    func decodeChatMessage(text: String) -> Message? {
        do {
            let jsonData = Data(text.utf8)
            return try JSONDecoder().decode(Message.self, from: jsonData)
        } catch {
            //print("[decodeChatMessage] decode error: \(error.localizedDescription)")
            return nil
        }
    }
    
    func prepareChatMessages(messages: [Message]) -> String {
        do {
            let jsonData = try JSONEncoder().encode(messages)
            guard let jsonText = String(data: jsonData, encoding: .utf8) else {
                return "unknown"
            }
            return jsonText
        } catch {
            print("encode error: \(error.localizedDescription)")
            return "unknown"
        }
    }
    
    func decodeKeyData(text: String) -> clientKeyData? {
        do {
            let jsonData = Data(text.utf8)
            return try JSONDecoder().decode(clientKeyData.self, from: jsonData)
        } catch {
            //print("[decodePeerKeyData] decode error: \(error.localizedDescription)")
            return nil
        }
    }
    func prepareKeyData(clientKeyData: clientKeyData) -> String {
        do {
            let jsonData = try JSONEncoder().encode(clientKeyData)
            guard let jsonText = String(data: jsonData, encoding: .utf8) else {
                return "unknown"
            }
            return jsonText
        } catch {
            print("encode error: \(error.localizedDescription)")
            return "unknown"
        }
    }
    
    func decodeBaseMassage(text: String) -> BaseMessage? {
        do {
            let jsonData = Data(text.utf8)
            return try JSONDecoder().decode(BaseMessage.self, from: jsonData)
        } catch {
            print("error: \(error.localizedDescription)")
            return nil
        }
    }
}
