//
//  AnalyticsView.swift
//  Water Reminder
//
//  Created by KEREM BOYLU on 4.05.2025.
//

import SwiftUI

struct AnalyticsView: View {
    @Binding var waterData: [WaterData]
    @State private var selectedRange = "Gün"
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                
                // Segmented control
                let options = ["Gün", "Hafta", "Ay", "Yıl"]
                let selectedIndex = options.firstIndex(of: selectedRange) ?? 0
                
                GeometryReader { geo in
                    let buttonWidth = geo.size.width / CGFloat(options.count)
                    
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(Color(.systemGray5))
                        
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(Color("ButtonColor"))
                            .frame(width: buttonWidth, height: 40)
                            .offset(x: CGFloat(selectedIndex) * buttonWidth)
                            .animation(.easeInOut, value: selectedIndex)
                        
                        HStack(spacing: 0) {
                            ForEach(options.indices, id: \.self) { index in
                                let label = options[index]
                                let nextLabel = options[safe: index + 1] ?? ""
                                Button(action: {
                                    withAnimation(.easeInOut) {
                                        selectedRange = label
                                    }
                                }) {
                                    Text(label)
                                        .font(.system(size: 16, weight: selectedRange == label ? .bold : .semibold))
                                        .frame(width: buttonWidth, height: 40)
                                        .foregroundColor(selectedRange == label ? .white : .primary)
                                }
                                if index < options.count - 1 {
                                    if selectedRange != label && selectedRange != nextLabel {
                                        Divider()
                                            .frame(width: 1, height: 20)
                                            .background(Color.gray.opacity(0.5))
                                        
                                    }
                                    
                                }
                            }
                        }
                    }
                    .frame(height: 40)
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                }
                .frame(height: 40)
                .padding(.horizontal)
                
                // Daily chart view placeholder
                if selectedRange == "Gün" {
                    DailyChartView(data: $waterData)
                }
                if selectedRange == "Hafta" {
                    WeeklyChartView(data: $waterData)
                }
                if selectedRange == "Ay" {
                    MonthlyChartView(data: $waterData)
                }
                if selectedRange == "Yıl" {
                    YearlyChartView(data: $waterData)
                }
                
                Spacer()
            }
            .navigationTitle("Analytics")
        }
    }
}

#Preview {
    AnalyticsView(waterData: .constant(WaterData.MOCK_WATER_DATA))
}
