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
    
    var body: some View {
        NavigationStack {
            VStack {
                
                if lnManager.isGranted {
                    GroupBox("Shelude") {
                        Button("Interval Notification") {
                            Task {
                                let localNotification = LocalNotificationModel(
                                    identifier: UUID().uuidString,
                                    title: "Some Title",
                                    body: "Some Body",
                                    timeInterval: 60,
                                    repeats: true)
                                await lnManager.schlude(locaNotification: localNotification)
                            }
                        }
                        .buttonStyle(.bordered)
                        
                        Button("Calendar Notification") {
                            
                        }
                        .buttonStyle(.bordered)
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
