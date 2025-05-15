//
//  YearlyChartView.swift
//  Water Reminder
//
//  Created by KEREM BOYLU on 4.05.2025.
//

import SwiftUI
import Charts

struct YearlyChartView: View {
    
    @Binding var data: [WaterData]
    
    @State private var selectedYear: Date = Calendar.current.date(
        from: Calendar.current.dateComponents([.year], from: Date())
    )!
    
    @State private var selectedMonth: Date? = nil
    
    struct ViewMonth: Identifiable {
        let id = UUID()
        let date: Date
        let total: Int
    }
    
    var selectedViewMonth: ViewMonth? {
        guard let selectedMonth else { return nil }
        return viewMonths.first {
            Calendar.current
                .isDate(selectedMonth, equalTo:$0.date, toGranularity:.month)
        }
    }
    
    var viewMonths: [ViewMonth] {
        generateYearlyTotals(from: data, for: selectedYear)
    }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(Color(.systemGray5))

            HStack {
                Button(
action: {
    if let prevYear = Calendar.current.date(
        byAdding: .year,
        value: -1,
        to: selectedYear
    ) {
        selectedYear = prevYear
    }
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

                Text(selectedYear.formattedDate(format: "yyyy"))
                    .font(.subheadline)
                    .bold()

                Spacer()

                Divider()
                    .frame(width: 1, height: 15)
                    .background(Color.gray.opacity(0.5))

                let nextYear = Calendar.current.date(
                    byAdding: .year,
                    value: 1,
                    to: selectedYear
                )!
                let isFuture = nextYear > Date()

                Button(action: {
                    if !isFuture {
                        selectedYear = nextYear
                    }
                }) {
                    Image(systemName: "chevron.right")
                        .foregroundColor(isFuture ? .gray : .secondary)
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
                if !hasData(in: selectedYear, data: data) {
                    Text(" ")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Text("No Data")
                        .font(.title)
                        .bold()
                } else if let selected = selectedMonth,
                          let viewMonth = viewMonths.first(
                            where: { Calendar.current.isDate(
                                selected,
                                equalTo: $0.date,
                                toGranularity: .month
                            )
                            }) {
                    Text(" ")
                        .font(.caption)

                    Text(" ")
                        .font(.title)
                        .bold()
                } else {
                    Text("DAILY AVERAGE")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Text(
                        "\(calculateDailyAverage(from: data, for: selectedYear, granularity: .year)) ml"
                    )
                    .font(.title)
                    .bold()
                }
            }
            .padding(.vertical, 8)

            Chart {
                if let selected = selectedMonth,
                   let viewMonth = viewMonths.first(
where:{
                       Calendar.current
        .isDate(
            selected,
            equalTo:$0.date,
            toGranularity:.month
        )
}),
                   viewMonth.total > 0{
                    RuleMark(
                        x: .value("Selected Month", selected, unit: .month)
                    )
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
                            Text("DAILY AVARAGE")
                                .font(.caption)
                                .foregroundColor(.secondary)

                            Text(
                                "\(calculateDailyAverage(from: data, for: selected, granularity: .month)) ml"
                            )
                            .font(.title3)
                            .bold()

                            Text(viewMonth.date.formattedDate(format: "MMM"))
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
                ForEach(viewMonths) { viewMonth in
                    BarMark(
                        x: .value("Month", viewMonth.date, unit: .month),
                        y: .value("Total", viewMonth.total)
                    )
                    .foregroundStyle(Color("ChartColor"))
                    .opacity(
                        selectedMonth == nil || Calendar.current
                            .isDate(
                                selectedMonth!,
                                inSameDayAs: viewMonth.date
                            ) ? 1 : 0.3
                    )
                }
            }
            .chartXSelection(value: $selectedMonth)
            .chartXAxis {
                AxisMarks(values: viewMonths.map { $0.date }) { value in
                    AxisGridLine()
                    AxisTick()
                    AxisValueLabel {
                        if let date = value.as(Date.self) {
                            Text(date.formattedDate(format: "MMM"))
                        }
                    }
                }
            }
            .frame(height: 220)
        }
        .padding(.horizontal)
        .padding(.bottom)
        .animation(.easeInOut, value: selectedYear)
    }

    func generateYearlyTotals(from data: [WaterData], for year: Date, calendar: Calendar = Calendar.current) -> [ViewMonth] {
        let startOfYear = calendar.date(
            from: calendar.dateComponents([.year], from: year)
        )!
        return (1...12).compactMap { month in
            guard let date = calendar.date(from: DateComponents(year: calendar.component(.year, from: startOfYear), month: month, day: 1)) else {
                return nil
            }
            let total = data.filter {
                calendar
                    .component(.year, from: $0.date) == calendar
                    .component(.year, from: date) && calendar
                    .component(.month, from: $0.date) == month
            }
                .reduce(0) { $0 + $1.amount }
            return ViewMonth(date: date, total: total)
        }
    }

    func calculateAverage(_ data: [Int]) -> String {
        guard !data.isEmpty else { return "0" }
        let avg = data.reduce(0, +) / data.count
        return avg.localizedString()
    }
    
    func calculateDailyAverage(from data: [WaterData], for date: Date, granularity: Calendar.Component) -> String {
        let calendar = Calendar.current
        let filteredData: [WaterData]
        
        switch granularity {
        case .year:
            let year = calendar.component(.year, from: date)
            filteredData = data.filter {
                calendar.component(.year, from: $0.date) == year
            }
        case .month:
            let year = calendar.component(.year, from: date)
            let month = calendar.component(.month, from: date)
            filteredData = data.filter {
                calendar.component(.year, from: $0.date) == year &&
                calendar.component(.month, from: $0.date) == month
            }
        default:
            return "0"
        }
        
        let groupedByDay = Dictionary(
            grouping: filteredData,
            by: { calendar.startOfDay(for: $0.date)
            })
        let dailyTotals = groupedByDay.mapValues { entries in
            entries.reduce(0) { $0 + $1.amount }
        }
        
        guard !dailyTotals.isEmpty else { return "0" }
        
        let total = dailyTotals.values.reduce(0, +)
        let avg = total / dailyTotals.count
        return avg.localizedString()
    }
    
    func hasData(in year: Date, data: [WaterData]) -> Bool {
        let calendar = Calendar.current
        let yearData = data.filter {
            calendar
                .component(.year, from: $0.date) == calendar
                .component(.year, from: year)
        }
        let total = yearData.reduce(0) { $0 + $1.amount }
        return total > 0
    }
}

#Preview {
    YearlyChartView(data: .constant(WaterData.MOCK_WATER_DATA))
}
