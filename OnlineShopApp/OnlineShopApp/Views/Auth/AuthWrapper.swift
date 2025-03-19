//
//  AuthWrapper.swift
//  OnlineShopApp
//
//  Created by Philipp Hermann on 14.01.25.
//

import SwiftUI

struct AuthWrapper: View {
    @StateObject private var authViewModel = AuthViewModel()
    
    var body: some View {
        if authViewModel.isAuthenticated {
            ContentView()
                .environmentObject(authViewModel)
        } else {
            WelcomeView()
                .environmentObject(authViewModel)
        }
    }
}
