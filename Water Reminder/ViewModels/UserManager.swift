//
//  UserManager.swift
//  Water Reminder
//
//  Created by KEREM BOYLU on 26.05.2025.
//

import Foundation
import Combine
import FirebaseAuth

class UserManager: ObservableObject {
    @Published var currentUser: AppUser?

    init() {
        self.currentUser = nil
        loadCurrentUser()
    }
    
    static var preview: UserManager {
        let manager = UserManager()
        manager.currentUser = AppUser(
            id: UUID().uuidString,
            email: "preview@example.com",
            username: "previewUser",
            creationDate: Date(),
            lastSignInDate: Date(),
            age: 25,
            height: 175,
            weight: 70,
            dailyGoal: 3000
        )
        return manager
    }

    func loadHydrationEntries(completion: @escaping ([HydrationEntry]) -> Void) {
        FirebaseService.fetchHydrationEntries(for: currentUser?.id ?? "") { entries in
            DispatchQueue.main.async {
                completion(entries)
            }
        }
    }

    private func loadCurrentUser() {
        guard let user = Auth.auth().currentUser else {
            print("⚠️ No authenticated user found")
            return
        }

        FirebaseService.fetchUser(userID: user.uid) { fetchedUser in
            DispatchQueue.main.async {
                if let fetchedUser = fetchedUser {
                    self.currentUser = fetchedUser
                } else {
                    print("❌ Failed to fetch or decode user")
                }
            }
        }
    }
}
