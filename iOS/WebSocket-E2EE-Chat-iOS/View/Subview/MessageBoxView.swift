//
//  MessageBoxView.swift
//  WebSocket-E2EE-Chat-iOS
//
//  Created by Gökalp Gürocak on 28.02.2026.
//

import SwiftUI

struct MessageBoxView: View {
    @Environment(\.colorScheme) var colorScheme
    @State var message: Message
    @State var peerMessage: Bool
    
    @EnvironmentObject var vm: MainViewModel
    var body: some View {
        VStack(alignment: peerMessage ? .leading : .trailing) {
            HStack {
                if !peerMessage {
                    Spacer()
                }
                if peerMessage {
                    if let messageText = CryptoManager.shared.decryptMessageText(message: message) {
                        Text(messageText)
                            .fontDesign(.rounded)
                            .fontWeight(.semibold)
                            .foregroundStyle(colorScheme == .light && !peerMessage ? .white : .primary)
                            .padding()
                            .glassEffect(peerMessage ? .regular.interactive() : .regular.tint(.green).interactive())
                    }
                } else {
                    Text(message.plainText ?? "")
                        .fontDesign(.rounded)
                        .fontWeight(.semibold)
                        .foregroundStyle(colorScheme == .light && !peerMessage ? .white : .primary)
                        .padding()
                        .glassEffect(peerMessage ? .regular.interactive() : .regular.tint(.green).interactive())
                }
                if peerMessage {
                    Spacer()
                }
            }
            Text("\(Date(timeIntervalSince1970: TimeInterval(message.timestamp)).formatted(date: .omitted, time: .standard))")
                .foregroundStyle(.secondary)
                .font(.caption)
        }.padding(.horizontal)
    }
}

#Preview {
    ZStack {
        Color(.secondarySystemBackground).ignoresSafeArea()
        //MessageBoxView(message: Message(message: "Original Ghetto.", username: "User1", timestamp: Int(Date().timeIntervalSince1970)), peerMessage: true)
    }
}
