//
//  AddToCartAnimation.swift
//  OnlineShopApp
//
//  Created by Philipp Hermann on 26.01.25.
//

import SwiftUI

struct AddToCartAnimation: View {
    @Binding var isPresented: Bool
    
    var body: some View {
        if isPresented {
            ZStack {
                Circle()
                    .fill(Color.white)
                    .frame(width: 100, height: 100)
                    .overlay(
                        Image(systemName: "cart.badge.plus")
                            .font(.system(size: 40))
                            .foregroundColor(.blue)
                    )
                    .shadow(radius: 5)
                    .scaleEffect(isPresented ? 1 : 0.5)
                    .opacity(isPresented ? 1 : 0)
            }
            .transition(.scale.combined(with: .opacity))
            .onAppear {
                // Animation nach 1.5 Sekunden ausblenden
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    withAnimation(.spring()) {
                        isPresented = false
                    }
                }
            }
        }
    }
}

#Preview {
    AddToCartAnimation(isPresented: .constant(true))
        .previewLayout(.sizeThatFits)
}

// Alternative Preview mit State
struct AddToCartAnimation_Previews: PreviewProvider {
    static var previews: some View {
        StateWrapper()
    }
    
    // Helper View für interaktive Preview
    struct StateWrapper: View {
        @State private var isPresented = true
        
        var body: some View {
            ZStack {
                Color.gray.opacity(0.3)
                
                Button("Toggle Animation") {
                    withAnimation {
                        isPresented.toggle()
                    }
                }
                
                AddToCartAnimation(isPresented: $isPresented)
            }
        }
    }
}
