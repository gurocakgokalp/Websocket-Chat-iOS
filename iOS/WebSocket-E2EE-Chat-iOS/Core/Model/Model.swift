//
//  Model.swift
//  WebSocket-E2EE-Chat-iOS
//
//  Created by Gökalp Gürocak on 24.02.2026.
//
import Foundation

struct ParticipantData: Codable {
    let type: String
    let username: String
    let deviceID: String
}
struct handshakeReady: Codable {
    let type: String
    let peerName: String
    let status: String
    let sharedSalt: String
}

struct Message: Codable, Identifiable {
    let type: String
    //let message: String
    let ciphertext: String
    let signature: String
    let nonce: String
    let tag: String
    //
    let username: String
    let deviceId: String
    let timestamp: Int
    var id = UUID()
    
    var plainText: String?
    
    // plainText eklemedim so codable degil yani, ayirt ediliyor
    enum CodingKeys: String, CodingKey {
        case type, ciphertext, signature, deviceId, nonce, tag, username, timestamp, id
    }
}

struct clientKeyData: Codable {
    let type: String
    let agreementPKey: String
    let signPKey: String
    let deviceId: String
}

struct encryptedMessageText {
    let ciphertext: String
    let signature: String
    let nonce: String
    let tag: String
}

struct BaseMessage: Codable {
    let type: String
}

struct roomMemberCount: Codable {
    let type: String
    let count: Int
}
