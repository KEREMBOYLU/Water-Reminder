//
//  DateExtensions.swift
//  Water Reminder
//
//  Created by KEREM BOYLU on 12.05.2025.
//

import Foundation

let preferred = Locale.preferredLanguages.first ?? "en"

extension Date {
    static func from(year: Int, month: Int, day: Int) -> Date? {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        return Calendar.current.date(from: components)
    }
    
    func formattedDate(format: String = "default") -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: preferred)
        switch format{
        case "noDayName":
            formatter.setLocalizedDateFormatFromTemplate("d MMM yyyy")
            break
        case "noYear":
            formatter.setLocalizedDateFormatFromTemplate("d MMM EEE")
            break
        default:
            formatter.setLocalizedDateFormatFromTemplate("d MMM yyyy EEE")
            break
        }
        
        return formatter.string(from: self)
    }
    
    static func formattedRange(from startDate: Date, to endDate: Date, localeIdentifier: String = preferred) -> String {
        let calendar = Calendar.current
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: localeIdentifier)
        
        let start = calendar.dateComponents([.day, .month, .year], from: startDate)
        let end = calendar.dateComponents([.day, .month, .year], from: endDate)
        
        guard let startDay = start.day, let startMonth = start.month, let startYear = start.year,
              let endDay = end.day, let endMonth = end.month, let endYear = end.year,
              let monthSymbols = formatter.shortMonthSymbols else {
            return ""
        }

        let startMonthName = monthSymbols[safe: startMonth - 1] ?? ""
        let endMonthName = monthSymbols[safe: endMonth - 1] ?? ""

        if startYear != endYear {
            return "\(startDay) \(startMonthName) \(startYear) – \(endDay) \(endMonthName) \(endYear)"
        } else if startMonth != endMonth {
            return "\(startDay) \(startMonthName) – \(endDay) \(endMonthName) \(endYear)"
        } else {
            return "\(startDay) – \(endDay) \(endMonthName) \(endYear)"
        }
    }
    
    static func weekdaySymbol(for weekday: Int) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: preferred)
        return formatter.shortStandaloneWeekdaySymbols[weekday - 1]
    }
    
    func weekdaySymbol() -> String {
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: self)
        return Date.weekdaySymbol(for: weekday)
    }
}

extension Int {
    func localizedString() -> String {
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: preferred)
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: self)) ?? "\(self)"
    }
}

extension Collection {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
