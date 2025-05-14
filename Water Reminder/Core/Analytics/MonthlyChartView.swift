//
//  MonthlyChartView.swift
//  Water Reminder
//
//  Created by KEREM BOYLU on 4.05.2025.
//

import SwiftUI
import Charts


struct MonthlyChartView: View {
    let data = WaterData.MOCK_WATER_DATA

    @State private var selectedMonth: DateInterval = Calendar.current.dateInterval(
        of: .month,
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
        generateMonthlyTotals(from: data, for: selectedMonth)
    }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(Color(.systemGray5))

            HStack {
                Button(
action: {
    let prevMonth = Calendar.current.date(
        byAdding: .month,
        value: -1,
        to: selectedMonth.start
    )!
    selectedMonth = Calendar.current
        .dateInterval(of: .month, for: prevMonth) ?? selectedMonth
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
                            from: selectedMonth.start,
                            to: selectedMonth.end - 1
                        )
                )
                .font(.subheadline)
                .bold()

                Spacer()
                
                Divider()
                    .frame(width: 1, height: 15)
                    .background(Color.gray.opacity(0.5))

                let today = Calendar.current.startOfDay(for: Date())
                let nextMonth = Calendar.current.date(
                    byAdding: .month,
                    value: 1,
                    to: selectedMonth.start
                )!
                let isFutureMonth = nextMonth > today

                Button(
action: {
                    if !isFutureMonth {
                        selectedMonth = Calendar.current
                            .dateInterval(
                                of: .month,
                                for: nextMonth
                            ) ?? selectedMonth
                    }
}) {
    Image(systemName: "chevron.right")
        .foregroundColor(isFutureMonth ? .gray : .secondary)
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
                if !hasData(in: selectedMonth, data: data){
                    Text(" ")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Text("No Data")
                        .font(.title)
                        .bold()
                    
                } else if selectedDay != nil {
                    Text(" ")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Text(" ")
                        .font(.title)
                        .bold()

                } else {
                    Text("AVERAGE")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Text("\(calculateAverage(viewDays.map { $0.total })) ml")
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
                        .annotation(
                            position: .top,
                            overflowResolution: .init(
                                x: .fit(to: .chart),
                                y: .disabled
                            )
                        ) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("TOTAL")
                                    .font(.caption)
                                    .foregroundColor(.secondary)

                                Text("\(viewDay.total.localizedString()) ml")
                                    .font(.title3)
                                    .bold()

                                Text(
                                    viewDay.date
                                        .formattedDate(format: "d MMM yyyy EEE")
                                )
                                .font(.caption)
                                .foregroundColor(.gray)
                                .bold()
                            }
                            .padding(6)
                            .frame(width: 140)
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
                    BarMark(
                        x: .value("Day", viewDay.date, unit: .day),
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
            .chartXScale(domain: selectedMonth.start...selectedMonth.end - 1)
            .chartXScale(range: .plotDimension(padding: 16))
            .chartXAxis {
                AxisMarks(values: viewDays.map { $0.date }.filter {
                    let day = Calendar.current.component(.day, from: $0)
                    return [1, 8, 15, 22, 29].contains(day)
                }) { value in
                    AxisGridLine()
                    AxisTick()
                    AxisValueLabel {
                        if let date = value.as(Date.self) {
                            Text(date.formattedDate(format: "d"))
                        }
                    }
                }
            }
            .frame(height: 220)
        }
        .padding(.horizontal)
        .padding(.bottom)
        .animation(.easeInOut, value: selectedMonth)

    }
    
    func generateMonthlyTotals(from data: [WaterData], for month: DateInterval, calendar: Calendar = Calendar.current) -> [ViewDay] {
        let monthStart = calendar.startOfDay(for: month.start)
        let range: Range<Int> = calendar.range(of: .day, in: .month, for: monthStart) ?? (
            1..<32
        )

        return range.compactMap { day -> ViewDay? in
            guard let date = calendar.date(bySetting: .day, value: day, of: monthStart) else {
                return nil
            }
            let total = data.filter { calendar.isDate($0.date, inSameDayAs: date) }.reduce(
                0
            ) {
                $0 + $1.amount
            }
            return ViewDay(date: date, total: total)
        }
    }
    
    func hasData(in month: DateInterval, data: [WaterData]) -> Bool {
        let calendar = Calendar.current
        let monthStart = calendar.startOfDay(for: month.start)
        let range = calendar.range(
            of: .day,
            in: .month,
            for: monthStart
        ) ?? 1..<32
        let days = range.compactMap { day -> Date? in
            calendar.date(bySetting: .day, value: day, of: monthStart)
        }

        let total = days.reduce(0) { sum, date in
            sum + data
                .filter { calendar.isDate($0.date, inSameDayAs: date) }
                .reduce(0) { $0 + $1.amount }
        }
        return total > 0
    }
    
    func calculateAverage(_ data: [Int]) -> String {
        guard !data.isEmpty else { return "0" }
        let avg = data.reduce(0, +) / data.count
        return avg.localizedString()
    }
}



#Preview {
    MonthlyChartView()
}
