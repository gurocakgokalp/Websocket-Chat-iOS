import Vapor

func routes(_ app: Application) throws {
    app.get { req async in
        "Server works!"
    }

    app.webSocket("room", ":pin", ":createOrJoin") { req, ws in
        let pin = req.parameters.get("pin")!
        let createOrJoin = req.parameters.get("createOrJoin")!
        
        ws.onText { ws, text in
            // şuan her seferinde addConection atıyorum. handle etmem lazım burayı.
            if let participant = await JSONManager.shared.decodeParticipantData(ws: ws, jsonText: text) {
                Task {
                    if createOrJoin == "join" {
                        let status = await roomManager.addConnectionToRoom(pin: pin, participant: participant)
                        print("tried add connection to room: \(status.rawValue)")
                        if status == .joined {
                            if let username = await roomManager.getUsername(ws: ws) {
                                print("\(username) joined to room (\(pin))")
                            } else {
                                print("unknown user joined to room (\(pin))")
                            }
                            if let roomMemberCount = await roomManager.getParticipantCount(pin: pin) {
                                print("\(pin) member count: \(roomMemberCount)")
                                await roomManager.broadcastToRoom(pin: pin, message: String(roomMemberCount))
                                    
                                if roomMemberCount == 2 {
                                    print("room is full now, pre-handshake completed.")
                                    // burada gonderecegiz.
                                    
                                    if let partipicants = await roomManager.rooms[pin]?.partipicants {
                                        let first = partipicants[0]
                                        let second = partipicants[1]
                                        
                                        if let salt = await roomManager.getSalt(pin: pin) {
                                            let messageToFirst = await JSONManager.shared.prepareReadyMessage(peerName: second.username, sharedSalt: salt)
                                            print("\"ready message\" sent to \(first.username) (\(first.deviceId))")
                                            let messageToSecond = await JSONManager.shared.prepareReadyMessage(peerName: first.username, sharedSalt: salt)
                                            print("\"ready message\" sent to \(second.username) (\(second.deviceId))")
                                            try await first.ws.send(messageToFirst)
                                            try await second.ws.send(messageToSecond)
                                        } else {
                                            print("failure: something went wrong when getting salt so couldn't send \"ready message\"")
                                        }
                                    }
                                    
                                }
                            }
                        } else if status == .cantFound {
                            print("room not found (\(pin))")
                        }
                        print("sending status.rawValue to socket")
                        try await ws.send(status.rawValue)
                        if status != .joined {
                            print("room (\(pin)) is full or not found, socket will be closed...")
                            try await Task.sleep(for: .seconds(1))
                            try await ws.close()
                        }
                    } else if createOrJoin == "create" {
                        let status = await roomManager.createRoom(pin: pin, participant: participant)
                        print("trying create room (\(pin)), status: \(status.rawValue)")
                        if status == .created {
                            if let username = await roomManager.getUsername(ws: ws) {
                                print("\(username) created room (\(pin))")
                            } else {
                                print("unknown user created room (\(pin))")
                            }
                            if let roomMemberCount = await roomManager.getParticipantCount(pin: pin) {
                                print("\(pin) member count: \(roomMemberCount)")
                                await roomManager.broadcastToRoom(pin: pin, message: String(roomMemberCount))
                            }
                        } else if status == .alreadyExist {
                            print("the session code user is trying to create already exists")
                        }
                        print("sending status.rawValue to socket")
                        try await ws.send(status.rawValue)
                    }
                }
            } else {
                //print("received text is not participantData")
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
                                        
                                        print("sending peer user key data to \(room.partipicants[0].username)")
                                        try await room.partipicants[0].ws.send(textToFirst)
                                        print("sending peer user key data to \(room.partipicants[1].username)")
                                        try await room.partipicants[1].ws.send(textToSec)
                                    }
                                }
                            } else {
                                //print("key data count in the room not 2")
                            }
                        }
                        //print("key data count return nil")
                    }
                } else {
                    Task {
                        await roomManager.broadcastToRoom(pin: pin, message: text)
                    }
                }
            }
            
        }
        ws.onClose.whenSuccess { result in
            Task {
                await roomManager.removeUserFromRoom(pin: pin, ws: ws)
                await roomManager.removeKeyDataFromRoom(pin: pin, ws: ws)
                
                if let username = await roomManager.getUsername(ws: ws) {
                    print("\(username) disconnected.")
                } else {
                    print("a unknown device disconnected.")
                }
                if let roomMemberCount = await roomManager.getParticipantCount(pin: pin) {
                    print("\(pin) member count: \(roomMemberCount)")
                    await roomManager.broadcastToRoom(pin: pin, message: String(roomMemberCount))
                }
                await roomManager.checkRoomAndClose(pin: pin)
            }
            
        }
    }
}
