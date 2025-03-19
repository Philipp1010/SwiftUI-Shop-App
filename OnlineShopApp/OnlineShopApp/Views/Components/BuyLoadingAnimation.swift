//
//  BuyLoadingAnimation.swift
//  OnlineShopApp
//
//  Created by Philipp Hermann on 26.01.25.
//

import SwiftUI

struct BuyLoadingAnimation: View {
    @State private var isRotating = false
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.white.opacity(0.3), lineWidth: 4)
                .frame(width: 100, height: 100)
            
            Circle()
                .trim(from: 0, to: 0.7)
                .stroke(Color.white, lineWidth: 4)
                .frame(width: 100, height: 100)
                .rotationEffect(Angle(degrees: isRotating ? 360 : 0))
            
            Image(systemName: "cart.fill")
                .font(.system(size: 30))
                .foregroundColor(.white)
                .scaleEffect(isAnimating ? 1.1 : 1.0)
        }
        .onAppear {
            withAnimation(Animation.linear(duration: 1).repeatForever(autoreverses: false)) {
                isRotating = true
            }
            withAnimation(Animation.easeInOut(duration: 0.5).repeatForever()) {
                isAnimating = true
            }
        }
    }
}

#Preview {
    BuyLoadingAnimation()
        .preferredColorScheme(.light)
}
