//
//  WaterDropView.swift
//  Water Reminder
//
//  Created by KEREM BOYLU on 19.05.2025.
//

import SwiftUI

struct WaterDropView: View {
    @Binding var progress: CGFloat
    @Binding var startAnimation: CGFloat
    var rotation: Double

    var body: some View {
        GeometryReader { proxy in
            let size = proxy.size
            ZStack {
                Image(systemName: "drop.fill")
                    .resizable()
                    .renderingMode(.template)
                    .aspectRatio(contentMode: .fit)
                    .foregroundStyle(Color("BackgroundColor"))
                    .scaleEffect(x: 1.1, y: 1)

                WaterWave(progress: progress, waveHeight: 0.03, offset: startAnimation, rotation: rotation)
                    .fill(Color("WaterColor"))
                    .shadow(color: Color("WaterColor"), radius: 3, x: 0, y: 1)
                    .rotationEffect(.radians(-rotation)) // Only the water rotates
                    .animation(.easeInOut(duration: 0.3), value: rotation)
                    .overlay(content: {
                        ZStack {
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
            .frame(width: size.width, height: size.height, alignment: .center)
        }
    }
}

struct WaterWave: Shape {
    var progress: CGFloat
    var waveHeight: CGFloat
    var offset: CGFloat
    var rotation: Double
    
    var animatableData: CGFloat {
        get { offset }
        set { offset = newValue }
    }
    
    func path(in rect: CGRect) -> Path {
        return Path { path in
            path.move(to: .zero)
            
            let progressHeight: CGFloat = (1 - progress) * rect.height - (waveHeight * rect.height * 0.5)
            let height = waveHeight * rect.height
            let rollOffset = CGFloat(rotation) * 30
            
            for value in stride(from: 0, to: rect.width, by: 2) {
                let x: CGFloat = value
                let sine: CGFloat = sin(Angle(degrees: value + offset).radians)
                let y: CGFloat = progressHeight + height * sine + rollOffset * (value / rect.width - 0.5)
                path.addLine(to: CGPoint(x: x, y: y))
            }
            
            path.addLine(to: CGPoint(x: rect.width, y: rect.height))
            path.addLine(to: CGPoint(x: 0, y: rect.height))
        }
    }
}

