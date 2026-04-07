//
//  JSONManager.swift
//  WebSocket-E2EE-Chat-iOS
//
//  Created by Gökalp Gürocak on 28.02.2026.
//
import Foundation

class JSONManager {
    static let shared = JSONManager()
    
    private init() {}
    
    func decodeReadyCallAndGetPeerName(jsonText: String) -> HandshakeReady? {
        let textData = Data(jsonText.utf8)
        do {
            return try JSONDecoder().decode(HandshakeReady.self, from: textData)
        } catch {
            //print("[decodeReadyCallAndGetPeerName] decode error: \(error.localizedDescription)")
            return nil
        }
    }
    
    func prepareMessage(message: Message) -> String {
        do {
            let data = try JSONEncoder().encode(message)
            guard let jsonText = String(data: data, encoding: .utf8) else {
                return "unknown"
            }
            return jsonText
        } catch {
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
    
    func prepareClientKeyData(data: ClientKeyData) -> String {
        do {
            let data = try JSONEncoder().encode(data)
            guard let jsonText = String(data: data, encoding: .utf8) else {
                return "unknown"
            }
            return jsonText
        } catch {
            print("encode error: \(error.localizedDescription)")
            return "unknown"
        }
    }
    
    func decodePeerKeyData(text: String) -> ClientKeyData? {
        do {
            let jsonData = Data(text.utf8)
            return try JSONDecoder().decode(ClientKeyData.self, from: jsonData)
        } catch {
            //print("[decodePeerKeyData] decode error: \(error.localizedDescription)")
            return nil
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
    
    func decodeMemberCount(text: String) -> RoomMemberCount? {
        do {
            let jsonData = Data(text.utf8)
            return try JSONDecoder().decode(RoomMemberCount.self, from: jsonData)
        } catch {
            print("error: \(error.localizedDescription)")
            return nil
        }
    }
}
