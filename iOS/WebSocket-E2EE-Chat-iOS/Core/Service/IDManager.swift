//
//  Untitled.swift
//  WebSocket-E2EE-Chat-iOS
//
//  Created by Gökalp Gürocak on 23.02.2026.
//
import SwiftUI

final class IDManager {
    static let shared = IDManager()
    
    private init() {}
    
    @AppStorage("deviceId") private var deviceId: String?
    
    func setDeviceId() {
        if deviceId != nil {
            return
        } else {
            self.deviceId = UUID().uuidString
        }
    }
    
    func getDeviceId() -> String? {
        if let deviceId = deviceId {
            return deviceId
        } else {
            return nil
        }
    }
}

