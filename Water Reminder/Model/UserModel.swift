//
//  UserModel.swift
//  Water Reminder
//
//  Created by KEREM BOYLU on 26.05.2025.
//

import Foundation
import FirebaseAuth

struct AppUser: Identifiable, Codable {
    let id: String
    var email: String?
    var username: String?
    var creationDate: Date?
    var lastSignInDate: Date?
    var age: Int?
    var height: Int?
    var weight: Int?
    var dailyGoal: Int?
    
    init(from firebaseUser: FirebaseAuth.User) {
        self.id = firebaseUser.uid
        self.email = firebaseUser.email
        self.username = nil
        self.creationDate = firebaseUser.metadata.creationDate
        self.lastSignInDate = firebaseUser.metadata.lastSignInDate
        self.age = nil
        self.height = nil
        self.weight = nil
        self.dailyGoal = nil
    }
    
    init(
        id: String,
        email: String? = nil,
        username: String? = nil,
        creationDate: Date? = nil,
        lastSignInDate: Date? = nil,
        age: Int? = nil,
        height: Int? = nil,
        weight: Int? = nil,
        dailyGoal: Int? = nil
    ) {
        self.id = id
        self.email = email
        self.username = username
        self.creationDate = creationDate
        self.lastSignInDate = lastSignInDate
        self.age = age
        self.height = height
        self.weight = weight
        self.dailyGoal = dailyGoal
    }
}
