//
//  HydrationTypeManager.swift
//  Water Reminder
//
//  Created by KEREM BOYLU on 27.05.2025.
//

import Foundation
import FirebaseFirestore

@MainActor
class HydrationTypeManager: ObservableObject {
    @Published var types: [HydrationType] = []
    
    func loadTypes() {
        FirebaseService.fetchHydrationTypes { [weak self] fetchedTypes in
            DispatchQueue.main.async {
                self?.types = fetchedTypes
                print("✅ Hydration Types Loaded:")
                for t in fetchedTypes {
                    print("- \(t.name) (\(t.id))")
                }
            }
        }
    }
}
