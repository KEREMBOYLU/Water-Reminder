//
//  SettingsView.swift
//  Water Reminder
//
//  Created by KEREM BOYLU on 31.05.2025.
//

import SwiftUI
import FirebaseAuth

struct SettingsView: View {
    var body: some View {
        VStack {
            Text("Settings")
                .font(.largeTitle)
                .padding()

            Button(action: {
                do {
                    let userUID = Auth.auth().currentUser?.uid ?? "Unknown UID"
                    try Auth.auth().signOut()
                    print("✅ User signed out: \(userUID)")

                    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                       let window = windowScene.windows.first {
                        window.rootViewController = UIHostingController(rootView: WelcomeView())
                        window.makeKeyAndVisible()
                    }
                } catch {
                    print("❌ Failed to sign out: \(error.localizedDescription)")
                }
            }) {
                Text("Sign Out")
                    .foregroundColor(.red)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
            }

            Spacer()
        }
        .padding()
    }
}

#Preview {
    SettingsView()
}
