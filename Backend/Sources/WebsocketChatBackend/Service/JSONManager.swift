//
//  DecodeManager.swift
//  WebsocketChatBackend
//
//  Created by Gökalp Gürocak on 23.02.2026.
//
import Vapor

actor JSONManager {
    static let shared = JSONManager()
    let logger = Logger(label: "json.manager")
    
    private init() {}
    
    func decodeParticipantData(ws: WebSocket, jsonText: String) -> Participant? {
        do {
            let jsonData = Data(jsonText.utf8)
            let participantData = try JSONDecoder().decode(ParticipantData.self, from: jsonData)
            return Participant(ws: ws, username: participantData.username, deviceId: participantData.deviceID)
        } catch {
            logger.error("Decoding Error: \(error.localizedDescription)", metadata: ["context": "participantData"])
            return nil
        }
    }
    
    func prepareReadyMessage(peerName: String, sharedSalt: String) -> String {
        do {
            let jsonData = try JSONEncoder().encode(HandshakeReady(type: "handshakeReady", peerName: peerName, status: "ready", sharedSalt: sharedSalt))
            guard let jsonText = String(data: jsonData, encoding: .utf8) else {
                return "unknown"
            }
            return jsonText
        } catch {
            logger.error("Encoding Error: \(error.localizedDescription)", metadata: ["context": "handshakeReady"])
            return "unknown"
        }
    }
    
    func decodeChatMessage(text: String) -> Message? {
        do {
            let jsonData = Data(text.utf8)
            return try JSONDecoder().decode(Message.self, from: jsonData)
        } catch {
            logger.error("Decoding Error: \(error.localizedDescription)", metadata: ["context": "chatMessage"])
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
            logger.error("Encoding Error: \(error.localizedDescription)", metadata: ["context": "chatMessage"])
            return "unknown"
        }
    }
    func prepareRoomCount(count: Int) -> String {
        do {
            let jsonData = try JSONEncoder().encode(RoomMemberCount(type: "roomMemberCount", count: count))
            guard let jsonText = String(data: jsonData, encoding: .utf8) else {
                return "unknown"
            }
            return jsonText
        } catch {
            logger.error("Encoding Error: \(error.localizedDescription)", metadata: ["context": "RoomMemberCount"])
            return "unknown"
        }
    }
    
    func decodeKeyData(text: String) -> ClientKeyData? {
        do {
            let jsonData = Data(text.utf8)
            return try JSONDecoder().decode(ClientKeyData.self, from: jsonData)
        } catch {
            //print("[decodePeerKeyData] decode error: \(error.localizedDescription)")
            logger.error("Decoding Error: \(error.localizedDescription)", metadata: ["context": "keyData"])
            return nil
        }
    }
    func prepareKeyData(clientKeyData: ClientKeyData) -> String {
        do {
            let jsonData = try JSONEncoder().encode(clientKeyData)
            guard let jsonText = String(data: jsonData, encoding: .utf8) else {
                return "unknown"
            }
            return jsonText
        } catch {
            logger.error("Encoding Error: \(error.localizedDescription)", metadata: ["context": "keyData"])
            return "unknown"
        }
    }
    
    func decodeBaseMassage(text: String) -> BaseMessage? {
        do {
            let jsonData = Data(text.utf8)
            return try JSONDecoder().decode(BaseMessage.self, from: jsonData)
        } catch {
            logger.error("Decoding Error: \(error.localizedDescription)", metadata: ["context": "baseMessage"])
            return nil
        }
    }
}
