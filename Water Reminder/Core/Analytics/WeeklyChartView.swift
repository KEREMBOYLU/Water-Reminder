//
//  weeklytestUIView.swift
//  Water Reminder
//
//  Created by KEREM BOYLU on 8.05.2025.
//

import SwiftUI
import Charts


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

                    Text(Date.formattedRange(from: selectedWeek.start, to: selectedWeek.end))
                        .foregroundColor(.gray)
                        .font(.subheadline)
                        .bold()
                    
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

                    Text("\(calculateAvarage(viewDays.map { $0.total })) ml")
                        .font(.title)
                        .bold()

                    Text(Date.formattedRange(from: selectedWeek.start, to: selectedWeek.end))
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .bold()
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

                                    Text(viewDay.date.formattedDate(format: "noDayName"))
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                        .bold()
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
                            Text(date.weekdaySymbol())
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
    
    func calculateAvarage(_ data: [Int]) -> String {
        guard !data.isEmpty else {return "0"}
        let total = data.reduce(0, +)
        let avg = total / data.count
        return avg.localizedString()
    }
}

struct ViewDay: Identifiable {
    let id = UUID()
    let date: Date
    let total: Int
}

#Preview {
    WeeklyChartView()
}
