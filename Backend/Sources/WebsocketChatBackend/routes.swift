import Vapor

func routes(_ app: Application) throws {
    app.get { req async in
        "Server works!"
    }

    app.webSocket("room", ":pin", ":createOrJoin") { req, ws in
        let pin = req.parameters.get("pin")!
        let createOrJoin = req.parameters.get("createOrJoin")!
        
        ws.onText { ws, text in
            if let baseMessage = await JSONManager.shared.decodeBaseMassage(text: text) {
                switch MessageType(rawValue: baseMessage.type) {
                case .partipicantData:
                    if let participant = await JSONManager.shared.decodeParticipantData(ws: ws, jsonText: text) {
                        Task {
                            if createOrJoin == "join" {
                                let status = await roomManager.addConnectionToRoom(pin: pin, participant: participant)
                                if status == .joined {
                                    if let username = await roomManager.getUsername(ws: ws) {
                                        req.logger.info("\(username) Joined", metadata: ["pin": .string(pin)])
                                    } else {
                                        req.logger.info("Unknown Joined", metadata: ["pin": .string(pin)])
                                    }
                                    if let roomMemberCount = await roomManager.getParticipantCount(pin: pin) {
                                        let memberCountString = await JSONManager.shared.prepareRoomCount(count: roomMemberCount)
                                        await roomManager.broadcastToRoom(pin: pin, message: memberCountString)
                                            
                                        if roomMemberCount >= 2 {
                                            req.logger.debug("Room is Full, Pre-Handshake Completed", metadata: ["pin": .string(pin)])
                                            if let partipicants = await roomManager.rooms[pin]?.partipicants {
                                                let first = partipicants[0]
                                                let second = partipicants[1]
                                                
                                                if let salt = await roomManager.getSalt(pin: pin) {
                                                    let messageToFirst = await JSONManager.shared.prepareReadyMessage(peerName: second.username, sharedSalt: salt)
                                                    req.logger.debug("Handshake Request Sent", metadata: ["deviceId": .string(first.deviceId)])
                                                    let messageToSecond = await JSONManager.shared.prepareReadyMessage(peerName: first.username, sharedSalt: salt)
                                                    req.logger.debug("Handshake Request Sent", metadata: ["deviceId": .string(second.deviceId)])
                                                    try await first.ws.send(messageToFirst)
                                                    try await second.ws.send(messageToSecond)
                                                } else {
                                                    req.logger.error("Cannot Requset Handshake", metadata: ["context": "salt"])
                                                }
                                            }
                                            
                                        }
                                    }
                                } else if status == .cantFound {
                                    req.logger.warning("Room doesnot exist", metadata: ["pin": .string(pin)])
                                }
                                try await ws.send(status.rawValue)
                                if status != .joined {
                                    req.logger.warning("Cannot join room", metadata: ["pin": .string(pin), "reason": "Room is full or not found."])
                                    try await Task.sleep(for: .seconds(1))
                                    try await ws.close()
                                }
                            } else if createOrJoin == "create" {
                                let status = await roomManager.createRoom(pin: pin, participant: participant)
                                if status == .created {
                                    if let username = await roomManager.getUsername(ws: ws) {
                                        req.logger.info("Created Room", metadata: ["pin": .string(pin), "byWho": .string(username)])
                                    } else {
                                        req.logger.info("Created Room", metadata: ["pin": .string(pin), "byWho": "UNKNOWN"])
                                    }
                                    if let roomMemberCount = await roomManager.getParticipantCount(pin: pin) {
                                        let memberCountString = await JSONManager.shared.prepareRoomCount(count: roomMemberCount)
                                        await roomManager.broadcastToRoom(pin: pin, message: memberCountString)
                                    }
                                } else if status == .alreadyExist {
                                    req.logger.warning("Cannot Create Room", metadata: ["pin": .string(pin), "reason": "The session code user is trying to create already exists"])
                                }
                                try await ws.send(status.rawValue)
                            }
                        }
                    } else {
                        req.logger.error("Unknown Content", metadata: ["context": "ParticipantData"])
                    }
                case .chatMessage:
                    Task {
                        await roomManager.broadcastToRoom(pin: pin, message: text)
                    }
                case .keyData:
                    if let clientKeyData = await JSONManager.shared.decodeKeyData(text: text) {
                        Task {
                            if let keyDataCount = await roomManager.addKeyDataToRoom(pin: pin, clientKeyData: clientKeyData) {
                                if keyDataCount == 2 {
                                    // race condition olabilir ?
                                    if let room = await roomManager.rooms[pin] {
                                        if let firstKeyData = room.clientKeyData.first(where: { $0.deviceId == room.partipicants[0].deviceId }),
                                           let secKeyData = room.clientKeyData.first(where: { $0.deviceId == room.partipicants[1].deviceId }) {
                                            
                                            let textToSec = await JSONManager.shared.prepareKeyData(clientKeyData: firstKeyData)
                                            let textToFirst = await JSONManager.shared.prepareKeyData(clientKeyData: secKeyData)
                                            
                                            try await room.partipicants[0].ws.send(textToFirst)
                                            try await room.partipicants[1].ws.send(textToSec)
                                        }
                                    }
                                } else {
                                    //print("key data count in the room not 2")
                                }
                            }
                        }
                    } else {
                        req.logger.error("Unknown Content", metadata: ["context": "ClientKeyData"])
                    }
                case .none:
                    req.logger.warning("Unknown Content")
                }
            }
        }
        ws.onClose.whenSuccess { result in
            Task {
                await roomManager.removeUserFromRoom(pin: pin, ws: ws)
                await roomManager.removeKeyDataFromRoom(pin: pin, ws: ws)
                
                if let username = await roomManager.getUsername(ws: ws) {
                    req.logger.info("User disconnected.", metadata: ["pin": .string(pin), "username": .string(username)])
                } else {
                    req.logger.info("User disconnected.", metadata: ["pin": .string(pin), "username": "UNKNOWN"])                }
                if let roomMemberCount = await roomManager.getParticipantCount(pin: pin) {
                    await roomManager.broadcastToRoom(pin: pin, message: String(roomMemberCount))
                }
                await roomManager.checkRoomAndClose(pin: pin)
                req.logger.info("Room Closed", metadata: ["pin": .string(pin)])
            }
            
        }
    }
}
