//
//  LocalNotificationManager.swift
//  LocalNotification
//
//  Created by Benji Loya on 05.04.2024.
//

import SwiftUI
import NotificationCenter

@MainActor
class LocalNotificationManager: NSObject, ObservableObject, UNUserNotificationCenterDelegate {
   let notificationCenter = UNUserNotificationCenter.current()
    
    @Published var isGranted = false
    @Published var pendingRequests: [UNNotificationRequest] = []
    
    override init() {
        super .init()
        notificationCenter.delegate = self
    }
    
    // Delegate function - for show notification when you in app
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification) async -> UNNotificationPresentationOptions{
       await getPendingRequests()
        return [.sound, .banner]
    }
    
    func requestAuthorization() async throws {
        try await notificationCenter
            .requestAuthorization(options: [.sound, .badge, .alert])
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
    
    func schlude(locaNotification: LocalNotificationModel) async {
        let content = UNMutableNotificationContent()
        content.title = locaNotification.title
        content.body = locaNotification.body
        content.sound = .default
        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: locaNotification.timeInterval,
            repeats: locaNotification.repeats
        )
        let request = UNNotificationRequest(
            identifier: locaNotification.identifier,
            content: content,
            trigger: trigger
        )
        try? await notificationCenter.add(request)
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
