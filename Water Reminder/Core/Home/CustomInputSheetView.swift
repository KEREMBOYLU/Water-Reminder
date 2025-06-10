import SwiftUI

struct CustomInputSheetView: View {
    let onSave: () -> Void
    @Environment(\.dismiss) var dismiss
    @Binding var hydrationData: [HydrationEntry]
    @ObservedObject var typeManager: HydrationTypeManager
    @State private var inputAmount = ""
    @State private var animateKeypad = false
    @State private var selectedTypeID: String = "water"
    let currentUser: AppUser
    
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
        VStack(spacing: 16) {
            Picker("Type", selection: $selectedTypeID) {
                ForEach(typeManager.types, id: \.id) { type in
                    HStack {
                        type.icon
                        Text(" \(type.name)")
                            .foregroundStyle(.red)
                    }
                    .tag(type.id)
                }
            }
            .pickerStyle(.automatic)
            .foregroundStyle(Color("WaterColor").gradient)
            .padding(.horizontal)
            
            Text(Date().formattedDate(format: "d MMM yyyy EEEE HH:mm"))
                .font(.title3)
                .bold()
                .padding(.top, 20)
            
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(inputAmount.isEmpty ? "    0" : inputAmount)
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
                    let userID = currentUser.id
                    let newEntry = HydrationEntry(id: UUID().uuidString, date: Date(), amount: amount, typeID: selectedTypeID)
                    FirebaseService.addHydrationEntry(for: userID, entry: newEntry) { error in
                        if error == nil {
                            hydrationData.append(newEntry)
                            onSave()
                            dismiss()
                        } else {
                            print("❌ Failed to save entry to Firestore")
                        }
                    }
                }
            }){
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
        .padding()
        .onAppear {
            animateKeypad = true
            typeManager.loadTypes()
        }
    }
}
