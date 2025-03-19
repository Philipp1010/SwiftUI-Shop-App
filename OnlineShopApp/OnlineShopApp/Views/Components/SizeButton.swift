//
//  SizeButton.swift
//  OnlineShopApp
//
//  Created by Philipp Hermann on 02.01.25.
//

import SwiftUI

struct SizeButton: View {
    let size: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(size)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(isSelected ? .white : .black)
                .frame(width: 70, height: 44)
                .background(isSelected ? Color.black : Color.white)
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray.opacity(0.3), lineWidth: isSelected ? 0 : 1)
                )
        }
    }
}
