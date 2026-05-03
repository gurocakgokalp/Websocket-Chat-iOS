//
//  RoomView.swift
//  WebSocket-E2EE-Chat-iOS
//
//  Created by Gökalp Gürocak on 27.02.2026.
//

import SwiftUI

struct RoomView: View {
    @Environment(\.dismiss) var dismiss
        
    var pin: String
    @EnvironmentObject var vm: MainViewModel
    @Environment(\.scenePhase) var scenePhase

    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.secondarySystemBackground).ignoresSafeArea()
                VStack {
                    VStack(spacing: 8) {
                        
                        switch vm.roomStatus {
                        case .joined:
                            if vm.roomMemberCount == 2 {
                                ChatView()
                                    .environmentObject(vm)
                            }
                        case .created:
                            if vm.roomMemberCount == 1 {
                                VStack {
                                    Image(systemName: "person.crop.circle.badge.clock")
                                        .foregroundStyle(.green.gradient)
                                        .symbolEffect(.pulse)
                                        .font(.system(size: 60))
                                    Text("Waiting for User")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                }
                            } else {
                                ChatView()
                                    .environmentObject(vm)
                            }
                        case .full:
                            VStack(spacing: 8) {
                                Image(systemName: "xmark.circle")
                                    .foregroundStyle(.red.gradient)
                                    .symbolEffect(.pulse)
                                    .font(.system(size: 60))
                                Text("Failed.")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                Text("The room is full.")
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 20)
                            }
                        case .cantFound:
                            VStack(spacing: 8) {
                                Image(systemName: "xmark.circle")
                                    .foregroundStyle(.red.gradient)
                                    .symbolEffect(.pulse)
                                    .font(.system(size: 60))
                                Text("Failed.")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                Text("Room not found.")
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 20)
                            }
                        case .alreadyExist:
                            VStack(spacing: 8) {
                                Image(systemName: "xmark.circle")
                                    .foregroundStyle(.red.gradient)
                                    .symbolEffect(.pulse)
                                    .font(.system(size: 60))
                                Text("Failed.")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                Text("The already exist.")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 20)
                            }
                        case .none:
                            ProgressView()
                            
                        }
                        
                    }
                }.overlay {
                    if let alert = vm.alertWrapper {
                        ContentUnavailableView {
                            Label("Connection Failed", systemImage: "person.2.slash")
                        } description: {
                            Text(alert.message)
                        } actions: {
                            Button("Leave") {
                                vm.disconnect()
                                vm.alertWrapper = nil
                            }
                            .buttonStyle(.glassProminent)
                        }
                        .background(Color(.secondarySystemBackground).ignoresSafeArea())
                    }
                }.onChange(of: scenePhase) { oldPhase , newPhase in
                    if newPhase == .background {
                        vm.disconnect()
                    }
                }
                .toolbar {
                    if vm.roomStatus == .joined || vm.roomStatus == .created {
                        ToolbarItem(placement: .topBarLeading) {
                            Button {
                                vm.disconnect()
                                dismiss()
                            } label: {
                                Image(systemName: "door.right.hand.open")
                            }
                            
                        }
                        ToolbarItem(placement: .title) {
                            HStack {
                                if vm.roomMemberCount == 2 {
                                    HStack {
                                        Image(systemName: "person.fill")
                                            .foregroundStyle(.green.gradient)
                                            .font(.caption)
                                        Text(vm.peerUsername)
                                            .bold()
                                            .fontDesign(.monospaced)
                                    }
                                    Divider()
                                }
                                HStack(spacing: 3) {
                                    Image(systemName: "number")
                                        .foregroundStyle(.green.gradient)
                                        .font(vm.roomMemberCount == 2 ? .caption2 : .caption)
                                    Text(pin)
                                        .bold()
                                        .fontDesign(.monospaced)
                                        .font(vm.roomMemberCount == 2 ? .caption2 : .default)
                                }
                            }.padding(.horizontal)
                                .padding(.vertical, 10)
                                .glassEffect(.regular)
                                .animation(.spring, value: vm.roomMemberCount)
                            
                        }
                        ToolbarItem(placement: .topBarTrailing) {
                            HStack {
                                Image(systemName: "wifi.badge.lock")
                                    .foregroundStyle(.green.gradient)
                                    //.font(.caption)
                                //Text("\(vm.roomMemberCount)")
                            }//.padding(.horizontal, 7)
                        }
                    } else {
                        ToolbarItem(placement: .topBarLeading) {
                            Button {
                                dismiss()
                            } label: {
                                Image(systemName: "xmark")
                            }
                            
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    RoomView(pin: "7FGU5F")
        .environmentObject(MainViewModel())
}
