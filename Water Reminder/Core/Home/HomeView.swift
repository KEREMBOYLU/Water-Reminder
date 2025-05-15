//
//  HomeView.swift
//  Water Reminder
//
//  Created by KEREM BOYLU on 14.05.2025.
//

import SwiftUI

struct HomeView: View {
    @Binding var waterData: [WaterData]
    let targetAmount: Int = 4000

    @State var progress: CGFloat = 0.5
    @State var startAnimation: CGFloat = 0
    
    var body: some View {
        VStack {
            HStack {
                VStack(alignment: .leading) {
                    Text("14")
                        .font(.largeTitle)
                        .bold()
                    Text("Çarşamba")
                        .font(.caption)
                        .padding(.top, -4)
                        .foregroundColor(.white)
                        .padding(4)
                        .background(Color.blue)
                        .cornerRadius(4)
                    Text("6:56 ÖS")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                Spacer()
                Text("6:56")
                    .font(.title)
                    .bold()
            }
            .padding(.horizontal)
            .padding(.bottom, 30)
            
            
            GeometryReader{ proxy in
                let size = proxy.size
                
                ZStack{
                    Image(systemName: "drop.fill")
                        .resizable()
                        .renderingMode(.template)
                        .aspectRatio(contentMode: .fit)
                        .foregroundStyle(Color("BackgroundColor"))
                    
                        .scaleEffect(x: 1.1,y: 1)
                    
                    WaterWave(progress: progress, waveHeight: 0.05, offset: startAnimation)
                        .fill(Color("WaterColor"))
                        .overlay(content: {
                            ZStack{
                                Circle()
                                    .fill(Color("BackgroundColor").opacity(0.1))
                                    .frame(width: 15, height: 15)
                                    .offset(x: -20)
                                Circle()
                                    .fill(Color("BackgroundColor").opacity(0.1))
                                    .frame(width: 15, height: 15)
                                    .offset(x: 20, y: 30)
                                Circle()
                                    .fill(Color("BackgroundColor").opacity(0.1))
                                    .frame(width: 25, height: 25)
                                    .offset(x: 10, y: -70)
                                Circle()
                                    .fill(Color("BackgroundColor").opacity(0.1))
                                    .frame(width: 25, height: 25)
                                    .offset(x: -50, y: 70)
                                Circle()
                                    .fill(Color("BackgroundColor").opacity(0.1))
                                    .frame(width: 10, height: 10)
                                    .offset(x: 25, y: -60)
                                Circle()
                                    .fill(Color("BackgroundColor").opacity(0.1))
                                    .frame(width: 10, height: 10)
                                    .offset(x: 50, y: 70)

                            }
                        })
                    
                        .mask {
                            Image(systemName: "drop.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .padding(20)
                        }
                        
                }
                .frame(width: size.width, height: size.height,alignment: .center)
                .onAppear {
                    let today = Calendar.current.startOfDay(for: Date())
                    let totalToday = waterData
                        .filter { Calendar.current.isDate($0.date, inSameDayAs: today) }
                        .reduce(0) { $0 + $1.amount }
                    progress = min(CGFloat(totalToday) / CGFloat(targetAmount), 1.0)

                    withAnimation(.linear(duration: 2).repeatForever(autoreverses: false)) {
                        startAnimation = size.width
                    }
                }
            }
            .frame(height: 350)
            .padding(.bottom, 40)
            
            HStack(spacing: 40) {
                Button(action: {
                    let now = Date()
                    let newEntry = WaterData(id: UUID().uuidString, date: now, amount: 250)
                    waterData.append(newEntry)
                    
                    let today = Calendar.current.startOfDay(for: now)
                    let totalToday = waterData
                        .filter { Calendar.current.isDate($0.date, inSameDayAs: today) }
                        .reduce(0) { $0 + $1.amount }
                    progress = min(CGFloat(totalToday) / CGFloat(targetAmount), 1.0)
                }) {
                    Image(systemName: "plus.circle.fill")
                        .resizable()
                        .frame(width: 60, height: 60)
                        .foregroundColor(Color("WaterColor"))
                    
                }
                
                Button(action: {}) {
                    Image(systemName: "list.bullet")
                        .resizable()
                        .frame(width: 30, height: 30)
                        .foregroundColor(.gray)
                }
            }
            HStack {
                Text("0ml • 0%")
                    .font(.subheadline)
                    .bold()
                Spacer()
                Text("Kalan: 3.824ml")
                    .font(.subheadline)
                    .bold()
            }
            .padding(.horizontal)
            
            ProgressView(value: 0.0)
                .progressViewStyle(LinearProgressViewStyle(tint: .gray))
                .padding(.horizontal)
        }
        .padding()
        .frame(maxWidth: .infinity,maxHeight: .infinity,alignment: .top)
    }
}

#Preview {
    HomeView(waterData: .constant(WaterData.MOCK_WATER_DATA))
}

struct WaterWave: Shape {
    
    var progress: CGFloat
    var waveHeight: CGFloat
    
    var offset: CGFloat
    
    var animatableData: CGFloat {
        get { offset }
        set { offset = newValue }
    }
    
    func path(in rect: CGRect) -> Path {
        return Path{path in
            path.move(to: .zero)
            
            let progressHeight: CGFloat = (1 - progress) * rect.height
            let height = waveHeight * rect.height
            
            for value in stride(from: 0, to: rect.width, by: 2) {
                let x: CGFloat = value
                let sine: CGFloat = sin(Angle(degrees:value + offset).radians)
                let y: CGFloat = progressHeight + height * sine
                
                path.addLine(to: CGPoint(x: x, y: y))
            }
            
            path.addLine(to: CGPoint(x: rect.width, y: rect.height))
            path.addLine(to: CGPoint(x: 0, y: rect.height))
            
        }
    }
}
