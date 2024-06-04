//
//  MainTabView.swift
//  LearnAlert
//
//  Created by Blake Miller on 3/27/24.
//

import SwiftUI
struct MainTabView: View {
    var body: some View {
        TabView {
            DeckListView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
            
            NotificationsView()
                .tabItem {
                    Label("Notifications", systemImage: "bell.fill")
                }
            
            GlobalFlashcardsView()
                .tabItem {
                    Label("Library", systemImage: "folder.fill")
                }
            
            ProfileView()
                .tabItem {
                    Label("Setttings", systemImage: "gearshape.fill")
                }
        }
    }
}

#Preview("Dark") {
    return MainTabView()
        .preferredColorScheme(.dark)
        .modelContainer(PreviewHandler.previewContainer)
}
