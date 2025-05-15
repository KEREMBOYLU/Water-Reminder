//
//  weeklytestUIView.swift
//  Water Reminder
//
//  Created by KEREM BOYLU on 8.05.2025.
//

import SwiftUI
import Charts


struct WeeklyChartView: View {

    @Binding var data: [WaterData]

    @State private var selectedWeek: DateInterval = Calendar.current.dateInterval(
        of: .weekOfYear,
        for: Date()
    )!
    @State private var selectedDay: Date? = nil
    
    struct ViewDay: Identifiable {
        let id = UUID()
        let date: Date
        let total: Int
    }
    
    var selectedViewDay: ViewDay? {
        guard let selectedDay else { return nil }
        return viewDays.first { $0.date == selectedDay }
    }
    
    var viewDays: [ViewDay] {
        generateWeeklyTotals(from: data, for: selectedWeek)
    }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(Color(.systemGray5))

            HStack {
                Button(
action: {
    let prevWeek = Calendar.current.date(
        byAdding: .weekOfYear,
        value: -1,
        to: selectedWeek.start
    )!
    selectedWeek = Calendar.current
        .dateInterval(of: .weekOfYear, for: prevWeek) ?? selectedWeek
}) {
    Image(systemName: "chevron.left")
        .foregroundColor(.secondary)
        .font(.title3)
        .padding()
}
                
                Divider()
                    .frame(width: 1, height: 15)
                    .background(Color.gray.opacity(0.5))

                Spacer()

                Text(
                    Date
                        .formattedRange(
                            from: selectedWeek.start,
                            to: selectedWeek.end - 1
                        )
                )
                .font(.subheadline)
                .bold()

                Spacer()
                
                Divider()
                    .frame(width: 1, height: 15)
                    .background(Color.gray.opacity(0.5))

                let today = Calendar.current.startOfDay(for: Date())
                let nextWeek = Calendar.current.date(
                    byAdding: .weekOfYear,
                    value: 1,
                    to: selectedWeek.start
                )!
                let isFutureWeek = nextWeek > today

                Button(
action: {
                    if !isFutureWeek {
                        selectedWeek = Calendar.current
                            .dateInterval(
                                of: .weekOfYear,
                                for: nextWeek
                            ) ?? selectedWeek
                    }
}) {
    Image(systemName: "chevron.right")
        .foregroundColor(isFutureWeek ? .gray : .secondary)
        .font(.title3)
        .padding()
}
            }
            .padding(.vertical, 2)
            .padding(.horizontal, 8)
        }
        .frame(height: 30)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .padding(.horizontal)

        VStack(alignment: .leading, spacing: 8) {
            VStack(alignment: .leading, spacing: 4) {
                if !hasData(in: selectedWeek, data: data){
                    Text(" ")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Text("No Data")
                        .font(.title)
                        .bold()
                    
                } else if selectedDay != nil {
                    Text(" ")
                        .font(.caption)
                    
                    Text(" ")
                        .font(.title)
                        .bold()
                }
                else {
                    Text("AVERAGE")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Text("\(calculateAvarage(viewDays.map { $0.total })) ml")
                        .font(.title)
                        .bold()
                }
            }
            .padding(.vertical, 8)
            
            Chart {
                if let selected = selectedDay,
                   let viewDay = viewDays.first(
                    where: { Calendar.current.isDate(
                        $0.date,
                        inSameDayAs: selected
                    )
                    }),
                   viewDay.total > 0 {
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

                                Text("\(viewDay.total) ml")
                                    .font(.title3)
                                    .bold()

                                Text(
                                    viewDay.date
                                        .formattedDate(format: "d MMM yyyy")
                                )
                                .font(.caption)
                                .foregroundColor(.gray)
                                .bold()
                            }
                            .padding(6)
                            .frame(width: 120)
                            .background {
                                RoundedRectangle(
                                    cornerRadius: 12,
                                    style: .continuous
                                )
                                .fill(Color(.systemGray5))
                            }
                        }
                }
                
                ForEach(viewDays) { viewDay in
                    BarMark(x: .value("Day", viewDay.date, unit: .day),
                            y: .value("Total", viewDay.total)
                    )
                    .foregroundStyle(Color("ChartColor"))
                    .opacity(
                        selectedDay == nil || Calendar.current
                            .isDate(
                                selectedDay!,
                                inSameDayAs: viewDay.date
                            ) ? 1 : 0.3
                    )
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
                        }
                    }
                }
            }
            .frame(height: 220)
        }
        .padding(.horizontal)
        .padding(.bottom)
        .animation(.easeInOut, value: selectedWeek)
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
    
    func calculateAvarage(_ data: [Int]) -> String {
        guard !data.isEmpty else {return "0"}
        let total = data.reduce(0, +)
        let avg = total / data.count
        return avg.localizedString()
    }
}

#Preview {
    WeeklyChartView(data: .constant(WaterData.MOCK_WATER_DATA))
}
