//
//  YearlyChartView.swift
//  Water Reminder
//
//  Created by KEREM BOYLU on 4.05.2025.
//

import SwiftUI
import Charts

struct YearlyChartView: View {
    
    @Binding var HydrationData: [HydrationEntry]
    @State private var selectedYear: Date = Calendar.current.date(from: Calendar.current.dateComponents([.year], from: Date()))!
    @State private var selectedMonth: Date? = nil
    
    struct ViewMonth: Identifiable {
        let id = UUID()
        let date: Date
        let totalsByType: [HydrationType: Int]
    }
    
    var selectedViewMonth: ViewMonth? {
        guard let selectedMonth else { return nil }
        return viewMonths.first {
            Calendar.current.isDate(selectedMonth, equalTo:$0.date, toGranularity:.month)
        }
    }
    
    var viewMonths: [ViewMonth] {
        generateYearlyTotals(from: HydrationData, for: selectedYear)
    }
    
    var body: some View {

        VStack(alignment: .leading, spacing: 12) {
            yearSwitcherBar()
                .padding(.bottom)
            
            VStack(alignment: .leading, spacing: 4) {
                if !hasData(in: selectedYear, data: HydrationData) {
                    Text("DAILY AVERAGE")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .hidden()

                    Text("No Data")
                        .font(.title)
                        .bold()
                    
                } else if  selectedMonth != nil {
                    Text("DAILY AVERAGE")
                        .font(.caption)
                        .hidden()

                    Text("ml")
                        .font(.title)
                        .bold()
                        .hidden()
                } else {
                    Text("DAILY AVERAGE")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Text(
                        "\(calculateDailyAverage(from: HydrationData, for: selectedYear, granularity: .year)) ml"
                    )
                    .font(.title)
                    .bold()
                }
            }
            
            hydrationYearlyChart(viewMonths)
        }
        .padding(.horizontal)
        .animation(.easeInOut, value: selectedYear)
    }
    
    @ViewBuilder
    func hydrationYearlyChart(_ viewMonths: [ViewMonth]) -> some View {
        Chart {
            if let selected = selectedMonth,
               let viewMonth = viewMonths.first(where: {
                   Calendar.current.isDate(selected, equalTo: $0.date, toGranularity: .month )}),
               viewMonth.totalsByType.values.reduce(0, +) > 0 {
                let aligned = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: selected))!
                RuleMark(x: .value("Selected Month", aligned, unit: .month))
                    .zIndex(-10)
                    .offset(yStart: -10)
                    .foregroundStyle(Color("WaterColor"))
                    .annotation(position: .top,
                                spacing: 0,
                                overflowResolution: .init(x: .fit(to: .chart), y: .disabled)) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("DAILY AVARAGE")
                                .font(.caption)
                                .foregroundColor(.secondary)

                            Text("\(calculateDailyAverage(from: HydrationData, for: selected, granularity: .month)) ml")
                            .font(.title3)
                            .bold()

                            Text(viewMonth.date.formattedDate(format: "MMM yyyy"))
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
            
            ForEach(viewMonths) { viewMonth in
                ForEach(viewMonth.totalsByType.sorted(by: { $0.key.stackPriority < $1.key.stackPriority}), id: \.key) { type, total in
                    BarMark(
                        x: .value("Month", viewMonth.date, unit: .month),
                        y: .value("Amount", total),
                        stacking: .standard
                    )
                    .foregroundStyle(type.color)
                    .opacity({
                        if let selected = selectedMonth {
                            return Calendar.current.isDate(selected, equalTo: viewMonth.date, toGranularity: .month) ? 1 : 0.3
                        } else {
                            return 1
                        }
                    }())
                }
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
        .frame(height: 240)
        
        let usedTypes = Set(viewMonths.flatMap{ $0.totalsByType.keys })
        
        HStack(spacing: 16) {
            if !usedTypes.isEmpty && hasData(in: selectedYear, data: HydrationData){
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
     
    @ViewBuilder
    func yearSwitcherBar() -> some View {
        HStack{
            
            Button(action: {
                if let prevYear = Calendar.current.date(
                    byAdding: .year,
                    value: -1,
                    to: selectedYear) {
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
        .frame(height: 30)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(.systemGray5))
    )}

    func generateYearlyTotals(from data: [HydrationEntry], for year: Date, calendar: Calendar = Calendar.current) -> [ViewMonth] {
        let startOfYear = calendar.date(from: calendar.dateComponents([.year], from: year))!

        return (1...12).compactMap { month in
            guard let date = calendar.date(from: DateComponents(year: calendar.component(.year, from: startOfYear), month: month, day: 1)) else {
            return nil
        }
            
            let entriesForMonth = data.filter {
                calendar.component(.year, from: $0.date) == calendar.component(.year, from: date) &&
                calendar.component(.month, from: $0.date) == month
            }

            let totalsByType: [HydrationType: Int]
            if entriesForMonth.isEmpty {
                totalsByType = [HydrationType.water: 0]
            } else {
                totalsByType = Dictionary(grouping: entriesForMonth, by: { $0.type })
                    .mapValues { $0.reduce(0) { $0 + $1.amount } }
            }

            return ViewMonth(date: date, totalsByType: totalsByType)
        }
    }

    func calculateAverage(_ data: [Int]) -> String {
        guard !data.isEmpty else { return "0" }
        let avg = data.reduce(0, +) / data.count
        return avg.localizedString()
    }
    
    func calculateDailyAverage(from data: [HydrationEntry], for date: Date, granularity: Calendar.Component) -> String {
        let calendar = Calendar.current
        let filteredData: [HydrationEntry]
        
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
        let sum = dailyTotals.values.reduce(0, +)
        let avg = sum / dailyTotals.count
        return avg.localizedString()
    }
    
    func hasData(in year: Date, data: [HydrationEntry]) -> Bool {
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
    YearlyChartView(HydrationData: .constant(HydrationEntry.MOCK_DATA))
}
