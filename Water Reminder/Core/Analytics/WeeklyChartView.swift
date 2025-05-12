//
//  weeklytestUIView.swift
//  Water Reminder
//
//  Created by KEREM BOYLU on 8.05.2025.
//

import SwiftUI
import Charts

let preferred = Locale.preferredLanguages.first ?? "en"

struct WeeklyChartView: View {
    @State private var selectedWeek: DateInterval = Calendar.current.dateInterval(of: .weekOfYear, for: Date())!
    @State private var selectedDay: Date? = nil
    
    var selectedViewDay: ViewDay? {
        guard let selectedDay else { return nil }
        return viewDays.first { $0.date == selectedDay }
    }
    
    var viewDays: [ViewDay] {
        generateWeeklyTotals(from: WaterData.MOCK_WATER_DATA, for: selectedWeek)
    }
    
    var body: some View {

        VStack(alignment: .leading, spacing: 8) {
            VStack(alignment: .leading, spacing: 4) {
                if !hasData(in: selectedWeek, data: WaterData.MOCK_WATER_DATA) {
                    Text("")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Text("No Data")
                        .font(.title)
                        .bold()

                    Text(formattedDateRange(selectedWeek.start, to: selectedWeek.end))
                        .foregroundColor(.gray)
                        .font(.subheadline)
                    
                } else if selectedDay != nil {
                    Text(" ")
                        .font(.caption)
                    
                    Text(" ")
                        .font(.title)
                        .bold()
                    Text(" ")
                        .font(.subheadline)
                }
                else {
                    Text("AVERAGE")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Text("\(formattedAverage(viewDays.map { $0.total })) ml")
                        .font(.title)
                        .bold()

                    Text(formattedDateRange(selectedWeek.start, to: selectedWeek.end))
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }
            .padding(.bottom, 4)
            
            Chart {
                if let selected = selectedDay {
                    RuleMark(x: .value("Selected Day", selected, unit: .day))
                        .foregroundStyle(.secondary)
                        .annotation(position: .top, overflowResolution: .init(x: .fit(to: .chart), y: .disabled)) {
                            if let viewDay = viewDays.first(where: { Calendar.current.isDate($0.date, inSameDayAs: selected) }) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("TOTAL")
                                        .font(.caption)
                                        .foregroundColor(.secondary)

                                    Text("\(viewDay.total) ml")
                                        .font(.title3)
                                        .bold()

                                    Text(formattedDate(viewDay.date))
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                        .cornerRadius(8)
                }
                
                ForEach(viewDays) { viewDay in
                    BarMark(x: .value("Day", viewDay.date, unit: .day),
                            y: .value("Total", viewDay.total)
                    )
                    .foregroundStyle(Color("ChartColor"))
                    .opacity(selectedDay == nil || Calendar.current.isDate(selectedDay!, inSameDayAs: viewDay.date) ? 1 : 0.3)
                }
            }
            .chartXSelection(value: $selectedDay)
            .chartXAxis {
                AxisMarks(values: viewDays.map { $0.date }) { date in
                    AxisGridLine()
                    AxisTick()
                    AxisValueLabel {
                        if let date = date.as(Date.self) {
                            Text(weekdaySymbol(for: date))
                        }
                    }
                }
            }
            .frame(height: 220)
        }
        .padding(.horizontal)
        .padding(.bottom)
        .gesture(
            DragGesture()
                .onEnded { value in
                    let calendar = Calendar.current
                    let today = calendar.startOfDay(for: Date())
                    let nextWeek = calendar.date(byAdding: .day, value: 7, to: selectedWeek.start)!
                    let prevWeek = calendar.date(byAdding: .day, value: -7, to: selectedWeek.start)!

                    if value.translation.width > 50 {
                        selectedWeek = calendar.dateInterval(of: .weekOfYear, for: prevWeek) ?? selectedWeek
                    } else if value.translation.width < -50 {
                        if nextWeek <= today {
                            selectedWeek = calendar.dateInterval(of: .weekOfYear, for: nextWeek) ?? selectedWeek
                        }
                    }
                }
        )
    }
    
    func generateWeeklyTotals(from data: [WaterData], for week: DateInterval, calendar: Calendar = Calendar.current) -> [ViewDay] {
        let weekStart = calendar.startOfDay(for: week.start)
        _ = calendar.startOfDay(for: Date())

        return (0..<7).compactMap { offset in
            guard let date = calendar.date(byAdding: .day, value: offset, to: weekStart) else {
                return nil
            }
            let total = data
                .filter { calendar.isDate($0.date, inSameDayAs: date) }
                .reduce(0) { $0 + $1.amount }
            return ViewDay(date: date, total: total)
        }
    }
    
    func hasData(in week: DateInterval, data: [WaterData]) -> Bool {
        let calendar = Calendar.current
        let weekStart = calendar.startOfDay(for: week.start)
        let days = (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: weekStart) }
        
        let total = days.reduce(0) { sum, date in
            sum + data.filter { calendar.isDate($0.date, inSameDayAs: date) }.reduce(0) { $0 + $1.amount }
        }
        return total > 0
    }
    
    func weekdaySymbol(for weekday: Int) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(
            identifier: Locale.preferredLanguages.first ?? "en"
        )
        return formatter.shortStandaloneWeekdaySymbols[weekday - 1]
    }

    func weekdaySymbol(for date: Date) -> String {
        let calendar = Calendar.current
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
            let calendar = Calendar.current
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
            
            let fromMonthName = monthSymbols.indices.contains(fromMonth - 1) ? monthSymbols[fromMonth - 1] : ""
            let toMonthName = monthSymbols.indices.contains(toMonth - 1) ? monthSymbols[toMonth - 1] : ""
            
            if fromYear != toYear {
                return "\(fromDay) \(fromMonthName) \(fromYear) – \(toDay) \(toMonthName) \(toYear)"
            } else if fromMonth != toMonth {
                return "\(fromDay) \(fromMonthName) – \(toDay) \(toMonthName) \(toYear)"
            } else {
                return "\(fromDay) – \(toDay) \(toMonthName) \(toYear)"
            }
        }
    
    
}

struct ViewDay: Identifiable {
    let id = UUID()
    let date: Date
    let total: Int
}

extension Date {
    static func from(year: Int, month: Int, day: Int) -> Date {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        return Calendar.current.date(from: components)!
    }
}

#Preview {
    WeeklyChartView()
}

    func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: preferred)
        formatter.setLocalizedDateFormatFromTemplate("d MMMM yyyy EEE")
        return formatter.string(from: date)
    }

//Safe array access for collection
extension Collection {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
