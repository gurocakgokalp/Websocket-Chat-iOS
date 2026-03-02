//
//  Enum.swift
//  WebsocketChatBackend
//
//  Created by Gökalp Gürocak on 23.02.2026.
//
import Vapor

enum DecodeError: Error {
    case DecodeError
}

enum RoomManagerState: String, Identifiable {
    case joined = "Joined Room"
    case created = "Created Room"
    case full = "Room is Full"
    case cantFound = "Room not Found"
    case alreadyExist = "Already Exist Room"
    
    var id: String {
        self.rawValue
    }

}

enum MessageType: String {
    case partipicantData = "participantData"
    case keyData = "keyData"
    case chatMessage = "chatMessage"
}

