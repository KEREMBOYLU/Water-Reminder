//
//  WaterData.swift
//  Water Reminder
//
//  Created by KEREM BOYLU on 4.05.2025.
//

import Foundation

struct WaterData: Identifiable {
    let id: String
    let date: Date
    let amount: Int
}

extension WaterData{
    static var MOCK_WATER_DATA: [WaterData] = [
        // Day 1: May 4, 2025
        .init(id: UUID().uuidString, date: ISO8601DateFormatter().date(from: "2025-05-04T08:00:00Z")!, amount: 100),
        .init(id: UUID().uuidString, date: ISO8601DateFormatter().date(from: "2025-05-04T10:00:00Z")!, amount: 200),
        .init(id: UUID().uuidString, date: ISO8601DateFormatter().date(from: "2025-05-04T12:00:00Z")!, amount: 200),
        .init(id: UUID().uuidString, date: ISO8601DateFormatter().date(from: "2025-05-04T14:30:00Z")!, amount: 200),
        .init(id: UUID().uuidString, date: ISO8601DateFormatter().date(from: "2025-05-04T17:00:00Z")!, amount: 200),
        .init(id: UUID().uuidString, date: ISO8601DateFormatter().date(from: "2025-05-04T11:00:00Z")!, amount: 330),
        .init(id: UUID().uuidString, date: ISO8601DateFormatter().date(from: "2025-05-04T15:00:00Z")!, amount: 500),
        .init(id: UUID().uuidString, date: ISO8601DateFormatter().date(from: "2025-05-04T19:30:00Z")!, amount: 500),

        // Day 2: May 3, 2025
        .init(id: UUID().uuidString, date: ISO8601DateFormatter().date(from: "2025-05-03T08:30:00Z")!, amount: 200),
        .init(id: UUID().uuidString, date: ISO8601DateFormatter().date(from: "2025-05-03T09:45:00Z")!, amount: 100),
        .init(id: UUID().uuidString, date: ISO8601DateFormatter().date(from: "2025-05-03T12:00:00Z")!, amount: 200),
        .init(id: UUID().uuidString, date: ISO8601DateFormatter().date(from: "2025-05-03T13:30:00Z")!, amount: 200),
        .init(id: UUID().uuidString, date: ISO8601DateFormatter().date(from: "2025-05-03T16:15:00Z")!, amount: 200),
        .init(id: UUID().uuidString, date: ISO8601DateFormatter().date(from: "2025-05-03T11:30:00Z")!, amount: 1000),
        .init(id: UUID().uuidString, date: ISO8601DateFormatter().date(from: "2025-05-03T15:45:00Z")!, amount: 500),
        .init(id: UUID().uuidString, date: ISO8601DateFormatter().date(from: "2025-05-03T18:30:00Z")!, amount: 500),

        // Day 3: May 2, 2025
        .init(id: UUID().uuidString, date: ISO8601DateFormatter().date(from: "2025-05-02T07:45:00Z")!, amount: 150),
        .init(id: UUID().uuidString, date: ISO8601DateFormatter().date(from: "2025-05-02T09:15:00Z")!, amount: 200),
        .init(id: UUID().uuidString, date: ISO8601DateFormatter().date(from: "2025-05-02T11:45:00Z")!, amount: 200),
        .init(id: UUID().uuidString, date: ISO8601DateFormatter().date(from: "2025-05-02T13:00:00Z")!, amount: 900),
        .init(id: UUID().uuidString, date: ISO8601DateFormatter().date(from: "2025-05-02T16:00:00Z")!, amount: 300),
        .init(id: UUID().uuidString, date: ISO8601DateFormatter().date(from: "2025-05-02T10:30:00Z")!, amount: 500),
        .init(id: UUID().uuidString, date: ISO8601DateFormatter().date(from: "2025-05-02T14:45:00Z")!, amount: 500),
        .init(id: UUID().uuidString, date: ISO8601DateFormatter().date(from: "2025-05-02T17:30:00Z")!, amount: 50),
    ]
}
