//
//  ContentView.swift
//  LocalNotification
//
//  Created by Benji Loya on 05.04.2024.
//

import SwiftUI

struct NotificationsListView: View {
    
    @EnvironmentObject var lnManager: LocalNotificationManager
    @Environment(\.scenePhase) var scenePhase
    
    @State private var scheduleDate = Date()
    
    var body: some View {
        NavigationStack {
            VStack {
                
                if lnManager.isGranted {
                    GroupBox("Shelude") {
                        Button("Interval Notification") {
                            Task {
                                var localNotification = LocalNotificationModel(
                                    identifier: UUID().uuidString,
                                    title: "Some Title",
                                    body: "Some Body",
                                    timeInterval: 10,
                                    repeats: false) // if TRUE - min timeInterval = 60
                                localNotification.subtitle = "This is a subtitle"
                                localNotification.bundleImageName = "IMG_4349.JPG"
                                await lnManager.schlude(locaNotification: localNotification)
                            }
                        }
                        .buttonStyle(.bordered)
                        GroupBox {
                            DatePicker("", selection: $scheduleDate)
                            Button("Calendar Notification") {
                                Task {
                                    let dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: scheduleDate)
                                    let localNotification = LocalNotificationModel(
                                        identifier: UUID().uuidString,
                                        title: "Caalendar Notification",
                                        body: "Body calendar",
                                        dateComponents: dateComponents,
                                        repeats: false )
                                    await lnManager.schlude(locaNotification: localNotification)
                                }
                            }
                            .buttonStyle(.bordered)
                        }
                    }
                    .frame(width: 300)
                    // List View Here
                    List {
                        ForEach(lnManager.pendingRequests, id: \.identifier) { request in
                            VStack(alignment: .leading) {
                                Text(request.content.title)
                                HStack {
                                    Text(request.identifier)
                                        .font(.callout)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            .swipeActions {
                                Button("Delete", role: .destructive) {
                                    lnManager.removeRequest(withIdentifier: request.identifier)
                                }
                            }
                        }
                    }
                    
                    
                    
                } else {
                    Button("Enable Notification") {
                        lnManager.openSettings()
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .navigationTitle("Local Notifications")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        lnManager.clearRequests()
                    } label: {
                        Image(systemName: "clear.fill")
                            .imageScale(.large)
                    }
                }
            }
        }
        .task {
            try? await lnManager.requestAuthorization()
        }
        .onChange(of: scenePhase) { newValue, oldValue in
            if newValue == .active {
                Task {
                    await lnManager.getCurrentSettings()
                    await lnManager.getPendingRequests()
                }
            }
        }
    }
}

#Preview {
    NotificationsListView()
        .environmentObject(LocalNotificationManager())
}
