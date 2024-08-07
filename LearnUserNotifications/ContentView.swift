//
//  ContentView.swift
//  LearnUserNotifications
//
//  Created by hs on 8/6/24.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var notificationManager: NotificationManager
    @State private var secs: Int = 5
    
    var body: some View {
        if notificationManager.isAuthorized {
            VStack {
                setNotificationTimeView
                
                List(notificationManager.pendingRequests, id: \.self) { request in
                    Text(request.identifier)
                        .swipeActions {
                            Button("Delete", role: .destructive) {
                                notificationManager.removeRequest(withIdentifier: request.identifier)
                            }
                        }
                }
            }
            .overlay(alignment: .topTrailing) {
                moreOptionsView
                    .padding()
            }
        } else {
            Button("NEED AUTHORIZATION") {
                openSettings()
            }
        }
    }
}

extension ContentView {
    var setNotificationTimeView: some View {
        GroupBox {
            HStack {
                Button(action: {
                    secs -= 1
                }, label: {
                    Image(systemName: "minus.circle")
                        .foregroundColor(.red)
                })
                .disabled(secs <= 1)
                
                Button(action: {
                    Task {
                        await notificationManager.schedule(timeInterval: Double(secs))
                    }
                }, label: {
                    Text("\(secs)초 후 알림")
                        .monospaced()
                })
                
                Button(action: {
                    secs += 1
                }, label: {
                    Image(systemName: "plus.circle")
                        .foregroundColor(.green)
                })
            }
        }
    }
    
    var moreOptionsView: some View {
        Menu {
            Button(action: {
                secs = 5
            }) {
                Label("알림 시간 초기화", systemImage: "arrow.counterclockwise")
            }
            Button(action: {
                notificationManager.clearRequests()
            }) {
                Label("알림 전체 삭제", systemImage: "trash")
            }
        } label: {
            Image(systemName: "ellipsis.circle")
                .foregroundColor(.secondary)
        }
    }
}

extension ContentView {
    private func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            if UIApplication.shared.canOpenURL(url) {
                Task {
                    await UIApplication.shared.open(url)
                }
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(NotificationManager())
}
