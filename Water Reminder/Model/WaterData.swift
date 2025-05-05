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

        // Day 4: May 1, 2025
        .init(id: UUID().uuidString, date: ISO8601DateFormatter().date(from: "2025-05-01T08:00:00Z")!, amount: 250),
        .init(id: UUID().uuidString, date: ISO8601DateFormatter().date(from: "2025-05-01T11:00:00Z")!, amount: 200),
        .init(id: UUID().uuidString, date: ISO8601DateFormatter().date(from: "2025-05-01T13:30:00Z")!, amount: 500),
        .init(id: UUID().uuidString, date: ISO8601DateFormatter().date(from: "2025-05-01T16:00:00Z")!, amount: 200),
        .init(id: UUID().uuidString, date: ISO8601DateFormatter().date(from: "2025-05-01T18:30:00Z")!, amount: 200),

        // Day 5: Apr 30, 2025
        .init(id: UUID().uuidString, date: ISO8601DateFormatter().date(from: "2025-04-30T09:15:00Z")!, amount: 300),
        .init(id: UUID().uuidString, date: ISO8601DateFormatter().date(from: "2025-04-30T12:45:00Z")!, amount: 400),
        .init(id: UUID().uuidString, date: ISO8601DateFormatter().date(from: "2025-04-30T15:00:00Z")!, amount: 250),
        .init(id: UUID().uuidString, date: ISO8601DateFormatter().date(from: "2025-04-30T17:30:00Z")!, amount: 200),

        // Day 6: Apr 29, 2025
        .init(id: UUID().uuidString, date: ISO8601DateFormatter().date(from: "2025-04-29T08:00:00Z")!, amount: 150),
        .init(id: UUID().uuidString, date: ISO8601DateFormatter().date(from: "2025-04-29T10:00:00Z")!, amount: 250),
        .init(id: UUID().uuidString, date: ISO8601DateFormatter().date(from: "2025-04-29T14:00:00Z")!, amount: 500),

        // Day 7: Apr 28, 2025
        .init(id: UUID().uuidString, date: ISO8601DateFormatter().date(from: "2025-04-28T09:30:00Z")!, amount: 300),
        .init(id: UUID().uuidString, date: ISO8601DateFormatter().date(from: "2025-04-28T11:45:00Z")!, amount: 400),
        .init(id: UUID().uuidString, date: ISO8601DateFormatter().date(from: "2025-04-28T16:15:00Z")!, amount: 200),

        // Day 8: Apr 27, 2025
        .init(id: UUID().uuidString, date: ISO8601DateFormatter().date(from: "2025-04-27T07:00:00Z")!, amount: 200),
        .init(id: UUID().uuidString, date: ISO8601DateFormatter().date(from: "2025-04-27T12:00:00Z")!, amount: 330),
        .init(id: UUID().uuidString, date: ISO8601DateFormatter().date(from: "2025-04-27T18:00:00Z")!, amount: 500),

        // Day 9: Apr 26, 2025
        .init(id: UUID().uuidString, date: ISO8601DateFormatter().date(from: "2025-04-26T08:30:00Z")!, amount: 150),
        .init(id: UUID().uuidString, date: ISO8601DateFormatter().date(from: "2025-04-26T13:00:00Z")!, amount: 500),
        .init(id: UUID().uuidString, date: ISO8601DateFormatter().date(from: "2025-04-26T16:30:00Z")!, amount: 300),

        // Day 10: Apr 25, 2025
        //.init(id: UUID().uuidString, date: ISO8601DateFormatter().date(from: "2025-04-25T09:00:00Z")!, amount: 200),
        //.init(id: UUID().uuidString, date: ISO8601DateFormatter().date(from: "2025-04-25T14:15:00Z")!, amount: 400),

        // Day 11: Apr 24, 2025
        .init(id: UUID().uuidString, date: ISO8601DateFormatter().date(from: "2025-04-24T10:30:00Z")!, amount: 200),
        .init(id: UUID().uuidString, date: ISO8601DateFormatter().date(from: "2025-04-24T15:45:00Z")!, amount: 500),

        // Day 12: Apr 23, 2025
        .init(id: UUID().uuidString, date: ISO8601DateFormatter().date(from: "2025-04-23T07:15:00Z")!, amount: 250),
        .init(id: UUID().uuidString, date: ISO8601DateFormatter().date(from: "2025-04-23T13:30:00Z")!, amount: 400),

        // Day 13: Apr 22, 2025
        .init(id: UUID().uuidString, date: ISO8601DateFormatter().date(from: "2025-04-22T09:45:00Z")!, amount: 200),
        .init(id: UUID().uuidString, date: ISO8601DateFormatter().date(from: "2025-04-22T17:00:00Z")!, amount: 330),

        // Day 14: Apr 21, 2025
        .init(id: UUID().uuidString, date: ISO8601DateFormatter().date(from: "2025-04-21T11:00:00Z")!, amount: 500),
        .init(id: UUID().uuidString, date: ISO8601DateFormatter().date(from: "2025-04-21T18:30:00Z")!, amount: 500),
    ]
}
