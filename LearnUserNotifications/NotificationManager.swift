//
//  NotificationManager.swift
//  LearnUserNotifications
//
//  Created by hs on 8/6/24.
//

import UserNotifications

@MainActor
class NotificationManager: NSObject, ObservableObject {
    private var notificationCenter = UNUserNotificationCenter.current()
    @Published var isAuthorized: Bool = false
    @Published var pendingRequests: [UNNotificationRequest] = []
    @Published var sheetView: SheetView? = nil
    
    override init() {
        super.init()
        self.notificationCenter.delegate = self
        setNotificationCategories()
    }
    
    func requestAuthorization() async {
        guard !isAuthorized else { return }
        do {
            try await notificationCenter.requestAuthorization(options: [.sound, .badge, .alert])
        } catch {
            print(error)
        }
    }
    
    func getAuthorizationStatus() async {
        let currentSettings = await notificationCenter.notificationSettings()
        isAuthorized = (currentSettings.authorizationStatus == .authorized)
    }
}

extension NotificationManager {
    func fetchPendingRequests() async {
        pendingRequests = await notificationCenter.pendingNotificationRequests()
    }
    
    func removeRequest(withIdentifier identifier: String) {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [identifier])
        if let index = pendingRequests.firstIndex(where: {$0.identifier == identifier}) {
            pendingRequests.remove(at: index)
        }
    }
    
    func clearRequests() {
        notificationCenter.removeAllPendingNotificationRequests()
        pendingRequests.removeAll()
    }
    
    func schedule(timeInterval: Double) async {
        let content = UNMutableNotificationContent()
        content.title = "Hello"
        content.body = "This is a test notification"
        content.sound = .default
        
        /// 멀티미디어 파일
        if let url = Bundle.main.url(forResource: "screenshot", withExtension: "png") {
            if let attachment = try? UNNotificationAttachment(identifier: "screenshot", url: url) {
                content.attachments = [attachment]
            }
        }
        
        /// 설정한 카테고리 ID 지정
        content.categoryIdentifier = "ALARM_CATEGORY"
        
        /// 알림에 데이터 추가
        content.userInfo = ["sheetView" : SheetView.type1.rawValue]
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        try? await notificationCenter.add(request)
        await fetchPendingRequests()
    }
}

extension NotificationManager: UNUserNotificationCenterDelegate {
    // userNotificationCenter(_:didReceive:) 메서드에서 사용되는 NotificationCategory 설정하는 메서드
    private func setNotificationCategories() {
        let snoozeAction = UNNotificationAction(identifier: "SNOOZE_ACTION",
                                                title: "Snooze",
                                                options: [])
        
        let deleteAction = UNNotificationAction(identifier: "DELETE_ACTION",
                                                title: "Delete",
                                                options: [.destructive])

        /// 알림 카테고리 설정(알림 액선들로 이루어짐)
        let category = UNNotificationCategory(identifier: "ALARM_CATEGORY",
                                              actions: [snoozeAction, deleteAction],
                                              intentIdentifiers: [],
                                              options: [])
        
        notificationCenter.setNotificationCategories([category])
    }
    
    // foreground일 때, 알림이 발생하면 앱에서 수행되는 동작되는 메서드
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
        await fetchPendingRequests()
        return [.sound, .banner]
    }
    
    // 알림 창을 누르면 이를 바탕으로 앱에서 수행되는 동작
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async {
        /// 알림에 포함된 데이터를 userInfo를 통해  처리
        let userInfo = response.notification.request.content.userInfo
        if let sheetViewData = userInfo["sheetView"] as? String {
            sheetView = SheetView(rawValue: sheetViewData)
        }

        /// response.actionIdentifier를 사용하여 카테고리의 어떤 액션이 선택되었는지 확인할 수 있다
        switch response.actionIdentifier {
        case UNNotificationDefaultActionIdentifier:
            print("Default action triggered")

        case "SNOOZE_ACTION":
            print("Snooze action triggered")

        case "DELETE_ACTION":
            print("Delete action triggered")

        default:
            break
        }

        await fetchPendingRequests()
    }
}
