//
//  SetupProfileView.swift
//  Water Reminder
//
//  Created by KEREM BOYLU on 30.05.2025.
//

import SwiftUI
import FirebaseAuth

struct SetupProfileView: View {
    @State private var username: String = ""
    @State private var age: Int? = nil
    @State private var height: Int? = nil
    @State private var weight: Int? = nil
    @State private var dailyGoal: Int? = nil
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Personel Information")) {
                    TextField("Username*", text: $username)
                    TextField("Age", value: $age, format: .number)
                        .keyboardType(.numberPad)
                        
                    TextField("Height", value: $height, format: .number)
                        .keyboardType(.numberPad)
                        
                    TextField("Weight", value: $weight, format: .number)
                        .keyboardType(.numberPad)
                        
                    TextField("Daily Water Goal (ml)*", value: $dailyGoal, format: .number)
                        .keyboardType(.numberPad)
                        .submitLabel(.done)
                }
                
                Section {
                    Button("Save") {
                        saveProfile()
                    }
                    .disabled(username.isEmpty || dailyGoal == nil)
                }
            }
            .navigationTitle(Text("Setup Profile"))
        }
    }
    
    private func saveProfile() {
        guard let userID = Auth.auth().currentUser?.uid else {
            print("❌ Unauthenticated user.")
            return
        }

        var user = AppUser(from: Auth.auth().currentUser!)
        user.username = username
        user.age = age
        user.height = height
        user.weight = weight
        user.dailyGoal = dailyGoal

        FirebaseService.saveUserProfile(userID: userID, user: user) { error in
            if let error = error {
                print("❌ Error saving profile: \(error.localizedDescription)")
            } else {
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let window = windowScene.windows.first {
                    window.rootViewController = UIHostingController(rootView: MainTabView())
                    window.makeKeyAndVisible()
                }
            }
        }
    }
}

#Preview {
    SetupProfileView()
}
