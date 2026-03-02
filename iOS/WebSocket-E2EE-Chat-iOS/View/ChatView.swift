//
//  ChatView.swift
//  WebSocket-E2EE-Chat-iOS
//
//  Created by Gökalp Gürocak on 28.02.2026.
//

import SwiftUI

struct ChatView: View {
    @State var chat: String = ""
    @EnvironmentObject var vm: MainViewModel

    var body: some View {
        NavigationStack {
            ScrollViewReader { proxy in
                ScrollView {
                    VStack {
                        HStack {
                            Image(systemName: "lock.shield.fill")
                                .foregroundStyle(.secondary)
                            Text("All messages are end-to-end encrypted.")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .fontDesign(.monospaced)
                        }.padding()
                            .glassEffect(.regular)
                            .padding(.bottom, 20)
                        ForEach(vm.messages) { message in
                            MessageBoxView(message: message, peerMessage: vm.peerUsername == message.username)
                                .id(message.id)
                        }
                        /*
                        HStack {
                            Text("User1 typing")
                                .foregroundStyle(.tertiary)
                                .bold()
                                .fontDesign(.monospaced)
                            Image(systemName: "ellipsis")
                                .foregroundStyle(.tertiary)
                                .font(.title)
                                .symbolEffect(.variableColor)
                        }.padding(.horizontal)
                            .padding(.vertical, 4)
                        .glassEffect()
                            */
                    }.animation(.spring, value: vm.messages.count)
                }.onChange(of: vm.messages.count) { oldValue, newValue in
                    withAnimation {
                        proxy.scrollTo(vm.messages.last?.id, anchor: .bottom)
                    }
                }
            }.toolbar {
                ToolbarItem(placement: .bottomBar) {
                    HStack {
                        TextField("Enter text here", text: $chat).padding(.leading)
                            .keyboardShortcut(.defaultAction)
                            .onSubmit {
                                sendMessage()
                            }
                        Button {
                            sendMessage()
                        } label: {
                            Image(systemName: "paperplane.fill")
                                .foregroundStyle(.green.gradient)
                        }.padding(.trailing)
                    }
                    
                }
            }
        }
    }
    func sendMessage() {
        guard chat != "" else {
            return
        }
        guard let encryptedText = CryptoManager.shared.encryptMessageText(text: chat) else {
            return
        }
        guard let deviceId = IDManager.shared.getDeviceId() else {
            return
        }
        // backende yolladim
        vm.sendMessage(message: Message(type: "chatMessage", ciphertext: encryptedText.ciphertext, signature: encryptedText.signature, nonce: encryptedText.nonce, tag: encryptedText.tag, username: vm.username, deviceId: deviceId, timestamp: Int(Date().timeIntervalSince1970)))
        // bana yolladim, zaten backendden gelen mesaj benimse ignore edicem
        vm.messages.append(Message(type: "chatMessage", ciphertext: encryptedText.ciphertext, signature: encryptedText.signature, nonce: encryptedText.nonce, tag: encryptedText.tag, username: vm.username, deviceId: deviceId, timestamp: Int(Date().timeIntervalSince1970), plainText: chat))
        chat = ""
    }
}

#Preview {
    ZStack {
        Color(.secondarySystemBackground).ignoresSafeArea()
        ChatView()
            .tint(.green)
            .environmentObject(MainViewModel())
    }
}
