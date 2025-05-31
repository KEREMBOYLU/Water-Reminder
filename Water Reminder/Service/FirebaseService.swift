//
//  FirebaseService.swift
//  Water Reminder
//
//  Created by KEREM BOYLU on 27.05.2025.
//

import FirebaseFirestore

class FirebaseService {
    static let db = Firestore.firestore()

    static func fetchHydrationTypes(completion: @escaping ([HydrationType]) -> Void) {
        db.collection("hydration_types").getDocuments { snapshot, error in
            guard let documents = snapshot?.documents, error == nil else {
                print("❌ Error fetching types: \(error?.localizedDescription ?? "Unknown")")
                completion([])
                return
            }

            let types: [HydrationType] = documents.compactMap { doc in
                try? doc.data(as: HydrationType.self)
            }
            completion(types)
        }
    }

    static func addHydrationEntry(for userID: String, entry: HydrationEntry, completion: @escaping (Error?) -> Void) {
        do {
            try db.collection("users")
                .document(userID)
                .collection("hydrationEntries")
                .document(entry.id)
                .setData(from: entry) { error in
                    if let error = error {
                        print("❌ Failed to add entry: \(error.localizedDescription)")
                    } else {
                        print("✅ Hydration entry added for user \(userID)")
                    }
                    completion(error)
                }
        } catch {
            print("❌ Encoding error: \(error)")
            completion(error)
        }
    }

    static func saveUserProfile(userID: String, user: AppUser, completion: @escaping (Error?) -> Void) {
        do {
            try db.collection("users")
                .document(userID)
                .setData(from: user) { error in
                    if let error = error {
                        print("❌ Failed to save user profile: \(error.localizedDescription)")
                    } else {
                        print("✅ User profile saved for \(userID)")
                    }
                    completion(error)
                }
        } catch {
            print("❌ Encoding error: \(error)")
            completion(error)
        }
    }
}
