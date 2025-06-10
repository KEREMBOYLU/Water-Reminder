//
//  HydrationEntry.swift
//  Water Reminder
//
//  Created by KEREM BOYLU on 21.05.2025.
//

import Foundation

struct HydrationEntry: Identifiable, Codable {
    let id: String
    let date: Date
    let amount: Int
    let typeID: String  // Reference to HydrationType's ID

    init(id: String = UUID().uuidString, date: Date, amount: Int, typeID: String) {
        self.id = id
        self.date = date
        self.amount = amount
        self.typeID = typeID
    }
}

extension HydrationEntry {
    static var MOCK_DATA: [HydrationEntry] = [
        HydrationEntry(id: UUID().uuidString, date: Date(), amount: 250, typeID: "water"),
        HydrationEntry(id: UUID().uuidString, date: Date().addingTimeInterval(-3600), amount: 150, typeID: "coffee")
    ]
}
