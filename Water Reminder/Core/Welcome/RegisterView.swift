//
//  RegisterView.swift
//  Water Reminder
//
//  Created by KEREM BOYLU on 29.05.2025.
//

import SwiftUI
import FirebaseAuth

struct RegisterView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showPassword = false
    @State private var showConfirmPassword = false
    @State private var shouldNavigateToSetup = false

    private func registerUser() {
        isLoading = true

        guard password == confirmPassword else {
            errorMessage = "Passwords do not match."
            isLoading = false
            return
        }

        AuthService.shared.signUp(email: email, password: password) { result in
            isLoading = false
            switch result {
            case .success(_):
                shouldNavigateToSetup = true
            case .failure(let error):
                errorMessage = error.localizedDescription
            }
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Register")
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

                HStack {
                    Group {
                        if showConfirmPassword {
                            TextField("Confirm Password", text: $confirmPassword)
                        } else {
                            SecureField("Confirm Password", text: $confirmPassword)
                        }
                    }
                    Button(action: { showConfirmPassword.toggle() }) {
                        Image(systemName: showConfirmPassword ? "eye.slash" : "eye")
                            .foregroundColor(.gray)
                    }
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(8)

                Button(action: registerUser) {
                    if isLoading {
                        ProgressView()
                    } else {
                        Text("Sign Up")
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color("WaterColor"))
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }

                if let error = errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding(.top)
                }

                Spacer()
                
            }
            .padding()
            .navigationDestination(isPresented: $shouldNavigateToSetup) {
                SetupProfileView()
                    .navigationBarBackButtonHidden(true)
            }
        }
    }
}

#Preview {
    RegisterView()
}
