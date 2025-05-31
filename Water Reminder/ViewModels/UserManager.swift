//
//  UserManager.swift
//  Water Reminder
//
//  Created by KEREM BOYLU on 26.05.2025.
//

import Foundation
import Combine

class UserManager: ObservableObject {
    @Published var currentUser: AppUser

    init() {
        self.currentUser = AppUser(
            id: UUID().uuidString,
            email: "kerem@example.com",
            username: "keremb",
            creationDate: Date(),
            lastSignInDate: Date(),
            age: 21,
            height: 180,
            weight: 70,
            dailyGoal: 3000,
        )
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
}
