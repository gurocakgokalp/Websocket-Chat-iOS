//
//  PINManager.swift
//  WebSocket-E2EE-Chat-iOS
//
//  Created by Gökalp Gürocak on 23.02.2026.
//

import Foundation

final class PINManager {
    static let shared = PINManager()
    
    private init() {}
    
    let numbersAndLetters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    
    func createRandomPIN() -> String {
        var pin: String = ""
        for _ in 1...6 {
            let randomString = numbersAndLetters.randomElement()
            pin.append(randomString!)
        }
        return pin
    }
}

