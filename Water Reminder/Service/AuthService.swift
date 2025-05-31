//
//  AuthService.swift
//  Water Reminder
//
//  Created by KEREM BOYLU on 29.05.2025.
//

import Foundation
import FirebaseAuth

class AuthService {
    
    static let shared = AuthService()
    
    private init() {}
    
    func signUp(email: String, password: String, completion: @escaping (Result<AuthDataResult, Error>) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password, completion: { result, error in
            if let error = error {
                completion(.failure(error))
            } else if let result = result {
                completion(.success(result))
            }
        })
    }
    
    func signIn(email: String, password: String, completion: @escaping (Result<AuthDataResult, Error>) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password, completion: { result, error in
            if let error = error {
                completion(.failure(error))
            } else if let result = result {
                completion(.success(result))
            }
        })
    }
    
    func signOut() throws {
        try Auth.auth().signOut()
    }
    
    func getCurrentUser() -> FirebaseAuth.User? {
        return Auth.auth().currentUser
    }
}
