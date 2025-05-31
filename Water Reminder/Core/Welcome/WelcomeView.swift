//
//  WelcomeView.swift
//  Water Reminder
//
//  Created by KEREM BOYLU on 29.05.2025.
//

import SwiftUI

struct WelcomeView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 32) {
                Spacer()
                
                VStack(spacing: 16) {
                    Image(systemName: "drop.fill")
                        .resizable()
                        .frame(width: 80, height: 120)
                        .foregroundColor(Color("WaterColor"))
                    Text("Water Reminder")
                        .font(.title)
                        .fontWeight(.semibold)
                    Text("Stay hydrated. Track your daily water intake with ease.")
                        .font(.subheadline)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.gray)
                }
                .padding(.horizontal, 32)

                Spacer()
                
                VStack(spacing: 16) {
                    NavigationLink(destination: LoginView()) {
                        Text("Log In")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color("WaterColor"))
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }

                    NavigationLink(destination: RegisterView()) {
                        Text("Register")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(.systemGray6))
                            .foregroundColor(Color("WaterColor"))
                            .cornerRadius(12)
                    }
                }
                .padding(.horizontal, 32)
                
                Spacer()
            }
        }
    }
}

#Preview {
    WelcomeView()
}
