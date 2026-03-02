//
//  KeyManager.swift
//  WebSocket-E2EE-Chat-iOS
//
//  Created by Gökalp Gürocak on 1.03.2026.
//
import CryptoKit
import LocalAuthentication
import SwiftUI

class KeyManager {
    static let shared = KeyManager()
    
    private var signingPrivateKey: SecureEnclave.P256.Signing.PrivateKey?
    private var peerSigningPubKey: P256.Signing.PublicKey?
    private var agreementPrivateKey: Curve25519.KeyAgreement.PrivateKey?
    private var hkdfSharedSymmetricKey: SymmetricKey?
        
    let keySignTag = "com.gokalpgurocak.websocketChat.signing"
    let keyAgreementTag = "com.gokalpgurocak.websocketChat.agreement"

    private init() {}
    
    func getSignPrivateKey() throws -> SecureEnclave.P256.Signing.PrivateKey {
        if let signingPrivateKey = signingPrivateKey {
            return signingPrivateKey
        }
        
        if let savedData = loadKeyDataFromKeychain(keyTag: keySignTag) {
            do {
                let restoredKey = try SecureEnclave.P256.Signing.PrivateKey(dataRepresentation: savedData)
                self.signingPrivateKey = restoredKey
                print("sign key restored.")
                return restoredKey
            } catch {
                print("key cannot restore.")
            }
        }

        print("new signiing private key creating...")
        return try createAndSaveNewSignKey()
    }
    
    func createAndSaveNewSignKey() throws -> SecureEnclave.P256.Signing.PrivateKey {
        var error: Unmanaged<CFError>?
        let context = LAContext()
        
        guard let access = SecAccessControlCreateWithFlags(
            nil,
            kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
            [.privateKeyUsage],
            &error
        ) else {
            throw KeyError.accessControlError
        }
        let createdKey = try SecureEnclave.P256.Signing.PrivateKey(compactRepresentable: false, accessControl: access, authenticationContext: context)
        
        saveKeyDataKeychain(data: createdKey.dataRepresentation, keyTag: keySignTag)
        
        self.signingPrivateKey = createdKey
        return createdKey
    }
    
    func getAgreementPrivateKey() throws -> Curve25519.KeyAgreement.PrivateKey {
        if let agreementKey = agreementPrivateKey {
            return agreementKey
        }
        
        if let savedData = loadKeyDataFromKeychain(keyTag: keyAgreementTag) {
            do {
                let restoredKey = try Curve25519.KeyAgreement.PrivateKey(rawRepresentation: savedData)
                print("agreement key restored")
                self.agreementPrivateKey = restoredKey
                return restoredKey
            } catch {
                print("cannot restore agreement key")
            }
        }
        print("new agreement key creating...")
        return try createAndSaveNewAgreementKey()
    }
    
    func createAndSaveNewAgreementKey() throws -> Curve25519.KeyAgreement.PrivateKey {
        let createdKey = Curve25519.KeyAgreement.PrivateKey()
        
        saveKeyDataKeychain(data: createdKey.rawRepresentation, keyTag: keyAgreementTag)
        self.agreementPrivateKey = createdKey
        print("agreement key created.")
        return createdKey
    }
    
    func setHkdfSharedSymmetricKey(key: SymmetricKey) {
        self.hkdfSharedSymmetricKey = key
        print("hkdfSharedSymmetricKey successfully saved\n[ready] sockets and server ready for messaging")
    }
    
    func getHkdfSharedSymmetricKey() -> SymmetricKey? {
        if let hkdfSharedSymmetricKey = hkdfSharedSymmetricKey {
            return hkdfSharedSymmetricKey
        } else {
            print("[getHkdfSharedSymmetricKey] hkdfSharedSymmetricKey not found")
            return nil
        }
    }
    
    func setPeerSigningPubKey(peerKeyData: clientKeyData) {
        guard let keyData = Data(base64Encoded: peerKeyData.signPKey) else {
            print("[setPeerSigningPubKey] error (b64decoding)")
            return
        }
        do {
            let key = try P256.Signing.PublicKey(rawRepresentation: keyData)
            self.peerSigningPubKey = key
        } catch {
            print("[setPeerSigningPubKey] error: \(error.localizedDescription)")
            return
        }
        
    }
    
    func getPeerSigningPubKey() -> P256.Signing.PublicKey? {
        if let key = self.peerSigningPubKey {
            return key
        } else {
            return nil
        }
    }
    
}
