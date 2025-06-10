//
//  AnalyticsView.swift
//  Water Reminder
//
//  Created by KEREM BOYLU on 4.05.2025.
//

import SwiftUI

enum AnalyticsRange: String, CaseIterable {
    case day = "D"
    case week = "W"
    case month = "M"
    case year = "Y"
}

struct AnalyticsView: View {
    @Binding var currentUser: AppUser
    @StateObject private var hydrationManager: HydrationDataManager
    @ObservedObject var typeManager: HydrationTypeManager
    @State private var selectedRange: AnalyticsRange = .day
    
    
    init(currentUser: Binding<AppUser>, typeManager: HydrationTypeManager) {
        self._currentUser = currentUser
        self._hydrationManager = StateObject(wrappedValue: HydrationDataManager(userID: currentUser.wrappedValue.id))
        self.typeManager = typeManager
    }
    
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                
                // Segmented control
                let options = AnalyticsRange.allCases
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
                                let label = options[index].rawValue
                                let nextLabel = options[safe: index + 1]?.rawValue ?? ""
                                Button(action: {
                                    withAnimation(.easeInOut) {
                                        selectedRange = options[index]
                                    }
                                }) {
                                    Text(label)
                                        .font(.system(size: 16, weight: selectedRange.rawValue == label ? .bold : .semibold))
                                        .frame(width: buttonWidth, height: 40)
                                        .foregroundColor(selectedRange.rawValue == label ? .white : .primary)
                                }
                                if index < options.count - 1 {
                                    if selectedRange.rawValue != label && selectedRange.rawValue != nextLabel {
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
                
                if selectedRange == .day {
                    DailyChartView(HydrationData: .constant(hydrationManager.entries), types: typeManager.types)
                        .environmentObject(typeManager)
                }
                if selectedRange == .week {
                    WeeklyChartView(HydrationData: .constant(hydrationManager.entries), types: typeManager.types)
                        .environmentObject(typeManager)
                }
                if selectedRange == .month {
                    MonthlyChartView(HydrationData: .constant(hydrationManager.entries), types: typeManager.types)
                        .environmentObject(typeManager)
                }
                if selectedRange == .year {
                    YearlyChartView(HydrationData: .constant(hydrationManager.entries), types: typeManager.types)
                        .environmentObject(typeManager)
                }
                
                Spacer()
            }
            .onAppear {
               
                print("🔍 Available HydrationTypes:")
                typeManager.types.forEach { print("- \($0.id)") }

                print("🟢 AnalyticsView appeared. hydrationData.count: \(hydrationManager.entries.count)")
                hydrationManager.entries.forEach { entry in
                    print("💧 Entry → amount: \(entry.amount), date: \(entry.date), typeID: \(entry.typeID)")
                }
            }
            .navigationTitle("Analytics")
        }
    }
}

#Preview {
    @Previewable @State var mockUser = AppUser(
        id: "mockUser123",
        email: "mock@example.com",
        username: "Mock User",
        creationDate: Date(),
        lastSignInDate: Date(),
        age: 25,
        height: 175,
        weight: 70,
        dailyGoal: 3000
    )
    
    AnalyticsView(currentUser: .constant(mockUser), typeManager: HydrationTypeManager.shared)
}
