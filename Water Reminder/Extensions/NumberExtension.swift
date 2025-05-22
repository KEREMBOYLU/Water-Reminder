//
//  NumberExtension.swift
//  Water Reminder
//
//  Created by KEREM BOYLU on 22.05.2025.
//

import Foundation

extension Int {
    
    func localizedString() -> String {
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: preferred)
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: self)) ?? "\(self)"
    }
}
