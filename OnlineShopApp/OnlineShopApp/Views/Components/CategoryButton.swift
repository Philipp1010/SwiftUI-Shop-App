//
//  CategoryButton.swift
//  OnlineShopApp
//
//  Created by Philipp Hermann on 19.12.24.
//

import SwiftUI

struct CategoryButton: View {
    let title: String
    let isSelected: Bool
    
    var body: some View {
        Text(title)
            .font(.subheadline)
            .fontWeight(.medium)
            .padding(.horizontal, 20)
            .padding(.vertical, 8)
            .background(isSelected ? Color.black : Color.clear)
            .foregroundColor(isSelected ? .white : .black)
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(isSelected ? Color.clear : Color.gray.opacity(0.3), lineWidth: 1)
            )
    }
}

#Preview("Category") {
    VStack {
        CategoryButton(title: "Running", isSelected: true)
        CategoryButton(title: "Training", isSelected: false)
    }
    .padding()
}
