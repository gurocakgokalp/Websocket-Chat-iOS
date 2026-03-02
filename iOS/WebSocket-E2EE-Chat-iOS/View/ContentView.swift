//
//  ContentView.swift
//  WebSocket-E2EE-Chat-iOS
//
//  Created by Gökalp Gürocak on 22.02.2026.
//

import SwiftUI

struct ContentView: View {
    @State var roomChoiceE: roomChoice = .join
    
    @Namespace private var animation
    
    @State var sessionPIN: String = ""
    @State var generatedPin: String = ""
    @State var username: String = ""
    
    @StateObject var vm = MainViewModel()
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.secondarySystemBackground).ignoresSafeArea()
                VStack(spacing: 30) {
                    VStack(spacing: 8) {
                        Image(systemName: "ellipsis.message.fill")
                            .foregroundStyle(.green.gradient)
                            .font(.system(size: 60))
                        Text("End-to-End Encrypted Chat")
                            .font(.title2)
                            .fontWeight(.bold)
                        Text("Chat app using Server-Side-Swift, SwiftUI, WebSocket, CryptoKit")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                    }
                    CustomSelectionView(roomChoiceE: $roomChoiceE)
                        .padding(.vertical)
                        .padding(.horizontal, 20)
                        .background{
                            RoundedRectangle(cornerRadius: 30)
                                .fill(Color(.systemBackground))
                                .shadow(radius: 30).opacity(0.4)
                        }.padding(.horizontal)
                    
                    VStack(alignment: .leading){
                        HeaderView(title: "USERNAME", imageName: "person.fill")
                        TextField("Enter your name", text: $username, axis: .vertical)
                            .contentTransition(.numericText())
                            .padding()
                            .fontDesign(.monospaced)
                            .background(Color(.systemGray6).opacity(1))
                            .cornerRadius(16)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.black.opacity(0.05), lineWidth: 1)
                            )
                        if roomChoiceE == .join {
                            HeaderView(title: "ROOM CODE", imageName: "number")
                                .padding(.top)
                            TextField("6 digit code", text: $sessionPIN, axis: .vertical)
                                .keyboardType(.asciiCapable)
                                .textInputAutocapitalization(.characters)
                                .onChange(of: sessionPIN) { _ , newValue in
                                    let allowed = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
                                    
                                    sessionPIN = String(
                                        newValue
                                            .uppercased()
                                            .filter { allowed.contains($0) }
                                            .prefix(6)
                                    )
                                }
                                .padding()
                                .fontDesign(.monospaced)
                                .background(Color(.systemGray6).opacity(1))
                                .cornerRadius(16)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color.black.opacity(0.05), lineWidth: 1)
                                )
                        }
                    }.padding()
                        .background{
                            RoundedRectangle(cornerRadius: 30)
                                .fill(Color(.systemBackground))
                                .shadow(radius: 30).opacity(0.4)
                        }.padding(.horizontal)

                    Button(action: {
                        switch roomChoiceE {
                        case .create:
                            self.generatedPin = PINManager.shared.createRandomPIN()
                            vm.connect(username: username, pin: generatedPin, createOrJoin: roomChoiceE)
                        case .join:
                            vm.connect(username: username, pin: sessionPIN, createOrJoin: roomChoiceE)
                        }
                        
                    }) {
                        HStack {
                            Image(systemName: "wifi")
                            Text("Connect to Chat")
                                .fontWeight(.bold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(.green.gradient)
                        .foregroundColor(.white)
                        .cornerRadius(16)
                        .shadow(radius: 10, x: 0, y: 5)
                    }
                    .padding()
                    
                    Text("id: \(IDManager.shared.getDeviceId() ?? "")")
                        .bold()
                        .fontDesign(.rounded)
                        .font(.caption2)
                        .textCase(.uppercase)
                        .foregroundStyle(.tertiary)
                        .multilineTextAlignment(.center)
                        .tracking(1.5)
                        .padding(.horizontal)
                }
            }.onAppear {
                IDManager.shared.setDeviceId()
            }.onDisappear {
                vm.disconnect()
            }.fullScreenCover(item: $vm.roomStatus) { roomStatus in
                switch roomChoiceE {
                case .create:
                    RoomView(pin: generatedPin)
                        .environmentObject(vm)
                        .navigationTransition(.zoom(sourceID: "1235", in: animation))
                        .interactiveDismissDisabled()
                case .join:
                    RoomView(pin: sessionPIN)
                        .environmentObject(vm)
                        .navigationTransition(.zoom(sourceID: "1235", in: animation))
                        .interactiveDismissDisabled()
                }
                
            }
        }
    }
}

#Preview {
    ContentView()
}
