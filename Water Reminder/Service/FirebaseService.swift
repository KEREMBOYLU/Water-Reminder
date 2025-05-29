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
}
