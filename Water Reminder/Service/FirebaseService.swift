//
//  FirebaseService.swift
//  Water Reminder
//
//  Created by KEREM BOYLU on 27.05.2025.
//

import FirebaseFirestore

class FirebaseService {
    static let shared = FirebaseService()
    static let db = Firestore.firestore()

    static func fetchHydrationEntries(for userID: String, completion: @escaping ([HydrationEntry]) -> Void) {
        db.collection("users")
            .document(userID)
            .collection("hydrationEntries")
            .getDocuments { snapshot, error in
                guard let documents = snapshot?.documents, error == nil else {
                    print("❌ Error fetching hydration entries: \(error?.localizedDescription ?? "Unknown")")
                    completion([])
                    return
                }

                let entries: [HydrationEntry] = documents.compactMap { doc in
                    try? doc.data(as: HydrationEntry.self)
                }

                print("✅ Fetched \(entries.count) hydration entries for user \(userID)")
                completion(entries)
            }
    }

    static func addHydrationEntry(for userID: String, entry: HydrationEntry, completion: @escaping (Error?) -> Void) {
        db.collection("users")
            .document(userID)
            .collection("hydrationEntries")
            .document(entry.id)
            .setData(entry.toDictionary()) { error in
                if let error = error {
                    print("❌ Failed to add entry: \(error.localizedDescription)")
                } else {
                    print("✅ Hydration entry added for user \(userID)")
                }
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
    static func fetchUser(userID: String, completion: @escaping (AppUser?) -> Void) {
        db.collection("users").document(userID).getDocument { snapshot, error in
            if let error = error {
                print("❌ Error fetching user profile: \(error.localizedDescription)")
                completion(nil)
                return
            }

            guard let document = snapshot, document.exists,
                  let data = try? document.data(as: AppUser.self) else {
                print("❌ Failed to decode user profile")
                completion(nil)
                return
            }

            print("✅ Fetched user profile for user \(userID)")
            completion(data)
        }
    }

    static func fetchHydrationTypes(completion: @escaping ([HydrationType]) -> Void) {
        db.collection("hydration_types")
            .getDocuments { snapshot, error in
                guard let documents = snapshot?.documents, error == nil else {
                    print("❌ Error fetching hydration types: \(error?.localizedDescription ?? "Unknown")")
                    completion([])
                    return
                }

                let types: [HydrationType] = documents.compactMap { doc in
                    try? doc.data(as: HydrationType.self)
                }

                print("✅ Fetched \(types.count) hydration types")
                completion(types)
            }
    }
}

extension HydrationEntry {
    func toDictionary() -> [String: Any] {
        return [
            "id": id,
            "date": Timestamp(date: date),
            "amount": amount,
            "typeID": typeID
        ]
    }
}
