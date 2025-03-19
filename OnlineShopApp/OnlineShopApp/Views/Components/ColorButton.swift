//
//  ColorButton.swift
//  OnlineShopApp
//
//  Created by Philipp Hermann on 02.01.25.
//

import SwiftUI

struct ColorButton: View {
    let productColor: ProductColor
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                if isSelected {
                    Circle()
                        .stroke(productColor.color, lineWidth: 2)
                        .frame(width: 56, height: 56)
                }
                
                Circle()
                    .fill(productColor.color)
                    .frame(width: 44, height: 44)
                    .overlay(
                        Circle()
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
            }
        }
        .overlay(
            Text(productColor.name)
                .font(.caption2)
                .foregroundColor(.gray)
                .padding(.top, 12)
                .offset(y: 26)
        )
    }
}
