//
//  ContentView.swift
//  Water Reminder
//
//  Created by KEREM BOYLU on 1.05.2025.
//

import SwiftUI
import FirebaseAuth

struct ContentView: View {
    var body: some View {
    
        if Auth.auth().currentUser != nil {
            MainTabView()
        } else {
            WelcomeView()
        }
    }
}

#Preview {
    ContentView()
}
