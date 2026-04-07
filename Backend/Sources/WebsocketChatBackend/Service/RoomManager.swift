//
//  RoomManager.swift
//  WebsocketChatBackend
//
//  Created by Gökalp Gürocak on 23.02.2026.
//
import Vapor

actor RoomManager {
    var rooms: [String: Room] = [:]
    let logger = Logger(label: "room.manager")
    
    func addConnectionToRoom(pin: String, participant: Participant) -> RoomManagerState {
        if var room = rooms[pin] {
            if room.partipicants.count == 1 {
                room.partipicants.append(participant)
                rooms[pin] = room
                return RoomManagerState.joined
            } else {
                return RoomManagerState.full
            }
        } else {
            return RoomManagerState.cantFound
        }
    }
    
    func addKeyDataToRoom(pin: String, clientKeyData: ClientKeyData) -> Int? {
        if var room = rooms[pin] {
            room.clientKeyData.append(clientKeyData)
            rooms[pin] = room
            return room.clientKeyData.count
        } else {
            return nil
        }
    }
    
    func removeKeyDataFromRoom(pin: String, ws: WebSocket) {
        guard var room = rooms[pin] else {
            return
        }
        guard let deviceId = getDeviceId(ws: ws) else {
            return
        }
        room.clientKeyData.removeAll { $0.deviceId == deviceId }
        rooms[pin] = room
    }
    
    func createRoom(pin: String, participant: Participant) -> RoomManagerState {
        if rooms[pin] != nil {
            return RoomManagerState.alreadyExist
        } else {
            rooms[pin] = Room(partipicants: [participant], salt: UUID().uuidString, clientKeyData: [])
            return RoomManagerState.created
        }
    }
    
    func getSalt(pin: String) -> String? {
        if let salt = rooms[pin]?.salt {
            return salt
        } else {
            return nil
        }
    }
    
    func getParticipantCount(pin: String) -> Int? {
        if let room = rooms[pin] {
            return room.partipicants.count
        } else {
            return nil
        }
    }

    
    func broadcastToRoom(pin: String, message: String) async {
        guard let room = rooms[pin] else {
            return
        }
        
        for parcipitant in room.partipicants {
            try? await parcipitant.ws.send(message)
        }
    }
    
    func getUsername(ws: WebSocket) -> String? {
        let participants = rooms.values.flatMap { $0.partipicants }
        // $0 yapip direkt room alicaksam compactMap, degilse flatMap
        // aksi taktirde [[Partipicant]] doncek
        
        let participant = participants.first { $0.ws === ws}
        return participant?.username
    }
    
    func getDeviceId(ws: WebSocket) -> String? {
        let participants = rooms.values.flatMap { $0.partipicants }
        let participant = participants.first { $0.ws === ws}
        return participant?.deviceId
    }
    
    func removeUserFromRoom(pin: String, ws: WebSocket) {
        guard var room = rooms[pin] else {
            return
        }
        room.partipicants.removeAll { $0.ws === ws }
        rooms[pin] = room
    }
    
    func checkRoomAndClose(pin: String) {
        guard let room = rooms[pin] else {
            return
        }
        if room.partipicants.count == 0 {
            rooms.removeValue(forKey: pin)
        }
    }
    
}

let roomManager = RoomManager()

