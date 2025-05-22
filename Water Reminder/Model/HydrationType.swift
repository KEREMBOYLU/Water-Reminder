//
//  HydrationType.swift
//  Water Reminder
//
//  Created by KEREM BOYLU on 21.05.2025.
//

import SwiftUI


struct HydrationType: Identifiable, Codable, Hashable {
    let id: String           // e.g. "water", "coffee"
    let name: String         // e.g. "Coffee"
    let waterRatio: Double   // e.g. 0.95
    let stackPriority: Int  // e.g.  1
    let iconName: String         // SF Symbol name
    let colorHex: String     // for UI use

    var color: Color {
        Color(hex: colorHex)
    }
    
    var icon: Image {
        Image(systemName: iconName)
    }
}

extension HydrationType {
    static let water = HydrationType(
        id: "water",
        name: "Su",
        waterRatio: 1.0,
        stackPriority: 1,
        iconName: "drop.fill",
        colorHex: "#4A90E2"
    )

    static let coffee = HydrationType(
        id: "coffee",
        name: "Kahve",
        waterRatio: 0.9,
        stackPriority: 2,
        iconName: "cup.and.saucer.fill",
        colorHex: "#6F4E37"
    )

    static let milk = HydrationType(
        id: "milk",
        name: "Süt",
        waterRatio: 0.87,
        stackPriority: 3,
        iconName: "carton.fill",
        colorHex: "#F7E7CE"
    )

    static let juice = HydrationType(
        id: "juice",
        name: "Meyve Suyu",
        waterRatio: 0.88,
        stackPriority: 4,
        iconName: "tropicaldrink.fill",
        colorHex: "#FFA500"
    )

    static let all: [HydrationType] = [water, coffee, milk, juice]
}
