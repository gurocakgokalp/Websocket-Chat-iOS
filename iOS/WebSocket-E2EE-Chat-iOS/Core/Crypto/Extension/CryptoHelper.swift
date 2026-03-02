//
//  CryptoHelper.swift
//  WebSocket-E2EE-Chat-iOS
//
//  Created by Gökalp Gürocak on 1.03.2026.
//
import Foundation
import CryptoKit

extension CryptoManager {
    func B64toAgreementPKey(agreementPB64: String) throws -> Curve25519.KeyAgreement.PublicKey {
        guard let keyRawData = Data(base64Encoded: agreementPB64) else {
            throw CryptoError.b64decoding
        }
        return try Curve25519.KeyAgreement.PublicKey(rawRepresentation: keyRawData)
    }
}

