//
//  AnalyticsView.swift
//  Water Reminder
//
//  Created by KEREM BOYLU on 4.05.2025.
//

import SwiftUI

struct AnalyticsView: View {
    @State private var selectedRange = "Gün"
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {

                // Segmented control
                HStack(spacing: 0) {
                    ForEach(["Gün", "Hafta", "Ay", "Yıl"].indices, id: \.self) { index in
                        let options = ["Gün", "Hafta", "Ay", "Yıl"]
                        let label = options[index]
                        let nextLabel = index + 1 < options.count ? options[index + 1] : nil
                        Button(action: {
                            selectedRange = label
                        }) {
                            Text(label)
                                .font(.system(size: 16, weight: selectedRange == label ? .bold : .semibold))
                                .frame(maxWidth: .infinity)
                                .frame(height: 40)
                                .background(
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(selectedRange == label ? Color.blue : Color(.systemGray5))
                                )
                                .foregroundColor(selectedRange == label ? .white : .primary)
                        }

                        if index < 3 {
                            if selectedRange != label && selectedRange != nextLabel {
                                Divider()
                                    .frame(width: 1, height: 20)
                                    .background(Color.gray.opacity(0.3))
                            }
                        }
                        
                    }
                }
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color(.systemGray5))
                )
                .padding(.horizontal)

                // Daily chart view placeholder
                if selectedRange == "Gün" {
                    DailyChartView(data: WaterData.MOCK_WATER_DATA)
                }

                Spacer()
            }
            .navigationTitle("Analiz")
        }
    }
}

#Preview {
    AnalyticsView()
}
