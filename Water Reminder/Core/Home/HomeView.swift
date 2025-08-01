//
//  HomeView.swift
//  Water Reminder
//
//  Created by KEREM BOYLU on 14.05.2025.
//

import SwiftUI
import CoreMotion

class MotionManager: ObservableObject {
    private var motionManager = CMMotionManager()
    @Published var rotation: Double = 0.0
    private var lastRawAngle: Double = 0.0
    private var totalRotation: Double = 0.0

    init() {
        motionManager.deviceMotionUpdateInterval = 1 / 60
        motionManager.startDeviceMotionUpdates(to: .main) { [weak self] data, _ in
            guard let self = self, let data = data else { return }

            let gravity = data.gravity
            let rawAngle = atan2(gravity.x, -gravity.y)

            // Açı farkını hesapla
            var delta = rawAngle - self.lastRawAngle

            // Açı farkını normalize et (-π ile π arasına getir)
            if delta > .pi {
                delta -= 2 * .pi
            } else if delta < -.pi {
                delta += 2 * .pi
            }

            // Birikimli toplamı güncelle
            self.totalRotation += delta
            self.lastRawAngle = rawAngle

            // Animasyonlu olarak güncelle
            DispatchQueue.main.async {
                withAnimation(.easeInOut(duration: 0.2)) {
                    self.rotation = self.totalRotation
                }
            }
        }
    }
}

struct HomeView: View {
    @Binding var currentUser: AppUser
    @Binding var hydrationData: [HydrationEntry]
    @StateObject var typeManager = HydrationTypeManager()

    @State var progress: CGFloat = 0
    @State var startAnimation: CGFloat = 0
    @State private var showCustomInput = false
    @State private var customAmount = ""
    @StateObject var motionManager = MotionManager()
    @State private var time: Double = 0.0
    
    func calculateTotalHydration(for date: Date) -> Int {
        let filteredData = hydrationData.filter { Calendar.current.isDate($0.date, inSameDayAs: date) }
        let total = filteredData.reduce(0) { sum, entry in
            let waterRatio = typeManager.types.first(where: { $0.id == entry.typeID })?.waterRatio ?? 1.0
            let amount = Double(entry.amount) * waterRatio
            return sum + Int(amount)
        }
        return total
    }
    
