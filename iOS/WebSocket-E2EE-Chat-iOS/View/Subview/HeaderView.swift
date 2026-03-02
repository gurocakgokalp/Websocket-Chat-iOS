//
//  HeaderView.swift
//  WebSocket-E2EE-Chat-iOS
//
//  Created by Gökalp Gürocak on 22.02.2026.
//

import SwiftUI

struct HeaderView: View {
    let title: String
    let imageName: String
    var body: some View {
        HStack {
            Image(systemName: imageName)
                .font(.caption)
                .fontWeight(.bold)
                .foregroundStyle(.green.gradient)
            Text(title)
                .font(.caption)
                .fontWeight(.bold)
                .textCase(.uppercase)
                .tracking(1.5)
                .fontDesign(.rounded)
                .foregroundStyle(.green.gradient)
        }
    }
}

#Preview {
    //HeaderView()
}
