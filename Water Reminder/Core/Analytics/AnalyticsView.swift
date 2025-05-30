//
//  AnalyticsView.swift
//  Water Reminder
//
//  Created by KEREM BOYLU on 4.05.2025.
//

import SwiftUI

struct AnalyticsView: View {
    @Binding var HydrationData: [HydrationEntry]
    @State private var selectedRange = "D"
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                
                // Segmented control
                let options = ["D", "W", "M", "Y"]
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
                
                if selectedRange == "D" {
                    DailyChartView(HydrationData: $HydrationData)
                }
                if selectedRange == "W" {
                    WeeklyChartView(HydrationData: $HydrationData)
                }
                if selectedRange == "M" {
                    MonthlyChartView(HydrationData: $HydrationData)
                }
                if selectedRange == "Y" {
                    YearlyChartView(HydrationData: $HydrationData)
                }
                
                Spacer()
            }
            .navigationTitle("Analytics")
        }
    }
}

#Preview {
    AnalyticsView(HydrationData: .constant(HydrationEntry.MOCK_DATA))
}
