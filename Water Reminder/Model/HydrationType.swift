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
