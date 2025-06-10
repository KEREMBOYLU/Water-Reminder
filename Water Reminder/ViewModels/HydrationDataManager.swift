//
//  HydrationDataManager.swift
//  Water Reminder
//
//  Created by KEREM BOYLU on 29.05.2025.
//

import Foundation
import FirebaseFirestore

class HydrationDataManager: ObservableObject {
    @Published var entries: [HydrationEntry] = []
    private var db = Firestore.firestore()
    private var listener: ListenerRegistration?

    init(userID: String) {
        fetchEntries(for: userID)
    }

    deinit {
        listener?.remove()
    }

    func fetchEntries(for userID: String) {
        listener = db.collection("users")
            .document(userID)
            .collection("hydrationEntries")
            .order(by: "date", descending: false)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                if let error = error {
                    print("❌ Failed to fetch hydration entries: \(error.localizedDescription)")
                    return
                }

                self.entries = snapshot?.documents.compactMap { doc in
                    try? doc.data(as: HydrationEntry.self)
                } ?? []
            }
    }
}
