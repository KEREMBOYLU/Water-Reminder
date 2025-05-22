//
//  weeklytestUIView.swift
//  Water Reminder
//
//  Created by KEREM BOYLU on 8.05.2025.
//

import SwiftUI
import Charts


struct WeeklyChartView: View {

    @Binding var HydrationData: [HydrationEntry]
    @State private var selectedWeek: DateInterval = Calendar.current.dateInterval(of: .weekOfYear,for: Date())!
    @State private var selectedDay: Date? = nil
    
    struct ViewDay: Identifiable {
        let id = UUID()
        let date: Date
        let totalsByType: [HydrationType: Int]
    }
    
    var selectedViewDay: ViewDay? {
        guard let selectedDay else { return nil }
        return viewDays.first { $0.date == selectedDay }
    }
    
    var viewDays: [ViewDay] {
        generateWeeklyTotals(from: HydrationData, for: selectedWeek)
    }
    
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
                    
                    Text("\(calculateAvarage(for: selectedWeek, using:HydrationData)) ml")
                        .font(.title)
                        .bold()
                }
            }
            
            hydrationWeeklyChart(viewDays)
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
    func hydrationWeeklyChart(_ viewDays: [ViewDay]) -> some View {
        Chart {
            if let selected = selectedDay,
               let viewDay = viewDays.first(where: { Calendar.current.isDate($0.date, inSameDayAs: selected) }),
               viewDay.totalsByType.values.reduce(0, +) > 0 {
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
                            Text("\(viewDay.totalsByType.values.reduce(0, +)) ml")
                                .font(.title3)
                                .bold()
                            Text(viewDay.date.formattedDate(format: "d MMM yyyy"))
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

            ForEach(viewDays) { viewDay in
                ForEach(viewDay.totalsByType.sorted(by: { $0.key.stackPriority < $1.key.stackPriority }), id: \.key) { type, total in
                    BarMark(
                        x: .value("Day", viewDay.date, unit: .day),
                        y: .value("Amount", total),
                        stacking: .standard
                    )
                    .foregroundStyle(type.color)
                    .opacity(selectedDay == nil || Calendar.current.isDate(selectedDay!, inSameDayAs: viewDay.date) ? 1 : 0.3)
                }
            }
        }
        .chartXSelection(value: $selectedDay)
        .chartXScale(domain: selectedWeek.start...selectedWeek.end - 1)
        .chartXScale(range: .plotDimension(padding: 16))
        .chartXAxis {
            AxisMarks(values: viewDays.map { $0.date }) { date in
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
        
        let usedTypes = Set(viewDays.flatMap { $0.totalsByType.keys })
        
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

    func generateWeeklyTotals(from data: [HydrationEntry], for week: DateInterval, calendar: Calendar = Calendar.current) -> [ViewDay] {
        let weekStart = calendar.startOfDay(for: week.start)

        return (0..<7).compactMap { offset in
            guard let date = calendar.date(byAdding: .day, value: offset, to: weekStart) else {
                return nil
            }
            let entriesForDay = data.filter { calendar.isDate($0.date, inSameDayAs: date) }
            let totalsByType = Dictionary(grouping: entriesForDay, by: { $0.type })
                .mapValues { $0.reduce(0) { $0 + $1.amount } }
            return ViewDay(date: date, totalsByType: totalsByType)
        }
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
    
    func calculateAvarage(for selectedWeek: DateInterval, using data: [HydrationEntry]) -> String {
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
    WeeklyChartView(HydrationData: .constant(HydrationEntry.MOCK_DATA))
}
