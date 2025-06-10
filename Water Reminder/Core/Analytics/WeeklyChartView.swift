//
//  weeklytestUIView.swift
//  Water Reminder
//
//  Created by KEREM BOYLU on 8.05.2025.
//

import SwiftUI
import Charts


struct DailyChartData: Identifiable {
    var id: String { "\(date)-\(type.id)" }
    let date: Date
    let type: HydrationType
    let value: Int
}

struct WeeklyChartView: View {

    @Binding var HydrationData: [HydrationEntry]
    let types: [HydrationType]
    @State private var selectedWeek: DateInterval = Calendar.current.dateInterval(of: .weekOfYear,for: Date())!
    @State private var selectedDay: Date? = nil
    @EnvironmentObject var typeManager: HydrationTypeManager

    
    var body: some View {
    
        VStack(alignment: .leading, spacing: 12) {
            weekSwitcherBar()
                .padding(.bottom)
            
            VStack(alignment: .leading, spacing: 4) {
                if !hasData(in: selectedWeek, data: HydrationData){
                    Text("AVERAGE")
                        .font(.caption)
                        .hidden()
                    
                    Text("No Data")
                        .font(.title)
                        .bold()
                    
                } else if selectedDay != nil {
                    Text("AVERAGE")
                        .font(.caption)
                        .hidden()
                    
                    Text("ml")
                        .font(.title)
                        .bold()
                        .hidden()
                    
                } else {
                    Text("AVERAGE")
                        .font(.caption)
                    
                    Text("\(calculateAverage(for: selectedWeek, using:HydrationData)) ml")
                        .font(.title)
                        .bold()
                }
            }
            
            hydrationWeeklyChart(weeklyChartData)
        }
        .padding(.horizontal)
        .animation(.easeInOut, value: selectedWeek)
    }
    
    @ViewBuilder
    func weekSwitcherBar() -> some View {
        HStack {
            Button(action: {
                let prevWeek = Calendar.current.date(byAdding: .weekOfYear, value: -1, to: selectedWeek.start)!
                selectedWeek = Calendar.current.dateInterval(of: .weekOfYear, for: prevWeek) ?? selectedWeek
            }) {
                Image(systemName: "chevron.left")
                    .foregroundColor(.secondary)
                    .padding()
            }

            Divider()
                .frame(width: 1, height: 15)
                .background(Color.gray.opacity(0.5))

            Spacer()

            Text(Date.formattedRange(from: selectedWeek.start, to: selectedWeek.end - 1))
                .font(.subheadline)
                .bold()

            Spacer()

            Divider()
                .frame(width: 1, height: 15)
                .background(Color.gray.opacity(0.5))

            let today = Calendar.current.startOfDay(for: Date())
            let nextWeek = Calendar.current.date(byAdding: .weekOfYear, value: 1, to: selectedWeek.start)!
            let isFutureWeek = nextWeek > today

            Button(action: {
                if !isFutureWeek {
                    selectedWeek = Calendar.current.dateInterval(of: .weekOfYear, for: nextWeek) ?? selectedWeek
                }
            }) {
                Image(systemName: "chevron.right")
                    .foregroundColor(isFutureWeek ? .gray : .secondary)
                    .padding()
            }
        }
        .frame(height: 30)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(.systemGray5))
        )}

    @ViewBuilder
    func hydrationWeeklyChart(_ chartData: [DailyChartData]) -> some View {
        Chart {
            if let selected = selectedDay {
                let totalForDay = chartData
                    .filter { Calendar.current.isDate($0.date, inSameDayAs: selected) }
                    .reduce(0) { $0 + $1.value }

                if totalForDay > 0 {
                    RuleMark(x: .value("Selected Day", selected, unit: .day))
                        .zIndex(-10)
                        .offset(yStart: -10)
                        .foregroundStyle(.secondary)
                        .annotation(position: .top,
                                    spacing: 0,
                                    overflowResolution: .init(x: .fit(to: .chart), y: .disabled)) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("TOTAL")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text("\(totalForDay) ml")
                                    .font(.title3)
                                    .bold()
                                Text(selected.formattedDate(format: "d MMM yyyy"))
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                    .bold()
                            }
                            .padding(6)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color(.systemGray6))
                            )
                        }
                }
            }

            ForEach(chartData.sorted(by: { $0.type.stackPriority < $1.type.stackPriority })) { data in
                BarMark(
                    x: .value("Day", data.date, unit: .day),
                    y: .value("Amount", data.value),
                    stacking: .standard
                )
                .foregroundStyle(data.type.color)
                .opacity(selectedDay == nil || Calendar.current.isDate(selectedDay!, inSameDayAs: data.date) ? 1 : 0.3)
            }
        }
        .chartXSelection(value: $selectedDay)
        .chartXScale(domain: selectedWeek.start...selectedWeek.end - 1)
        .chartXScale(range: .plotDimension(padding: 16))
        .chartXAxis {
            let calendar = Calendar.current
            let weekDays = (0..<7).compactMap {
                calendar.date(byAdding: .day, value: $0, to: calendar.startOfDay(for: selectedWeek.start))
            }

            AxisMarks(values: weekDays) { date in
                AxisGridLine()
                AxisTick()
                AxisValueLabel {
                    if let date = date.as(Date.self) {
                        Text(date.weekdaySymbol())
                            .foregroundColor(.gray)
                            .font(.caption2)
                    }
                }
            }
        }
        .frame(height: 240)
        
        let usedTypes = Set(chartData.map { $0.type })
        
        HStack(spacing: 16) {
            if !usedTypes.isEmpty{
                ForEach(Array(usedTypes).sorted(by: { $0.stackPriority < $1.stackPriority }), id: \.id) { type in
                    HStack(spacing: 4) {
                        Circle()
                            .fill(type.color)
                            .frame(width: 10, height: 10)
                        Text(type.name)
                            .font(.caption)
                    }
                }
            }
        }
        .frame(height: 24)
    }
    
    func hasData(in week: DateInterval, data: [HydrationEntry]) -> Bool {
        let calendar = Calendar.current
        let weekStart = calendar.startOfDay(for: week.start)
        let days = (0..<7).compactMap {
            calendar.date(byAdding: .day, value: $0, to: weekStart)
        }
        let total = days.reduce(0) { sum, date in
            sum + data
                .filter { calendar.isDate($0.date, inSameDayAs: date) }
                .reduce(0) { $0 + $1.amount }
        }
        return total > 0
    }
}

