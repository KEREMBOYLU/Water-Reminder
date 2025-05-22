import SwiftUI
import Charts

struct DailyChartView: View {
    @State var data: [HydrationEntry] = HydrationEntry.MOCK_DATA
    @State private var selectedDay = Calendar.current.startOfDay(for: Date())
    @State private var selectedHour: Int? = nil

    struct HourlyLiquidTotal: Identifiable {
        var id: String { "\(hour)-\(type.id)" }
        let hour: Int
        let type: HydrationType
        let total: Int
    }

    var todayEntries: [HydrationEntry] {
        data.filter { Calendar.current.isDate($0.date, inSameDayAs: selectedDay) }
    }

    var hourlyTotals: [HourlyLiquidTotal] {
        let groupedByHour = Dictionary(grouping: todayEntries) {
            Calendar.current.component(.hour, from: $0.date)
        }

        return groupedByHour.flatMap { hour, entriesInHour in
            Dictionary(grouping: entriesInHour, by: \.type).map { type, sameTypeEntries in
                HourlyLiquidTotal(
                    hour: hour,
                    type: type,
                    total: sameTypeEntries.reduce(0) { $0 + $1.amount }
                )
            }
        }
        .sorted(by: { $0.hour < $1.hour })
    }
    
    @ViewBuilder
    func daySwitcherBar() -> some View {
        HStack {
            Button(action: {
                selectedDay = Calendar.current.date(byAdding: .day, value: -1, to: selectedDay) ?? selectedDay
                print("Entries for \(selectedDay.formattedDate()):", todayEntries)
            }) {
                Image(systemName: "chevron.left")
                    .foregroundColor(.secondary)
                    .padding()
            }
            
            Divider()
                .frame(width: 1, height: 15)
                .background(Color.gray.opacity(0.5))
            Spacer()

            Text(selectedDay.relativeDayDescription())
                .bold()
                .font(.subheadline)

            Spacer()
            Divider()
                .frame(width: 1, height: 15)
                .background(Color.gray.opacity(0.5))

            let today = Calendar.current.startOfDay(for: Date())
            let isFutureDay = selectedDay >= today

            Button(action: {
                if !isFutureDay {
                    selectedDay = Calendar.current.date(byAdding: .day, value: 1, to: selectedDay) ?? selectedDay
                    print("Entries for \(selectedDay.formattedDate()):", todayEntries)
                }
            }) {
                Image(systemName: "chevron.right")
                    .foregroundColor(isFutureDay ? .gray : .secondary)
                    .padding()
            }
        }
        .padding(.horizontal)
        .frame(height: 30)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(.systemGray5))
        )
        .padding(.horizontal)
    }

    @ViewBuilder
    func hydrationStackedChart(_ data: [HourlyLiquidTotal]) -> some View {
        let sortedData = data.sorted {
            if $0.hour == $1.hour {
                return $0.type.stackPriority < $1.type.stackPriority
            } else {
                return $0.hour < $1.hour
            }
        }

        Chart {
            ForEach(sortedData) { item in
                BarMark(
                    x: .value("Hour", item.hour),
                    y: .value("Amount", item.total)
                )
                .foregroundStyle(item.type.color)
                .position(by: .value("Type", item.type.id))
                .opacity(selectedHour == nil || selectedHour == item.hour ? 1.0 : 0.3)
            }

            if let selected = selectedHour,
               sortedData.contains(where: { $0.hour == selected }) {
                let totalForHour = sortedData
                    .filter { $0.hour == selected }
                    .map { $0.total }
                    .reduce(0, +)

                RuleMark(x: .value("Selected Hour", selected))
                    .foregroundStyle(.secondary)
                    .zIndex(-1)
                    .offset(yStart: -10)
                    .annotation(
                        position: .top,
                        overflowResolution: .init(
                            x: .fit(to: .chart),
                            y: .disabled
                        )
                    ) {
                        VStack(spacing: 4) {
                            Text("TOTAL")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text("\(totalForHour) ml")
                                .font(.title3)
                                .bold()
                            
                            let hourDate = Calendar.current.date(bySettingHour: selected, minute: 0, second: 0, of: selectedDay)!
                            let nextHourDate = Calendar.current.date(bySettingHour: selected+1, minute: 0, second: 0, of: selectedDay)!
                            
                            Text("\(selectedDay.formattedDate(format: "d MMM EEE")) \(hourDate.formattedDate(format: "HH"))–\(nextHourDate.formattedDate(format: "HH"))")
                                .font(.caption2)
                                .foregroundColor(.gray)
                        }
                        .padding(6)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color(.systemGray6))
                        )
                    }
            }
        }
        .chartXSelection(value: $selectedHour)
        .chartXScale(domain: 0...23)
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
        .frame(height: 220)
        .padding(.horizontal)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Gün değiştirme barı
            daySwitcherBar()

            // Toplam miktar
            VStack(alignment: .leading, spacing: 4) {
                if todayEntries.isEmpty {
                    
                    Text(" ")
                        .font(.title2)
                        .bold()
                    
                    Text("No Data")
                        .font(.title)
                        .bold()
                    
                } else if selectedHour != nil {
                    Text(" ")
                        .font(.title2)
                    
                    Text(" ")
                        .font(.title)
                        .bold()
                    
                } else {
                    let totalAmount = todayEntries.reduce(0) { $0 + $1.amount }
                    
                    Text("TOTAL")
                        .font(.title2)
                    
                    Text("\(totalAmount) ml")
                        .font(.title)
                        .bold()
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)

            // Grafik
            hydrationStackedChart(hourlyTotals)
        }
        .padding(.top)
        .animation(.easeInOut, value: selectedDay)
    }
}

#Preview {
    DailyChartView()
}
