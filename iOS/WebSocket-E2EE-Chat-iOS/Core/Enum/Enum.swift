//
//  Enum.swift
//  WebSocket-E2EE-Chat-iOS
//
//  Created by Gökalp Gürocak on 22.02.2026.
//

enum roomChoice: String, CaseIterable, Identifiable {
    case create = "Host a Room"
    case join = "Join a Room"
    
    var id: String {
        self.rawValue
    }
    
    var pathComponent: String {
        switch self {
        case .create:
            return "create"
        case .join:
            return "join"
        }
    }
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

enum KeyError: Error {
    case accessControlError
    case keyGenerationFail(Error)
    case restoreError
}

enum CryptoError: Error {
    case combinedMissing
    case b64decoding
    case b64encoding
    case sealedBoxCreating(String)
    case error(String)
}

enum BaseMessageType: String {
    case handshakeReady = "handshakeReady"
    case chatMessage = "chatMessage"
    case keyData = "keyData"
    case roomMemberCount = "roomMemberCount"
    case peerDisconnected = "peer_disconnected"
}
