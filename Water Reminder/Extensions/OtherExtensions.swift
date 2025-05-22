//
//  OtherExtensions.swift
//  Water Reminder
//
//  Created by KEREM BOYLU on 22.05.2025.
//

import Foundation

extension Collection {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
