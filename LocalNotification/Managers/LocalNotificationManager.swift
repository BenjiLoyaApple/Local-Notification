//
//  LocalNotificationManager.swift
//  LocalNotification
//
//  Created by Benji Loya on 05.04.2024.
//

import SwiftUI
import NotificationCenter

@MainActor
class LocalNotificationManager: NSObject, ObservableObject {
   let notificationCenter = UNUserNotificationCenter.current()
    
    @Published var isGranted = false
    @Published var pendingRequests: [UNNotificationRequest] = []
    @Published var nextView: NextView?
    
    override init() {
        super .init()
        notificationCenter.delegate = self
    }
    
    func requestAuthorization() async throws {
        try await notificationCenter
            .requestAuthorization(options: [.sound, .badge, .alert])
        registerActions()
        await getCurrentSettings()
    }
    
    func getCurrentSettings() async {
        let currentSettings = await notificationCenter.notificationSettings()
        isGranted = (currentSettings.authorizationStatus == .authorized)
//        print(isGranted)
    }
    
    
    func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            if UIApplication.shared.canOpenURL(url) {
                Task {
                    await UIApplication.shared.open(url)
                }
            }
        }
    }
    
    func schedule(locaNotification: LocalNotificationModel) async {
        let content = UNMutableNotificationContent()
        content.title = locaNotification.title
        content.body = locaNotification.body
        if let subtitle = locaNotification.subtitle {
            content.subtitle = subtitle
        }
        if let bundleImageName = locaNotification.bundleImageName {
            if let url = Bundle.main.url(forResource: bundleImageName, withExtension: "") {
                if let attachment = try? UNNotificationAttachment(identifier: bundleImageName, url: url) {
                    content.attachments = [attachment]
                }
            }
        }
        if let userInfo = locaNotification.userInfo {
            content.userInfo = userInfo
        }
        if let categoryIdentifier = locaNotification.categoryIdentifier {
            content.categoryIdentifier = categoryIdentifier
        }
        
        content.sound = .default
        if locaNotification.scheduleType == .time {
            guard let timeInterval = locaNotification.timeInterval else { return }
            let trigger = UNTimeIntervalNotificationTrigger(
                timeInterval: timeInterval,
                repeats: locaNotification.repeats
            )
            let request = UNNotificationRequest(
                identifier: locaNotification.identifier,
                content: content,
                trigger: trigger
            )
            try? await notificationCenter.add(request)
        } else {
            guard let dateComponents = locaNotification.dateComponents else { return }
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: locaNotification.repeats)
            let request = UNNotificationRequest(
                identifier: locaNotification.identifier,
                content: content,
                trigger: trigger
            )
            try? await notificationCenter.add(request)
        }
        await getPendingRequests()
    }
    
    func getPendingRequests() async {
        pendingRequests = await notificationCenter.pendingNotificationRequests()
        print("Pending: \(pendingRequests.count)")
    }
    
    func removeRequest(withIdentifier identifier: String) {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [identifier])
        if let index = pendingRequests.firstIndex(where: {$0.identifier == identifier}) {
            pendingRequests.remove(at: index)
            print("Pending: \(pendingRequests.count)")
        }
    }
    
    func clearRequests() {
        notificationCenter.removeAllPendingNotificationRequests()
        pendingRequests.removeAll()
        print("Pending: \(pendingRequests.count)")
    }
    
}

extension LocalNotificationManager: UNUserNotificationCenterDelegate {
    
    func registerActions() {
        let snooze10Action = UNNotificationAction(identifier: "snooze10", title: "Snooze 10 seconds")
        let snooze60Action = UNNotificationAction(identifier: "snooze60", title: "Snooze 60 seconds")
        let snoozeCategory = UNNotificationCategory(identifier: "snooze", actions: [snooze10Action, snooze60Action], intentIdentifiers: [])
        notificationCenter.setNotificationCategories([snoozeCategory])
    }
    
    // Delegate function - for show notification when you in app
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification) async -> UNNotificationPresentationOptions{
       await getPendingRequests()
        return [.sound, .banner]
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async {
        if let value = response.notification.request.content.userInfo["nextView"] as? String {
            nextView = NextView(rawValue: value)
        }
        
        // Respond to snooze action
        var snoozeInterval: Double?
        if response.actionIdentifier == "snooze10" {
            snoozeInterval = 10
        } else {
            if response.actionIdentifier == "snooze60" {
                snoozeInterval = 60
            }
        }
        
        if let snoozeInterval = snoozeInterval {
            let content = response.notification.request.content
            let newContent = content.mutableCopy() as! UNMutableNotificationContent
            let newTrigger = UNTimeIntervalNotificationTrigger(timeInterval: snoozeInterval, repeats: false)
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: newContent, trigger: newTrigger)
           
            do {
                try? await notificationCenter.add(request)
            } catch {
                print(error.localizedDescription)
            }
            
            await getPendingRequests()
        }
        
    }
}
