//
//  SocialLoginButton.swift
//  OnlineShopApp
//
//  Created by Philipp Hermann on 03.01.25.
//

import SwiftUI

struct SocialLoginButton: View {
    let systemName: String
    let action: () -> Void
    
    // Farben für die verschiedenen Services
    private var iconColor: Color {
        switch systemName {
        case "apple.logo": return .black
        case "g.circle.fill": return Color(red: 234/255, green: 67/255, blue: 53/255) // Google Rot
        default: return .gray
        }
    }
    
    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 26, weight: .medium))
                .foregroundColor(iconColor)
                .frame(width: 44, height: 44)
                .background(
                    Circle()
                        .fill(.white)
                        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
                )
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.9 : 1)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

#Preview {
    ZStack {
        Color(.systemGray6)
            .ignoresSafeArea()
        
        HStack(spacing: 20) {
            SocialLoginButton(systemName: "apple.logo", action: {})
            SocialLoginButton(systemName: "g.circle.fill", action: {})
        }
        .padding()
    }
}
