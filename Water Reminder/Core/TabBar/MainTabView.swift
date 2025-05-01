//
//  MainTabView.swift
//  Water Reminder
//
//  Created by KEREM BOYLU on 1.05.2025.
//

import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView{
            Text("Calendar")
                .tabItem{
                    Image(systemName: "chart.bar.xaxis")
                }
            Text("Home")
                .tabItem{
                    Image(systemName: "waterbottle")
                }
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
