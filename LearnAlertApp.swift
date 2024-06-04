//
//  LearnAlertApp.swift
//  LearnAlert
//
//  Created by Blake Miller on 3/27/24.
//

import SwiftUI
import SwiftData
import UserNotifications


@main
struct LearnAlertApp: App {
    init() {
        UNUserNotificationCenter.current().delegate = NotificationHandler.shared
    }

    var body: some Scene {
        WindowGroup {
            //MainTabView()
            SplashScreen()
                .preferredColorScheme(.dark)
        }   
    
    
        .modelContainer(for: Deck.self)
    }
}
