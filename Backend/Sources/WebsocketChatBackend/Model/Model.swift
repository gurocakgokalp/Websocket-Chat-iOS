//
//  Model.swift
//  WebsocketChatBackend
//
//  Created by Gökalp Gürocak on 23.02.2026.
//
import Vapor

struct Participant {
    let ws: WebSocket
    let username: String
    let deviceId: String
}
struct ParticipantData: Codable {
    let type: String
    let username: String
    let deviceID: String
}

struct HandshakeReady: Codable {
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
    let timestamp: Int
    var id = UUID()

}

struct ClientKeyData: Codable {
    let type: String
    let agreementPKey: String
    let signPKey: String
    let deviceId: String
}

struct Room {
    var partipicants: [Participant]
    var salt: String
    var clientKeyData: [ClientKeyData]
}

struct RoomMemberCount: Codable {
    let type: String
    let count: Int
}

struct BaseMessage: Codable {
    let type: String
}
