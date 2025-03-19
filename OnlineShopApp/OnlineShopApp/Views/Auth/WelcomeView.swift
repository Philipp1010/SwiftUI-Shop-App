//
//  WelcomeView.swift
//  OnlineShopApp
//
//  Created by Philipp Hermann on 19.12.24.
//

import SwiftUI

struct WelcomeView: View {
    @State private var showLogin = false
    @State private var showRegister = false
    @State private var shouldShowLoginAfterRegister = false
    
    var body: some View {
        ZStack {
            // Hintergrundbild
            Image("welcomepic")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .edgesIgnoringSafeArea(.all)
            
            // Overlay
            Color.black.opacity(0.3)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                Spacer()
                
                Text("The best app for\nyour style")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                Text("Find your perfect outfit")
                    .font(.title3)
                    .foregroundColor(.white.opacity(0.8))
                
                Spacer()
                
                VStack(spacing: 12) {
                    Button(action: { showLogin.toggle() }) {
                        Text("Sign in")
                            .fontWeight(.semibold)
                            .foregroundColor(.black)
                            .frame(width: 200, height: 45)
                            .background(
                                RoundedRectangle(cornerRadius: 25)
                                    .fill(.white)
                                    .shadow(color: .black.opacity(0.25), radius: 8, y: 4)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 25)
                                    .stroke(Color.white.opacity(0.5), lineWidth: 1)
                            )
                    }
                    
                    Button(action: { showRegister.toggle() }) {
                        Text("Create an account")
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(width: 200, height: 45)
                            .overlay(
                                RoundedRectangle(cornerRadius: 25)
                                    .stroke(Color.white, lineWidth: 1.5)
                            )
                            .background(
                                RoundedRectangle(cornerRadius: 25)
                                    .fill(Color.white.opacity(0.2))
                            )
                    }
                }
                .padding(.bottom, 50)
            }
            .padding(.horizontal, 24)
        }
        .sheet(isPresented: $showLogin) {
            LoginView()
        }
        .sheet(isPresented: $showRegister) {
            RegisterView()
                .onDisappear {
                    if shouldShowLoginAfterRegister {
                        shouldShowLoginAfterRegister = false
                        showLogin = true
                    }
                }
        }
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("ShowLogin"))) { _ in
            shouldShowLoginAfterRegister = true
        }
    }
}

#Preview {
    WelcomeView()
}
