//
//  CustomInputSheetView.swift
//  Water Reminder
//
//  Created by KEREM BOYLU on 19.05.2025.
//

import SwiftUI

struct CustomInputSheetView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var hydrationData: [HydrationEntry]
    @State private var inputAmount = ""
    @State private var animateKeypad = false

    // Reusable button builder for the grid
    @ViewBuilder
    func numberButton(_ value: String) -> some View {
        Button(action: {
            if value == "⌫" {
                if !inputAmount.isEmpty {
                    inputAmount.removeLast()
                }
            } else {
                inputAmount.append(value)
            }
        }) {
            Text(value)
                .frame(maxWidth: .infinity, minHeight: 44)
                .foregroundStyle(value == "⌫" ? Color.red : .primary)
                .font(.title2)
                .background(Color(.secondarySystemBackground))
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 2)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color("WaterColor").opacity(0.3), lineWidth: 1)
                )
        }
    }

    var body: some View {
        ZStack {
            Color.clear
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 24))
                .ignoresSafeArea()

            VStack(spacing: 20) {
                ZStack {
                    Text("Water")
                        .font(.title3)
                        .bold()
                        .foregroundColor(.gray)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.gray.opacity(0.1))
                        .clipShape(Capsule())
                        .frame(maxWidth: .infinity, alignment: .center)

                    HStack {
                        Spacer()
                        Button(action: { dismiss() }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title2)
                                .foregroundColor(Color("WaterColor"))
                        }
                        .contentShape(Circle())
                        .hoverEffect(.highlight)
                    }
                }
                
                Text(Date().formatted(date: .long, time: .shortened))
                    .font(.subheadline)
                    .foregroundColor(Color("WaterColor"))
                    .bold()
                    .transition(.scale)
                    .animation(.easeOut(duration: 0.3), value: animateKeypad)
                
                Spacer()

                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text(inputAmount.isEmpty ? "0" : inputAmount)
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(.white)

                    Text("ml")
                        .font(.title3)
                        .foregroundColor(.white.opacity(0.9))
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(Color("WaterColor").gradient)
                        .shadow(color: Color("WaterColor").opacity(0.3), radius: 6, x: 0, y: 3)
                )
                .transition(.scale)
                .animation(.easeOut(duration: 0.3), value: animateKeypad)


                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 3), spacing: 12) {
                    numberButton("1")
                    numberButton("2")
                    numberButton("3")
                    numberButton("4")
                    numberButton("5")
                    numberButton("6")
                    numberButton("7")
                    numberButton("8")
                    numberButton("9")
                    numberButton("00")
                    numberButton("0")
                    numberButton("⌫")
                }
                .padding(.top)
                .offset(y: animateKeypad ? 0 : 40)
                .opacity(animateKeypad ? 1 : 0)
                .animation(.easeOut(duration: 0.3), value: animateKeypad)

                Button(action: {
                    if let amount = Int(inputAmount), amount > 0 {
                        let newEntry = HydrationEntry(id: UUID(), date: Date(), amount: amount, type: HydrationType.water)
                        hydrationData.append(newEntry)
                        dismiss()
                    }
                }) {
                    Text("ADD")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            Capsule()
                                .fill(Color("WaterColor").gradient)
                                .shadow(color: Color("WaterColor").opacity(0.3), radius: 6, x: 0, y: 3)
                        )
                        .foregroundColor(.white)
                        .shadow(color: Color("WaterColor").opacity(0.4), radius: 6, x: 0, y: 4)
                }
            }
            .padding(.horizontal)
            .padding()
        }
        .onAppear {
            animateKeypad = true
        }
    }
}

#Preview {
    CustomInputSheetView(hydrationData: .constant(HydrationEntry.MOCK_DATA))
}
