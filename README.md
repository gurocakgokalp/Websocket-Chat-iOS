# End-to-End Encrypted WebSocket Chat (PoC)

A lightweight, strictly educational Proof of Concept (PoC) demonstrating a real-time, end-to-end encrypted (E2EE) messaging architecture using **iOS (SwiftUI/CryptoKit)** for the client and **Vapor** for the backend. 

This project explores how to build a "stateless, blind router" server paired with a client-side cryptographic engine, ensuring that the server never has access to the message contents or the decryption keys.

## 🚀 Key Features

* **Real-time Communication:** Native `URLSessionWebSocketTask` for seamless, full-duplex messaging without third-party dependencies.
* **Stateless Backend (Vapor):** The server acts purely as a WebSocket router. It holds connections in RAM via Swift Actors, performs zero logging, and has no database. When the session ends, the room evaporates.
* **Session PIN Access:** Easy and intuitive room joining mechanism using generated PINs.
* **Modern UI:** Built entirely with SwiftUI, featuring a clean, dark-themed, and responsive interface.

## 🔐 Cryptography & Architecture

This project utilizes Apple's native `CryptoKit` to implement a robust, multi-layered security flow:

1. **Key Generation:** Each device generates its own `P256.Signing.PrivateKey` and `Curve25519.KeyAgreement.PrivateKey` locally.
2. **Key Exchange (Handshake):** Upon joining a room, clients exchange their public keys via the Vapor server. 
3. **Symmetric Key Derivation:** Using the Diffie-Hellman key exchange method, both devices compute a shared secret. This secret is then passed through an **HKDF** (HMAC-based Extract-and-Expand Key Derivation Function) with SHA256 to generate a cryptographically strong, 32-byte `SymmetricKey`.
4. **Encryption (AES-GCM):** All outgoing messages are sealed using `AES-GCM` before leaving the device. The payload sent to the server is purely ciphertext.
5. **Signature & Verification (ECDSA):** To prevent tampering, the combined digest of the encrypted message is signed using the sender's P256 private key. The receiver verifies this `ECDSASignature` before attempting to decrypt the payload.

## 📸 Screenshots

| Room Creation & QR | Chat Interface |
|:---:|:---:|
| <img src="https://github.com/user-attachments/assets/d3eb9f93-d006-423c-aa9c-2a770294da41" width="200"> | <img src="https://github.com/user-attachments/assets/f84b23c1-079f-40f2-8c25-64f83df927b1" width="200"> <img src="https://github.com/user-attachments/assets/55fe24df-253f-4299-bd12-b02fcea32f46" width="200">|

## 🛠 Tech Stack

* **Frontend:** Swift, SwiftUI, Combine
* **Security:** CryptoKit, LocalAuthentication
* **Backend:** Server-Side Swift (Vapor), WebSockets

## ⚠️ Disclaimer

**This project is a Proof of Concept (PoC) created strictly for educational and portfolio purposes to demonstrate WebSocket and CryptoKit implementations. It has not been audited by security professionals and should NOT be used for actual sensitive, private, or production-level communications. The author assumes no responsibility for any misuse of this software.**

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
