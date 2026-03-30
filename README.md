# E2EE Chat iOS

Real-time end-to-end encrypted messaging over WebSocket. The Vapor backend 
acts as a blind router — it never has access to message contents or 
cryptographic keys.

> **Disclaimer:** Educational and portfolio use only. Not audited.
> Do not use in production.

## Why "blind router"?

Most messaging architectures trust the server. This project inverts that 
assumption: the server holds only ciphertext and connection state. 
Even if the server is compromised, message contents remain private.

## Screenshots

| Room Creation | Chat Interface |
|:---:|:---:|
| <img src="https://github.com/user-attachments/assets/d3eb9f93-d006-423c-aa9c-2a770294da41" width="200"> | <img src="https://github.com/user-attachments/assets/f84b23c1-079f-40f2-8c25-64f83df927b1" width="200"> <img src="https://github.com/user-attachments/assets/55fe24df-253f-4299-bd12-b02fcea32f46" width="200">|

## Cryptographic Architecture

| Primitive | Implementation |
|---|---|
| Key Generation | P256 signing + Curve25519 key agreement — generated locally per session |
| Key Exchange | Ephemeral ECDH via Diffie-Hellman |
| Key Derivation | HKDF (SHA-256), 32-byte symmetric key |
| Encryption | AES-GCM authenticated encryption |
| Signing | ECDSA (P256) — tamper detection before decryption |

## Security Decisions

**Why stateless backend?** Storing messages server-side creates a honeypot. 
A stateless router means there's nothing valuable to steal — when the 
session ends, the room evaporates.

**Why ECDH + HKDF instead of a static shared key?** Each session derives 
a fresh symmetric key. Compromising one session doesn't affect others.

**Why sign before decrypt?** ECDSA verification happens before AES-GCM 
decryption. A tampered or forged message is rejected immediately without 
touching the decryption layer.

## System Flow

1. **Room creation** — Host generates a PIN, server assigns a room.
2. **Key exchange** — Both clients exchange public keys via the server.
3. **Key derivation** — Each client independently derives the same 
symmetric key via HKDF. The server never sees this key.
4. **Messaging** — Messages are signed and encrypted client-side. 
Server routes ciphertext only.
5. **Decryption** — Receiver verifies signature, then decrypts locally.

## Running with Docker
```bash
cd Backend
docker compose up
```

Then open `iOS/` in Xcode and run on Simulator.

## Tech Stack

- **iOS:** Swift, SwiftUI, CryptoKit, URLSessionWebSocketTask
- **Backend:** Vapor (Server-side Swift), Swift Actors, Docker

## Known Limitations

- Background state management not fully implemented.
- No persistent storage by design — sessions are ephemeral.
- Not security audited.