private extension WeeklyChartView {
    var weekEntries: [HydrationEntry] {
        HydrationData.filter { entry in
            selectedWeek.contains(entry.date)
        }
    }
    
    var weeklyChartData: [DailyChartData] {
        let calendar = Calendar.current
        let groupedByDay = Dictionary(grouping: weekEntries) { entry in
            calendar.startOfDay(for: entry.date)
        }

        return processGroupedEntries(groupedByDay)
            .sorted { $0.date < $1.date }
    }
    
    func processGroupedEntries(_ groupedByDay: [Date: [HydrationEntry]]) -> [DailyChartData] {
        groupedByDay.flatMap { (date, entries) -> [DailyChartData] in
            let groupedByType = Dictionary(grouping: entries, by: \.typeID)

            return groupedByType.compactMap { typeID, sameTypeEntries in
                guard let type = typeManager.types.first(where: { $0.id == typeID }) else { return nil }
                let total = sameTypeEntries.reduce(0) { $0 + $1.amount }
                return DailyChartData(date: date, type: type, value: total)
            }
        }
    }
}

extension WeeklyChartView {
    func calculateAverage(for selectedWeek: DateInterval, using data: [HydrationEntry]) -> String {
        let calendar = Calendar.current
        let weekStart = calendar.startOfDay(for: selectedWeek.start)

        let dailyTotals: [Int] = (0..<7).compactMap { offset in
            guard let date = calendar.date(byAdding: .day, value: offset, to: weekStart) else {
                return nil
            }
            let totalForDay = data
                .filter { calendar.isDate($0.date, inSameDayAs: date) }
                .reduce(0) { $0 + $1.amount }

            return totalForDay > 0 ? totalForDay : nil
        }

        guard !dailyTotals.isEmpty else { return "0" }
        let sum = dailyTotals.reduce(0, +)
        let avg = sum / dailyTotals.count
        return avg.localizedString()
    }
}

#Preview {
    WeeklyChartView(HydrationData: .constant([]), types: [])
        .environmentObject(HydrationTypeManager())
}