    var body: some View {
        let today: Date = Date()
        VStack {
            
            HStack(alignment: .center) {
                HStack(spacing: 12) {
                    Text(today.formattedDate(format: "d MMMM"))
                        .font(.headline)
                        .foregroundColor(.primary)

                    Text(today.formattedDate(format: "EEEE"))
                        .font(.headline)
                        .foregroundColor(Color("WaterColor"))
                        .bold()

                    Text(today.formattedDate(format: "HH:mm"))
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .padding(8)
                .frame(height: 32)
                .background(Color(.systemGray6))
                .cornerRadius(12)
                

                Spacer()

                Button(action: {
                    // buton aksiyonu buraya
                }) {
                    Image(systemName: "square.and.pencil")
                        .font(.title3)
                        .foregroundColor(Color("WaterColor"))
                        .frame(width: 32, height: 32)
                        .padding(4)
                        .background(
                            Rectangle()
                                .fill(Color("WaterColor").opacity(0.15))
                                .cornerRadius(18)
                        )
                }
                
            }
            .padding(.horizontal,4)
            .shadow(color: Color("WaterColor"), radius: 3, x: 0, y: 1)
            
            Spacer()

            
            WaterDropView(progress: $progress, startAnimation: $startAnimation, rotation: motionManager.rotation)
                .frame(height: 350)
                .padding(.bottom)
                .shadow(color: Color("WaterColor").opacity(0.5), radius: 3, x: 0, y: 1)
            
            HStack {
                let today = Calendar.current.startOfDay(for: Date())
                let totalToday = calculateTotalHydration(for: today)
                let remaining = max((currentUser.dailyGoal ?? 0) - totalToday, 0)
                let progressPercent = Int((CGFloat(totalToday) / CGFloat(currentUser.dailyGoal ?? 1)) * 100)

                Text("\(totalToday)ml • \(progressPercent)%")
                    .font(.subheadline)
                    .bold()
                Spacer()
                Text("Remaining: \(remaining.localizedString()) ml")
                    .font(.subheadline)
                    .bold()
            }
            .padding(.horizontal)
            

            ProgressView(value: CGFloat(calculateTotalHydration(for: Calendar.current.startOfDay(for: Date()))) / CGFloat(currentUser.dailyGoal ?? 1))
                .progressViewStyle(LinearProgressViewStyle(tint: Color("WaterColor")))
                .frame(height: 6)
                .clipShape(Capsule())
                .padding(.bottom, 48)
                .padding(.horizontal)
                .shadow(color: Color("WaterColor"), radius: 3, x: 0, y: 1)

            
            HStack(spacing: 20){
                
                Button(action: {
                    let now = Date()
                    let entry = HydrationEntry(id: UUID().uuidString, date: now, amount: 100, typeID: "water")
                    FirebaseService.addHydrationEntry(for: currentUser.id, entry: entry) { error in
                        if error == nil {
                            hydrationData.append(entry)
                            let today = Calendar.current.startOfDay(for: now)
                            let totalToday = calculateTotalHydration(for: today)
                            progress = min(CGFloat(totalToday) / CGFloat(currentUser.dailyGoal ?? 1), 1.0)
                        }
                    }
                }) {
                    ZStack(alignment: .bottomTrailing) {
                        Image("WaterGlass100")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 30, height: 30)
                            .foregroundColor(.white)
                            .padding()
                            .background(Circle().fill(Color("WaterColor")))
                            .frame(width: 60, height: 60)

                        Text("+100ml")
                            .font(.caption2)
                            .bold()
                            .padding(.horizontal, 4)
                            .padding(.vertical, 2)
                            .background(Color.white)
                            .foregroundColor(.black)
                            .clipShape(Capsule())
                            .offset(x: 5, y: 5)
                    }
                    .shadow(radius: 2)

                }
                
                Button(action: {
                    let now = Date()
                    let entry = HydrationEntry(id: UUID().uuidString, date: now, amount: 200, typeID: "water")
                    FirebaseService.addHydrationEntry(for: currentUser.id, entry: entry) { error in
                        if error == nil {
                            hydrationData.append(entry)
                            let today = Calendar.current.startOfDay(for: now)
                            let totalToday = calculateTotalHydration(for: today)
                            progress = min(CGFloat(totalToday) / CGFloat(currentUser.dailyGoal ?? 1), 1.0)
                        }
                    }
                }) {
                    ZStack(alignment: .bottomTrailing) {
                        Image("WaterGlass200")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 30, height: 30)
                            .foregroundColor(.white)
                            .padding()
                            .background(Circle().fill(Color("WaterColor")))
                            .frame(width: 60, height: 60)

                        Text("+200ml")
                            .font(.caption2)
                            .bold()
                            .padding(.horizontal, 4)
                            .padding(.vertical, 2)
                            .background(Color.white)
                            .foregroundColor(.black)
                            .clipShape(Capsule())
                            .offset(x: 5, y: 5)
                    }
                    .shadow(radius: 2)

                }
                
                Button(action: {
                    let now = Date()
                    let entry = HydrationEntry(id: UUID().uuidString, date: now, amount: 500, typeID: "water")
                    FirebaseService.addHydrationEntry(for: currentUser.id, entry: entry) { error in
                        if error == nil {
                            hydrationData.append(entry)
                            let today = Calendar.current.startOfDay(for: now)
                            let totalToday = calculateTotalHydration(for: today)
                            progress = min(CGFloat(totalToday) / CGFloat(currentUser.dailyGoal ?? 1), 1.0)
                        }
                    }
                }) {
                    ZStack(alignment: .bottomTrailing) {
                        Image("WaterBottle500")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 30, height: 30)
                            .foregroundColor(.white)
                            .padding()
                            .background(Circle().fill(Color("WaterColor")))
                            .frame(width: 60, height: 60)

                        Text("+500ml")
                            .font(.caption2)
                            .bold()
                            .padding(.horizontal, 4)
                            .padding(.vertical, 2)
                            .background(Color.white)
                            .foregroundColor(.black)
                            .clipShape(Capsule())
                            .offset(x: 5, y: 5)
                    }
                    .shadow(radius: 2)

                }
                
                Button(action: {
                    showCustomInput = true
                }) {
                    ZStack(alignment: .bottomTrailing) {
                        Image(systemName: "plus")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 30, height: 30)
                            .foregroundColor(.white)
                            .padding()
                            .background(Circle().fill(Color("WaterColor")))
                            .frame(width: 60, height: 60)

                        Text("Manual")
                            .font(.caption2)
                            .bold()
                            .padding(.horizontal, 4)
                            .padding(.vertical, 2)
                            .background(Color.white)
                            .foregroundColor(.black)
                            .clipShape(Capsule())
                            .offset(x: 5, y: 5)
                    }
                    .shadow(radius: 2)
                }
            }
            .shadow(color: Color("WaterColor"), radius: 3, x: 0, y: 1)
            
            Spacer()
            
//            HStack(spacing: 40) {
//                Button(action: {
//                    // Future functionality to be implemented
//                }) {
//                    Image(systemName: "pencil")
//                        .resizable()
//                        .scaledToFit()
//                        .frame(width: 30, height: 30)
//                        .foregroundColor(.white)
//                        .padding()
//                        .background(Circle().fill(Color("WaterColor")))
//                        .frame(width: 60, height: 60)
//                }
//
//            }
//            .padding()
            
        }
        .padding()
        .frame(maxWidth: .infinity,maxHeight: .infinity,alignment: .top)
        .sheet(isPresented: $showCustomInput) {
            CustomInputSheetView(
                onSave: {
                    let today = Calendar.current.startOfDay(for: Date())
                    let totalToday = calculateTotalHydration(for: today)
                    progress = min(CGFloat(totalToday) / CGFloat(currentUser.dailyGoal ?? 1), 1.0)
                }, hydrationData: $hydrationData,
                typeManager: typeManager,
                currentUser: currentUser
            )
            .presentationDetents([.fraction(0.75)])
            .presentationCornerRadius(24)
            .presentationBackground(Color("BackgroundColor").opacity(0.9))
            
        }
        .onAppear {
            typeManager.loadTypes()
            Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true) { _ in
                startAnimation += 1
            }
        }
    }
}
