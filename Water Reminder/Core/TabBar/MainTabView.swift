//
//  MainTabView.swift
//  Water Reminder
//
//  Created by KEREM BOYLU on 1.05.2025.
//

import SwiftUI

struct MainTabView: View {
    @State private var HydrationData: [HydrationEntry] = HydrationEntry.MOCK_DATA
    
    var body: some View {
        TabView{
            AnalyticsView(HydrationData: $HydrationData)
                .tabItem{
                    Image(systemName: "chart.bar.xaxis")
                }
//            HomeView(waterData: $waterData)
//                .tabItem{
//                    Image(systemName: "waterbottle")
//                }
            Text("Settings")
                .tabItem{
                    Image(systemName: "gearshape")
                }
        }
        .accentColor(Color("tabBarItemColor"))
    }
}

#Preview {
    MainTabView()
}
