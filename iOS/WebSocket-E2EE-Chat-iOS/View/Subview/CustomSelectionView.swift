//
//  CustomSelectionView.swift
//  WebSocket-E2EE-Chat-iOS
//
//  Created by Gökalp Gürocak on 22.02.2026.
//

import SwiftUI

struct CustomSelectionView: View {
    @Binding var roomChoiceE: roomChoice
    var body: some View {
        HStack {
            ForEach(roomChoice.allCases) { type in
                Button(action: {
                    withAnimation(.spring()) {
                        roomChoiceE = type
                    }
                }) {
                    Text(type.rawValue)
                        .foregroundColor(roomChoiceE == type ? .white : .primary)
                        .frame(maxWidth: .infinity)
                    .font(.caption.bold())
                    .padding(.vertical, 8)
                    .padding(.horizontal)
                    .background(roomChoiceE == type ? Color.green : Color(.systemGray6))
                    .clipShape(Capsule())
                    .overlay(
                        Capsule()
                            .stroke(Color.green.opacity(0.6).gradient, lineWidth: 2)
                    )
                    .padding(.vertical, 3)
                    
                }
            }
        }
    }
}

#Preview {
    //CustomSelectionView(roomChoiceE: .create)
}
