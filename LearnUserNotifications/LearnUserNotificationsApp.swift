//
//  LearnUserNotificationsApp.swift
//  LearnUserNotifications
//
//  Created by hs on 8/6/24.
//

import SwiftUI

@main
struct LearnUserNotificationsApp: App {
    @Environment(\.scenePhase) var scenePhase
    @StateObject var notificationManager: NotificationManager = .init()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .task {
                    await notificationManager.requestAuthorization()
                }
                .onChange(of: scenePhase, { _, newValue in
                    if newValue == .active {
                        Task {
                            await notificationManager.getAuthorizationStatus()
                        }
                    }
                })
                .environmentObject(notificationManager)
        }
    }
}
