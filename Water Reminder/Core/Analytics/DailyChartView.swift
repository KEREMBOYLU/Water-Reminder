//
//  DailyChartView.swift
//  Water Reminder
//
//  Created by KEREM BOYLU on 4.05.2025.
//

import SwiftUI
import Charts

struct DailyChartView: View {
    let data = WaterData.MOCK_WATER_DATA
    @State private var selectedDate = Calendar.current.startOfDay(for: Date())
    var body: some View {
        let calendar = Calendar.current
        let todayData = data.filter { calendar.isDate($0.date, inSameDayAs: selectedDate) }

        let hourlyTotals = Dictionary(grouping: todayData, by: { calendar.component(.hour, from: $0.date) })
            .map { hour, entries in
                (hour: hour, total: entries.reduce(0) { $0 + $1.amount })
            }
            .sorted(by: { $0.hour < $1.hour })

        return VStack(alignment: .leading, spacing: 8){
            VStack(alignment: .leading, spacing: 4) {
                if todayData.isEmpty{
                
                    Text("No Data")
                        .font(.title)
                        .bold()
                        .padding(.top)

                    Text(formattedDate(selectedDate))
                        .foregroundColor(.gray)
                        .font(.subheadline)
    
                }else {
                    let totalAmount = todayData.reduce(0) { $0 + $1.amount }
                    
                    Text("TOTAL")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Text("\(Int(totalAmount)) ml")
                        .font(.title)
                        .bold()

                    Text(formattedDate(selectedDate))
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                }
            }
            .padding(.bottom, 4)
            
            Chart {
                ForEach(hourlyTotals, id: \.hour) { entry in
                    BarMark(
                        x: .value("hour", entry.hour),
                        y: .value("ml", entry.total)
                    )
                    .foregroundStyle(.cyan)
                }
            }
            .chartXAxis {
                AxisMarks(values: [0, 6, 12, 18]) { value in
                    AxisGridLine()
                    AxisTick()
                    AxisValueLabel {
                        if let hour = value.as(Int.self) {
                            Text(formattedHour(hour))
                                .foregroundColor(.gray)
                                .font(.caption2)
                        }
                    }
                }
            }
            .chartXScale(domain: 0...23)
            .chartXScale(range: .plotDimension(padding: 16))
            .padding(.top, 8)
            .frame(height: 220)
        }
        .padding(.horizontal)
        .padding(.bottom)
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
                }
        )
    }

    func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        let preferred = Locale.preferredLanguages.first ?? "en"
        formatter.locale = Locale(identifier: preferred)
        formatter.dateFormat = "d MMMM yyyy EEE"
        return formatter.string(from: date)
    }
    
    func formattedHour(_ hour: Int) -> String {
        let date = Calendar.current.date(bySettingHour: hour, minute: 0, second: 0, of: Date())!
        let formatter = DateFormatter()
        let preferred = Locale.preferredLanguages.first ?? "en"
        formatter.locale = Locale(identifier: preferred)
        formatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "j", options: 0, locale: formatter.locale)
        return formatter.string(from: date)
    }
}

#Preview {
    DailyChartView()

}
