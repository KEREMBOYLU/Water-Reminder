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
    
    @State private var selectedDay = Calendar.current.startOfDay(for: Date())
    @State private var selectedHour: Int? = nil
    
    struct ViewHour: Identifiable {
        let id = UUID()
        let hour: Int
        let total: Int
    }
    
    var todayData: [WaterData] {
        data
            .filter {
                Calendar.current.isDate($0.date, inSameDayAs: selectedDay)
            }
    }
    
    var hourlyTotals: [ViewHour] {
        Dictionary(
            grouping: todayData,
            by: { Calendar.current.component(.hour, from: $0.date)
            })
        .map { hour, entries in
            ViewHour(hour: hour, total: entries.reduce(0) { $0 + $1.amount })
        }
        .sorted(by: { $0.hour < $1.hour })
    }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(Color(.systemGray5))
            
            HStack {
                Button(
action: {
                    selectedDay = Calendar.current
        .date(
            byAdding: .day,
            value: -1,
            to: selectedDay
        ) ?? selectedDay
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
                
                Text(selectedDay.relativeDayDescription())
                    .font(.subheadline)
                    .bold()
                
                Spacer()
                
                Divider()
                    .frame(width: 1, height: 15)
                    .background(Color.gray.opacity(0.5))
                
                let today = Calendar.current.startOfDay(for: Date())
                let isFutureDay = Calendar.current.isDate(
                    selectedDay,
                    inSameDayAs: today
                ) || selectedDay > today
                
                Button(
action: {
                    if !isFutureDay {
                        selectedDay = Calendar.current
                            .date(
                                byAdding: .day,
                                value: 1,
                                to: selectedDay
                            ) ?? selectedDay
                    }
}) {
    Image(systemName: "chevron.right")
        .foregroundColor(isFutureDay ? .gray : .secondary)
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
        
        VStack(alignment: .leading, spacing: 8){
            VStack(alignment: .leading, spacing: 4) {
                if todayData.isEmpty{
                    
                    Text(" ")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("No Data")
                        .font(.title)
                        .bold()
                    
                } else if selectedHour != nil {
                    Text(" ")
                        .font(.caption)
                    
                    Text(" ")
                        .font(.title)
                        .bold()
                    
                } else {
                    let totalAmount = todayData.reduce(0) { $0 + $1.amount }
                    
                    Text("TOTAL")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("\(totalAmount.localizedString()) ml")
                        .font(.title)
                        .bold()
                    
                }
            }
            .padding(.vertical, 8)
            
            Chart {
                
                if let selectedHour,
                   let entry = hourlyTotals.first(
                    where: { $0.hour == selectedHour
                    }),
                   entry.total > 0 {
                    RuleMark(x: .value("Selected Hour", selectedHour))
                        .foregroundStyle(.secondary)
                        .zIndex(-10)
                        .offset(yStart: -10)
                        .annotation(
                            position: .top,
                            overflowResolution: .init(
                                x: .fit(to: .chart),
                                y: .disabled
                            )
                        ) {
                            let hourDate = Calendar.current.date(
                                bySettingHour: entry.hour,
                                minute: 0,
                                second: 0,
                                of: selectedDay
                            )!
                            let nextHourDate = Calendar.current.date(
                                bySettingHour: (entry.hour + 1) % 24,
                                minute: 0,
                                second: 0,
                                of: selectedDay
                            )!
                            VStack(alignment: .leading, spacing: 4) {
                                Text("TOTAL")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                Text("\(entry.total.localizedString()) ml")
                                    .font(.title3)
                                    .bold()
                                
                                Text(
                                    "\(selectedDay.formattedDate(format: "d MMM EEE")) \(hourDate.formattedDate(format: "HH"))–\(nextHourDate.formattedDate(format: "HH"))"
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
                
                
                ForEach(hourlyTotals) { entry in
                    BarMark(
                        x: .value("hour", entry.hour),
                        y: .value("ml", entry.total)
                    )
                    .foregroundStyle(Color("ChartColor"))
                    .opacity(
                        selectedHour == nil || selectedHour == entry.hour ? 1.0 : 0.3
                    )
                }
            }
            .chartXSelection(value: $selectedHour)
            .chartXAxis {
                AxisMarks(values: [0, 6, 12, 18]) { value in
                    AxisGridLine()
                    AxisTick()
                    AxisValueLabel {
                        if let hour = value.as(Int.self) {
                            let hourDate = Calendar.current.date(
                                bySettingHour: hour,
                                minute: 0,
                                second: 0,
                                of: Date()
                            )!
                            Text(hourDate.formattedDate(format: "HH"))
                                .foregroundColor(.gray)
                                .font(.caption2)
                        }
                    }
                }
            }
            .chartXScale(domain: 0...23)
            .chartXScale(range: .plotDimension(padding: 16))
            .frame(height: 220)
        }
        .padding(.horizontal)
        .padding(.bottom)
        .animation(.easeInOut, value: selectedDay)

        
    }
}

#Preview {
    DailyChartView()
    
}
