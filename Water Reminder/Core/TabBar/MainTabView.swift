//
//  MainTabView.swift
//  Water Reminder
//
//  Created by KEREM BOYLU on 1.05.2025.
//

import SwiftUI
import FirebaseAuth
import UIKit

struct MainTabView: View {
    @StateObject private var userManager = UserManager()
    @State private var hydrationData: [HydrationEntry] = []
    @StateObject private var typeManager = HydrationTypeManager()
    
    var body: some View {
        NavigationStack {
            TabView {
                if let currentUser = userManager.currentUser {
                    AnalyticsView(currentUser: .constant(currentUser), typeManager: typeManager)
                        .tabItem {
                            Image(systemName: "chart.bar.xaxis")
                        }
                    HomeView(currentUser: .constant(currentUser), hydrationData: $hydrationData)
                        .tabItem {
                            Image(systemName: "waterbottle")
                        }
                }

                SettingsView()
                    .tabItem {
                        Image(systemName: "gearshape")
                    }
            }
            .accentColor(Color("WaterColor"))
            .background(Color("BackgroundColor").ignoresSafeArea())
            .fullScreenCover(isPresented: .constant({
                guard let user = userManager.currentUser else { return false }
                return user.age == 0 || user.height == 0 || user.weight == 0 || user.dailyGoal == 0
            }())) {
                SetupProfileView()
            }
            .onAppear {
                let tabBarAppearance = UITabBarAppearance()
                tabBarAppearance.configureWithOpaqueBackground()
                tabBarAppearance.backgroundColor = UIColor(named: "BackgroundColor")?.withAlphaComponent(0.2)
                UITabBar.appearance().standardAppearance = tabBarAppearance
                if #available(iOS 15.0, *) {
                    UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
                }
                
                typeManager.loadTypes()

                if let userID = userManager.currentUser?.id {
                    FirebaseService.fetchHydrationEntries(for: userID) { entries in
                        self.hydrationData = entries
                    }
                }
            }
        }
        
    }
}

#Preview {
    MainTabView()
}
