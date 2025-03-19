//
//  LoginView.swift
//  OnlineShopApp
//
//  Created by Philipp Hermann on 19.12.24.
//

import SwiftUI

struct LoginView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var authViewModel = AuthViewModel()
    @State private var email = ""
    @State private var password = ""
    @State private var rememberMe = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            // Back Button
            Button(action: { dismiss() }) {
                Image(systemName: "chevron.left")
                    .imageScale(.large)
                    .foregroundColor(.black)
            }
            .padding(.top)
            
            Text("Welcome Back")
                .font(.title)
                .fontWeight(.bold)
            
            Text("Login to your account")
                .foregroundColor(.gray)
            
            // Input Fields und Login Button
            VStack(spacing: 24) {
                // Input Fields
                VStack(spacing: 16) {
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
                
                // Remember Me & Forgot Password
                HStack {
                    Toggle(isOn: $rememberMe) {
                        Text("Remember Me")
                            .font(.subheadline)
                    }
                    .toggleStyle(CheckboxStyle())
                    
                    Spacer()
                    
                    Button("Forgot Password?") {
                        // Handle forgot password
                    }
                    .foregroundColor(.gray)
                    .font(.subheadline)
                }
                
                // Login Button und Fehlermeldung
                VStack(spacing: 32) {
                    if let error = authViewModel.error {
                        Text(error)
                            .foregroundColor(.red)
                            .font(.caption)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    
                    Button(action: {
                        authViewModel.login(email: email, password: password)
                        if authViewModel.isAuthenticated {
                            dismiss()
                        }
                    }) {
                        if authViewModel.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text("Login")
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
            VStack(spacing: 20) {
                Text("Or continue with")
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity)
                
                HStack(spacing: 20) {
                    SocialLoginButton(systemName: "apple.logo", action: {
                        AnalyticsManager.shared.logEvent("login_attempt", parameters: [
                            "login_method": "apple"
                        ])
                    })
                    SocialLoginButton(systemName: "g.circle.fill", action: {
                        AnalyticsManager.shared.logEvent("login_attempt", parameters: [
                            "login_method": "google"
                        ])
                    })
                }
                .frame(maxWidth: .infinity, alignment: .center)
            }
            .padding(.top, 24)
            
            Spacer()
        }
        .padding(.horizontal, 24)
        .onAppear {
            AnalyticsManager.shared.logScreenView(screenName: "Login")
        }
    }
}

#Preview {
    LoginView()
}
