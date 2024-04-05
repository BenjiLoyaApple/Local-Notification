//
//  ContentView.swift
//  LocalNotification
//
//  Created by Benji Loya on 05.04.2024.
//

import SwiftUI

struct ContentView: View {
    
    @EnvironmentObject var lnManager: LocalNotificationManager
    @Environment(\.scenePhase) var scenePhase
    
    var body: some View {
        NavigationStack {
            VStack {
                
                if lnManager.isGranted {
                    GroupBox("Shelude") {
                        Button("Interval Notification") {
                            
                        }
                        .buttonStyle(.bordered)
                        
                        Button("Calendar Notification") {
                            
                        }
                        .buttonStyle(.bordered)
                    }
                    .frame(width: 300)
                    // List View Here
                    
                } else {
                    Button("Enable Notification") {
                        lnManager.openSettings()
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .navigationTitle("Local Notifications")
        }
        .task {
            try? await lnManager.requestAuthorization()
        }
        .onChange(of: scenePhase) { newValue, oldValue in
            if newValue == .active {
                Task {
                   await lnManager.getCurrentSettings()
                }
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(LocalNotificationManager())
}
