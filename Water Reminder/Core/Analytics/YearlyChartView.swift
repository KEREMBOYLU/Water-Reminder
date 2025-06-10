//
//  YearlyChartView.swift
//  Water Reminder
//
//  Created by KEREM BOYLU on 4.05.2025.
//

import SwiftUI
import Charts

struct MonthlyChartData: Identifiable {
    var id: String { "\(month)-\(type.id)" }
    let month: Date
    let type: HydrationType
    let value: Int
}

struct YearlyChartView: View {
    
    @Binding var HydrationData: [HydrationEntry]
    let types: [HydrationType]
    @State private var selectedYear: Date = Calendar.current.date(from: Calendar.current.dateComponents([.year], from: Date()))!
    @State private var selectedMonth: Date? = nil
    @EnvironmentObject var typeManager: HydrationTypeManager
    
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
            
            hydrationYearlyChart(yearlyChartData)
        }
        .padding(.horizontal)
        .animation(.easeInOut, value: selectedYear)
    }
    
    var yearlyChartData: [MonthlyChartData] {
        let calendar = Calendar.current
        let year = calendar.component(.year, from: selectedYear)
        var result: [MonthlyChartData] = []
        
        for month in 1...12 {
            guard let monthDate = calendar.date(from: DateComponents(year: year, month: month)) else { continue }
            
            for type in typeManager.types {
                let total = HydrationData.filter {
                    calendar.component(.year, from: $0.date) == year &&
                    calendar.component(.month, from: $0.date) == month &&
                    $0.typeID == type.id
                }.reduce(0) { $0 + $1.amount }
                
                result.append(MonthlyChartData(month: monthDate, type: type, value: total))
            }
        }
        return result
    }
    
    @ViewBuilder
    func hydrationYearlyChart(_ chartData: [MonthlyChartData]) -> some View {
        Chart {
            // --- Begin Interactive Annotation Section ---
            if let selected = selectedMonth {
                let totalForMonth = chartData
                    .filter { Calendar.current.isDate($0.month, equalTo: selected, toGranularity: .month) }
                    .reduce(0) { $0 + $1.value }

                if totalForMonth > 0 {
                    RuleMark(x: .value("Selected Month", selected, unit: .month))
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
                                Text("\(totalForMonth) ml")
                                    .font(.title3)
                                    .bold()
                                Text(selected.formattedDate(format: "MMM yyyy"))
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
            // --- End Interactive Annotation Section ---

            ForEach(chartData.sorted(by: { $0.type.stackPriority < $1.type.stackPriority })) { data in
                BarMark(
                    x: .value("Month", data.month, unit: .month),
                    y: .value("Amount", data.value),
                    stacking: .standard
                )
                .foregroundStyle(data.type.color)
                .opacity({
                    if let selected = selectedMonth {
                        return Calendar.current.isDate(selected, equalTo: data.month, toGranularity: .month) ? 1 : 0.3
                    } else {
                        return 1
                    }
                }())
            }
        }
        .chartXSelection(value: $selectedMonth)
        .chartXAxis {
            AxisMarks(values: (1...12).compactMap { month in
                Calendar.current.date(from: DateComponents(year: Calendar.current.component(.year, from: selectedYear), month: month))
            }) { value in
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
        
        let usedTypes = Set(chartData.map { $0.type }.filter { type in
            chartData.contains(where: { $0.type == type && $0.value > 0 })
        })
        
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
    YearlyChartView(HydrationData: .constant([]), types: [])
        .environmentObject(HydrationTypeManager())
}
