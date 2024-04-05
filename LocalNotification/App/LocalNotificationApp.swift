//
//  LocalNotificationApp.swift
//  LocalNotification
//
//  Created by Benji Loya on 05.04.2024.
//

import SwiftUI

@main
struct LocalNotificationApp: App {
    
    @StateObject var lnManager = LocalNotificationManager()
    
    var body: some Scene {
        WindowGroup {
            NotificationsListView()
                .environmentObject(lnManager)
        }
    }
}
