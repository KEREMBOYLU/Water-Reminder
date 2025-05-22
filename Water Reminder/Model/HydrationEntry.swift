//
//  HydrationEntry.swift
//  Water Reminder
//
//  Created by KEREM BOYLU on 21.05.2025.
//

import Foundation

struct HydrationEntry: Identifiable, Codable {
    let id: UUID
    let date: Date
    let amount: Int
    let type: HydrationType
}

extension HydrationEntry {
    static let MOCK_DATA: [HydrationEntry] = [
        // May 12, 2025
        .init(id: UUID(), date: Date.from(year: 2025, month: 5, day: 12, hour: 8, minute: 30)!, amount: 300, type: .water),
        .init(id: UUID(), date: Date.from(year: 2025, month: 5, day: 12, hour: 8, minute: 45)!, amount: 250, type: .coffee),
        .init(id: UUID(), date: Date.from(year: 2025, month: 5, day: 12, hour: 18, minute: 45)!, amount: 400, type: .milk),

        // May 11, 2025
        .init(id: UUID(), date: Date.from(year: 2025, month: 5, day: 11, hour: 7, minute: 15)!, amount: 200, type: .milk),
        .init(id: UUID(), date: Date.from(year: 2025, month: 5, day: 11, hour: 10, minute: 30)!, amount: 300, type: .coffee),
        .init(id: UUID(), date: Date.from(year: 2025, month: 5, day: 11, hour: 14, minute: 0)!, amount: 350, type: .water),

        // May 10, 2025
        .init(id: UUID(), date: Date.from(year: 2025, month: 5, day: 10, hour: 9, minute: 0)!, amount: 250, type: .coffee),
        .init(id: UUID(), date: Date.from(year: 2025, month: 5, day: 10, hour: 12, minute: 30)!, amount: 300, type: .milk),
        .init(id: UUID(), date: Date.from(year: 2025, month: 5, day: 10, hour: 17, minute: 15)!, amount: 400, type: .water),

        // May 9, 2025
        .init(id: UUID(), date: Date.from(year: 2025, month: 5, day: 9, hour: 8, minute: 45)!, amount: 350, type: .milk),
        .init(id: UUID(), date: Date.from(year: 2025, month: 5, day: 9, hour: 11, minute: 0)!, amount: 200, type: .coffee),
        .init(id: UUID(), date: Date.from(year: 2025, month: 5, day: 9, hour: 16, minute: 30)!, amount: 500, type: .water),

        // May 8, 2025
        .init(id: UUID(), date: Date.from(year: 2025, month: 5, day: 8, hour: 7, minute: 30)!, amount: 250, type: .coffee),
        .init(id: UUID(), date: Date.from(year: 2025, month: 5, day: 8, hour: 12, minute: 0)!, amount: 300, type: .milk),
        .init(id: UUID(), date: Date.from(year: 2025, month: 5, day: 8, hour: 15, minute: 45)!, amount: 350, type: .water)
    ]
}
