//
//  DailyChartView.swift
//  Water Reminder
//
//  Created by KEREM BOYLU on 4.05.2025.
//

import SwiftUI
import Charts

struct DailyChartView: View {
    let data: [WaterData]
    @State private var selectedDate = Calendar.current.startOfDay(for: Date())
    var body: some View {
        let calendar = Calendar.current
        let todayData = data.filter { calendar.isDate($0.date, inSameDayAs: selectedDate) }

        let hourlyTotals = Dictionary(grouping: todayData, by: { calendar.component(.hour, from: $0.date) })
            .map { hour, entries in
                (hour: hour, total: entries.reduce(0) { $0 + $1.amount })
            }
            .sorted(by: { $0.hour < $1.hour })

        let rawMax = hourlyTotals.map(\.total).max() ?? 500
        let roundedMax = rawMax > 1000
            ? ((rawMax + 499) / 500) * 500
            : ((rawMax + 249) / 250) * 250

        return VStack(alignment: .leading, spacing: 8){
            if todayData.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Veri Yok")
                        .font(.title)
                        .bold()

                    Text(formattedDate(selectedDate))
                        .foregroundColor(.gray)
                        .font(.subheadline)
                }
                .padding(.horizontal)
                .padding(.bottom, 4)
                .padding(.top)

                Chart {
                    // No data
                }
                .chartXAxis {
                    AxisMarks(values: [0, 6, 12, 18]) { value in
                        AxisGridLine()
                        AxisTick()
                        AxisValueLabel {
                            switch value.as(Int.self) {
                            case 0: Text("ÖÖ 12")
                            case 6: Text("6")
                            case 12: Text("ÖS 12")
                            case 18: Text("6")
                            default: EmptyView()
                            }
                        }
                    }
                }
                .chartXScale(domain: 0...23, range: .plotDimension(padding: 16))
                .chartYScale(domain: 0...500)
                .chartYAxis {
                    AxisMarks(values: [0, 250, 500]) {
                        AxisGridLine()
                        AxisTick()
                        AxisValueLabel()
                    }
                }
                .padding(.top, 8)
                .frame(height: 220)
                .padding(.horizontal)
                .padding(.bottom)
            } else {
                let totalAmount = todayData.reduce(0) { $0 + $1.amount }

                VStack(alignment: .leading, spacing: 4) {
                    Text("TOPLAM")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Text("\(Int(totalAmount)) ml")
                        .font(.title)
                        .bold()

                    Text(formattedDate(selectedDate))
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .padding(.horizontal)
                .padding(.bottom, 4)

                Chart {
                    ForEach(hourlyTotals, id: \.hour) { entry in
                        BarMark(
                            x: .value("Saat", entry.hour),
                            y: .value("mL", entry.total)
                        )
                        .foregroundStyle(.cyan)
                    }
                }
                .chartXAxis {
                    AxisMarks(values: [0, 6, 12, 18]) { value in
                        AxisGridLine()
                        AxisTick()
                        AxisValueLabel {
                            switch value.as(Int.self) {
                            case 0: Text("ÖÖ 12")
                            case 6: Text("6")
                            case 12: Text("ÖS 12")
                            case 18: Text("6")
                            default: EmptyView()
                            }
                        }
                    }
                }
                .chartXScale(domain: 0...23)
                .chartXScale(range: .plotDimension(padding: 16))
                .chartYScale(domain: 0...roundedMax)
                .chartYAxis {
                    AxisMarks(values: stride(from: 0, through: roundedMax, by: rawMax > 1000 ? 500 : 250).map { $0 }) {
                        AxisGridLine()
                        AxisTick()
                        AxisValueLabel()
                    }
                }
                .padding(.top, 8)
                .frame(height: 220)
                .padding(.horizontal)
                .padding(.bottom)
            }
        }
        .animation(.easeInOut, value: selectedDate)
        .gesture(
            DragGesture()
                .onEnded { value in
                    if value.translation.width > 50 {
                        // sağa kaydır → geçmiş güne git
                        if let newDate = calendar.date(byAdding: .day, value: -1, to: selectedDate) {
                            withAnimation(.easeInOut) {
                                selectedDate = newDate
                            }
                        }
                    } else if value.translation.width < -50 {
                        // sola kaydır → ileriye git (bugüne kadar)
                        if let newDate = calendar.date(byAdding: .day, value: 1, to: selectedDate),
                           newDate <= Calendar.current.startOfDay(for: Date()) {
                            withAnimation(.easeInOut) {
                                selectedDate = newDate
                            }
                        }
                    }
                })
    }
    

    func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateFormat = "d MMMM yyyy EEE"
        return formatter.string(from: date)
    }
}

#Preview {
    DailyChartView(data: WaterData.MOCK_WATER_DATA)

}
