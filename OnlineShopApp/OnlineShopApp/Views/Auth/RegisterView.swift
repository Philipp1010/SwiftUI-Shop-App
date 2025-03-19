//
//  RegisterView.swift
//  OnlineShopApp
//
//  Created by Philipp Hermann on 19.12.24.
//

import SwiftUI

struct RegisterView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var authViewModel = AuthViewModel()
    @State private var fullName = ""
    @State private var email = ""
    @State private var password = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            // Back Button
            Button(action: { dismiss() }) {
                Image(systemName: "chevron.left")
                    .imageScale(.large)
                    .foregroundColor(.black)
            }
            .padding(.top)
            
            Text("Register")
                .font(.title)
                .fontWeight(.bold)
            
            Text("Create your new account")
                .foregroundColor(.gray)
            
            // Input Fields und Register Button
            VStack(spacing: 24) {
                // Input Fields
                VStack(spacing: 16) {
                    CustomTextField(
                        text: $fullName,
                        placeholder: "Full Name",
                        icon: "person.fill",
                        formatter: { text in
                            text.split(separator: " ")
                                .map { $0.prefix(1).uppercased() + $0.dropFirst().lowercased() }
                                .joined(separator: " ")
                        }
                    )
                    
                    CustomTextField(
                        text: $email,
                        placeholder: "Email",
                        icon: "envelope.fill",
                        formatter: { $0.formatAsEmail() }
                    )
                    
                    CustomSecureField(
                        text: $password,
                        placeholder: "Password",
                        icon: "lock.fill",
                        formatter: { $0 }
                    )
                }
                
                // Register Button und Fehlermeldung
                VStack(spacing: 32) {
                    if let error = authViewModel.error {
                        Text(error)
                            .foregroundColor(.red)
                            .font(.caption)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    
                    Button(action: {
                        authViewModel.register(
                            fullName: fullName,
                            email: email,
                            password: password
                        )
                        
                        if authViewModel.isAuthenticated {
                            AnalyticsManager.shared.logEvent("registration_success", parameters: [
                                "registration_method": "email"
                            ])
                        }
                    }) {
                        if authViewModel.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text("Register")
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(width: 200, height: 45)
                        }
                    }
                    .frame(width: 200, height: 45)
                    .background(
                        RoundedRectangle(cornerRadius: 25)
                            .fill(Color.black)
                            .shadow(color: .black.opacity(0.25), radius: 8, y: 4)
                    )
                    .disabled(authViewModel.isLoading)
                }
                .frame(maxWidth: .infinity, alignment: .center)
            }
            .padding(.top)
            
            // Social Login
            VStack(spacing: 16) {
                Text("Or continue with")
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity)
                
                HStack(spacing: 20) {
                    SocialLoginButton(systemName: "apple.logo", action: {})
                    SocialLoginButton(systemName: "g.circle.fill", action: {})
                }
                .frame(maxWidth: .infinity, alignment: .center)
            }
            .padding(.top)
            
            Spacer()
            
            // Sign In Link
            HStack {
                Text("Already have an account?")
                    .foregroundColor(.gray)
                Button("Sign in") {
                    dismiss()
                    // Kurze Verzögerung für bessere Animation
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        NotificationCenter.default.post(name: Notification.Name("ShowLogin"), object: nil)
                    }
                }
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.horizontal, 24)
        .onAppear {
            AnalyticsManager.shared.logScreenView(screenName: "Register")
        }
    }
}

#Preview {
    RegisterView()
}
