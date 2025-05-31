//
//  LoginView.swift
//  Water Reminder
//
//  Created by KEREM BOYLU on 29.05.2025.
//

import SwiftUI
import UIKit

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage = ""
    @State private var isLoading = false
    @State private var showPassword = false

    var body: some View {
        VStack(spacing: 20) {
            Text("Login")
                .font(.largeTitle)
                .bold()

            TextField("Email", text: $email)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(8)

            HStack {
                Group {
                    if showPassword {
                        TextField("Password", text: $password)
                    } else {
                        SecureField("Password", text: $password)
                    }
                }
                Button(action: { showPassword.toggle() }) {
                    Image(systemName: showPassword ? "eye.slash" : "eye")
                        .foregroundColor(.gray)
                }
            }
            .padding()
            .background(Color(.secondarySystemBackground))
            .cornerRadius(8)

            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
            }

            Button(action: {
                isLoading = true
                AuthService.shared.signIn(email: email, password: password) { result in
                    isLoading = false
                    switch result {
                    case .success(_):
                        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                           let window = windowScene.windows.first {
                            window.rootViewController = UIHostingController(rootView: MainTabView())
                            window.makeKeyAndVisible()
                        }
                    case .failure(let error):
                        errorMessage = error.localizedDescription
                    }
                }
            }) {
                if isLoading {
                    ProgressView()
                } else {
                    Text("Login")
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color("WaterColor"))
                        .cornerRadius(8)
                }
            }

            Spacer()
        }
        .padding()
    }
}

#Preview {
    LoginView()
}
