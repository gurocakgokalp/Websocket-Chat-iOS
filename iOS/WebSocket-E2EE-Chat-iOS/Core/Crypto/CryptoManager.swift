//
//  CryptoManager.swift
//  WebSocket-E2EE-Chat-iOS
//
//  Created by Gökalp Gürocak on 1.03.2026.
//
import Foundation
import CryptoKit

class CryptoManager {
    static let shared = CryptoManager()
    
    private var salt: Data?
    
    private init() {}
    
    func setSalt(saltS: String) {
        let saltData = Data(saltS.utf8)
        self.salt = saltData
        print("salt setted succesfully")
    }
    
    func getSalt() -> Data? {
        if let salt = salt {
            return salt
        } else {
            print("[getSalt] salt not found.")
            return nil
        }
    }
    
    func getClientKeyData() -> ClientKeyData? {
        do {
            guard let deviceId = IDManager.shared.getDeviceId() else {
                print("[prepareHandshake] error: deviceId not found")
                return nil
            }
            let agreementPublic = try KeyManager.shared.getAgreementPrivateKey().publicKey
            let signPublic = try KeyManager.shared.getSignPrivateKey().publicKey
            return ClientKeyData(type: "keyData", agreementPKey: agreementPublic.rawRepresentation.base64EncodedString(), signPKey: signPublic.rawRepresentation.base64EncodedString(), deviceId: deviceId)
        } catch {
            print("[prepareHandshake] error: \(error.localizedDescription)")
            return nil
        }
    }
    
    func sign(digest: Data) throws -> P256.Signing.ECDSASignature {
        let signPrivateKey = try KeyManager.shared.getSignPrivateKey()
        return try signPrivateKey.signature(for: digest)
    }
    
    func handshake(peerKeyData: ClientKeyData) {
        do {
            let agreementPriKey = try KeyManager.shared.getAgreementPrivateKey()
            let peerAgreementPubKey = try B64toAgreementPKey(agreementPB64: peerKeyData.agreementPKey)
            
            let sharedSecret = try agreementPriKey.sharedSecretFromKeyAgreement(with: peerAgreementPubKey)
            if let salt = self.getSalt() {
                let secretKey = sharedSecret.hkdfDerivedSymmetricKey(using: SHA256.self, salt: salt, sharedInfo: Data("websocket-e2ee".utf8), outputByteCount: 32)
                print("handshake succesfully completed\nsaving hkdfSharedSymmetricKey")
                KeyManager.shared.setHkdfSharedSymmetricKey(key: secretKey)
                KeyManager.shared.setPeerSigningPubKey(peerKeyData: peerKeyData)
            }
        } catch {
            print("handshake error: \(error.localizedDescription)")
            return
        }
    }
    
    // error throwing yapcam daha
    func encryptMessageText(text: String) -> EncryptedMessageText? {
        print("starting encrypt message")
        let textData = Data(text.utf8)
        
        guard let sharedKey = KeyManager.shared.getHkdfSharedSymmetricKey() else {
           return nil
        }
        
        do {
            let sealedBox = try AES.GCM.seal(textData, using: sharedKey)
            guard let digest = sealedBox.combined else {
                return nil
            }
            let signature = try sign(digest: digest)
            
            return EncryptedMessageText(ciphertext: sealedBox.ciphertext.base64EncodedString(), signature: signature.rawRepresentation.base64EncodedString(), nonce: sealedBox.nonce.withUnsafeBytes {Data($0)}.base64EncodedString(), tag: sealedBox.tag.base64EncodedString())
        } catch {
            print("[encryptMessageText] error: \(error.localizedDescription)")
            return nil
        }
    }
    
    func decryptMessageText(message: Message) -> String? {
        guard let sharedKey = KeyManager.shared.getHkdfSharedSymmetricKey() else {
           return nil
        }
        do {
            let sealedBox = try createSealedBox(nonce: message.nonce, tag: message.tag, ciphertext: message.ciphertext)
            if try verify(sealedBox: sealedBox, signatureS: message.signature) {
                let decryptedData = try AES.GCM.open(sealedBox, using: sharedKey)
                return String(data: decryptedData, encoding: .utf8)
            } else {
                print("could not verify so can't start decrypt")
                return nil
            }
        } catch {
            return nil
        }
    }
    
    func verify(sealedBox: AES.GCM.SealedBox, signatureS: String) throws -> Bool{
        guard let signatureD = Data(base64Encoded: signatureS) else {
            throw CryptoError.b64decoding
        }
        let signature = try P256.Signing.ECDSASignature(rawRepresentation: signatureD)
        if let peerSigningPubKey = KeyManager.shared.getPeerSigningPubKey() {
            
            guard let digest = sealedBox.combined else {
                return false
            }
            
            return peerSigningPubKey.isValidSignature(signature, for: digest)
        } else {
            print("peerSigningPubKey not found.")
            return false
        }
    }
    
    func createSealedBox(nonce: String, tag: String, ciphertext: String) throws -> AES.GCM.SealedBox {
        guard let ciphertext = Data(base64Encoded: ciphertext) else {
            throw CryptoError.b64decoding
        }
        guard let nonceD = Data(base64Encoded: nonce) else {
            throw CryptoError.b64decoding
        }
        let nonce = try AES.GCM.Nonce(data: nonceD)
        guard let tag = Data(base64Encoded: tag) else {
            throw CryptoError.b64decoding
        }
        do {
            return try AES.GCM.SealedBox(nonce: nonce, ciphertext: ciphertext, tag: tag)
        } catch let err {
            throw CryptoError.sealedBoxCreating(err.localizedDescription)
        }
    }
}

