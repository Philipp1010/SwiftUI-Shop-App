//
//  BrandView.swift
//  OnlineShopApp
//
//  Created by Philipp Hermann on 19.12.24.
//

import SwiftUI

struct BrandView: View {
    let brand: Brand
    
    var body: some View {
        VStack(spacing: 8) {
            Image(brand.logoName)
                .resizable()
                .scaledToFit()
                .frame(height: 40)
            
            Text(brand.description)
                .font(.caption)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
        .frame(width: 120, height: 90)
        .padding(.all, 12)
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(
            color: Color.black.opacity(0.1),
            radius: 5,
            x: 0,
            y: 2
        )
    }
}

#Preview {
    BrandView(brand: Brand(
        id: 1,
        name: "Nike",
        logoName: "nike",
        description: "Just Do It"
    ))
    .padding()
}
