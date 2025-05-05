//
//  WeeklyChartView.swift
//  Water Reminder
//
//  Created by KEREM BOYLU on 4.05.2025.
//

import SwiftUI
import Charts

struct WeeklyChartView: View {
    let data = WaterData.MOCK_WATER_DATA
    @State private var selectedDate = Calendar.current.startOfDay(for: Date())
    
    let firstWeekdaySetting = 2 // 1 = Sunday, 2 = Monday (default)
    let preferred = Locale.preferredLanguages.first ?? "en"
    
    var calendar: Calendar {
        var cal = Calendar(identifier: .gregorian)
        cal.locale = Locale(identifier: Locale.current.identifier)
        cal.firstWeekday = firstWeekdaySetting // 1 = Sunday, 2 = Monday
        return cal
    }
    
    var body: some View {
        let weekStart = calendar.dateInterval(of: .weekOfYear, for: selectedDate)!.start
        let weekdayComponent = calendar.component(.weekday, from: weekStart)
        let adjustment = (weekdayComponent - calendar.firstWeekday + 7) % 7
        let correctedWeekStart = calendar.date(byAdding: .day, value: -adjustment, to: weekStart)!
        let weekEnd = calendar.date(byAdding: .day, value: 7, to: correctedWeekStart)!
        
        let weekData = data.filter { $0.date >= correctedWeekStart && $0.date < weekEnd }
        
        let dailyTotals: [(date: Date, total: Int)] = (0..<7).map { offset in
            let date = calendar.date(byAdding: .day, value: offset, to: correctedWeekStart)!
            let total = weekData.filter { calendar.isDate($0.date, inSameDayAs: date) }
                .reduce(0) { $0 + $1.amount }
            return (date: date, total: total)
        }
        
        VStack(alignment: .leading, spacing: 8) {
            VStack(alignment: .leading, spacing: 4) {
                if dailyTotals.allSatisfy({ $0.total == 0 }) {
                    Text("")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("No Data")
                        .font(.title)
                        .bold()
                    
                    Text(formattedDateRange(correctedWeekStart, to: weekEnd))
                        .foregroundColor(.gray)
                        .font(.subheadline)
                    
                } else {
                    Text("AVERAGE")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("\(formattedAverage(dailyTotals.map { $0.total })) ml")
                        .font(.title)
                        .bold()
                    
                    Text(formattedDateRange(correctedWeekStart, to: weekEnd))
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
            }
            .padding(.bottom, 4)
            
            Chart {
                ForEach(dailyTotals, id: \.date) { entry in
                    BarMark(
                        x: .value("Gün", weekdaySymbol(for: entry.date)),
                        y: .value("ml", entry.total)
                    )
                    .foregroundStyle(Color("ChartColor"))
                }
            }
            .padding(.top, 8)
            .frame(height: 220)
        }
        .padding(.horizontal)
        .gesture(
            DragGesture()
                .onEnded { value in
                    if value.translation.width > 50 {
                        // Go to previous week
                        if let newDate = calendar.date(byAdding: .day, value: -7, to: selectedDate) {
                            withAnimation(.easeInOut) { selectedDate = newDate }
                        }
                    } else if value.translation.width < -50 {
                        // Go to next week (but not future)
                        let nextWeek = calendar.date(byAdding: .day, value: 7, to: selectedDate)!
                        if nextWeek <= calendar.startOfDay(for: Date()) {
                            withAnimation(.easeInOut) { selectedDate = nextWeek }
                        }
                    }
                }
        )
    }
    
    func weekdaySymbol(for weekday: Int) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: preferred)
        return formatter.shortStandaloneWeekdaySymbols[weekday - 1]
    }
    
    func weekdaySymbol(for date: Date) -> String {
        let weekday = calendar.component(.weekday, from: date)
        return weekdaySymbol(for: weekday)
    }
    
    func formattedAverage(_ data: [Int]) -> String {
        guard !data.isEmpty else { return "0" }
        let total = data.reduce(0, +)
        let avg = Double(total) / Double(data.count)
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: preferred)
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: avg)) ?? "-"
    }
    
    func formattedDateRange(_ from: Date, to: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: preferred)
        
        let fromComponents = calendar.dateComponents([.day, .month, .year], from: from)
        let toComponents = calendar.dateComponents([.day, .month, .year], from: to)
        
        let monthSymbols = formatter.shortMonthSymbols ?? []
        
        let fromDay = fromComponents.day ?? 0
        let fromMonth = fromComponents.month ?? 1
        let fromYear = fromComponents.year ?? 0
        
        let toDay = toComponents.day ?? 0
        let toMonth = toComponents.month ?? 1
        let toYear = toComponents.year ?? 0
        
        let fromMonthName = monthSymbols[safe: fromMonth - 1] ?? ""
        let toMonthName = monthSymbols[safe: toMonth - 1] ?? ""
        
        if fromYear != toYear {
            return "\(fromDay) \(fromMonthName) \(fromYear) – \(toDay) \(toMonthName) \(toYear)"
        } else if fromMonth != toMonth {
            return "\(fromDay) \(fromMonthName) – \(toDay) \(toMonthName) \(toYear)"
        } else {
            return "\(fromDay) – \(toDay) \(toMonthName) \(toYear)"
        }
    }
}

#Preview {
    WeeklyChartView()
}

//Safe array access for collection
extension Collection {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
