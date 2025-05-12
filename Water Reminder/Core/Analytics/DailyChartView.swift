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
    @State private var selectedHour: Int? = nil
    
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
                    
                    Text("")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("No Data")
                        .font(.title)
                        .bold()
                    
                    Text(selectedDate.formattedDate(format: "default"))
                        .foregroundColor(.gray)
                        .font(.subheadline)
                        .bold()
                    
                } else if selectedHour != nil {
                    Text(" ")
                        .font(.caption)
                    
                    Text(" ")
                        .font(.title)
                        .bold()
                    Text(" ")
                        .font(.subheadline)
                } else {
                    let totalAmount = todayData.reduce(0) { $0 + $1.amount }
                    
                    Text("TOTAL")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("\(totalAmount.localizedString()) ml")
                        .font(.title)
                        .bold()
                    
                    Text(selectedDate.formattedDate(format: "default"))
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .bold()
                    
                }
            }
            .padding(.bottom, 4)
            
            Chart {
                
                if let selectedHour {
                    RuleMark(x: .value("Selected Hour", selectedHour))
                        .foregroundStyle(.secondary)
                        .annotation(position: .top, overflowResolution: .init(x: .fit(to: .chart), y: .disabled)) {
                            if let entry = hourlyTotals.first(where: { $0.hour == selectedHour }) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("TOTAL")
                                        .font(.caption)
                                        .foregroundColor(.secondary)

                                    Text("\(entry.total.localizedString()) ml")
                                        .font(.title3)
                                        .bold()

                                    Text("\(selectedDate.formattedDate(format: "noYear")) \(formattedHourRange(for: entry.hour))")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                        .bold()
                                }
                                .padding(6)
                                .cornerRadius(8)
                                .frame(width: 120)
                        
                            }
                        }
                }
                
                
                ForEach(hourlyTotals, id: \.hour) { entry in
                    BarMark(
                        x: .value("hour", entry.hour),
                        y: .value("ml", entry.total)
                    )
                    .foregroundStyle(Color("ChartColor"))
                    .opacity(selectedHour == nil || selectedHour == entry.hour ? 1.0 : 0.3)
                }
            }
            .chartXSelection(value: $selectedHour)
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
                                selectedHour = nil
                            }
                        }
                    } else if value.translation.width < -50 {
                        // sola kaydır → ileriye git (bugüne kadar)
                        if let newDate = calendar.date(byAdding: .day, value: 1, to: selectedDate),
                           newDate <= Calendar.current.startOfDay(for: Date()) {
                            withAnimation(.easeInOut) {
                                selectedDate = newDate
                                selectedHour = nil
                            }
                        }
                    }
                }
        )
    }
    
    func formattedHour(_ hour: Int) -> String {
        let date = Calendar.current.date(bySettingHour: hour, minute: 0, second: 0, of: Date())!
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: preferred)
        formatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "j", options: 0, locale: formatter.locale)
        return formatter.string(from: date)
    }
    
    func formattedHourRange(for hour: Int) -> String {
        let start = formattedHour(hour)
        let end = formattedHour((hour + 1) % 24)
        return "\(start)–\(end)"
    }
}

#Preview {
    DailyChartView()
    
}
