//
//  TabButton.swift
//  OnlineShopApp
//
//  Created by Philipp Hermann on 19.12.24.
//

import SwiftUI

struct TabButton: View {
    let title: String
    let imageName: String
    let isSelected: Bool
    let badgeCount: Int?
    let action: () -> Void
    
    init(
        title: String,
        imageName: String,
        isSelected: Bool,
        badgeCount: Int? = nil,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.imageName = imageName
        self.isSelected = isSelected
        self.badgeCount = badgeCount
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                ZStack {
                    Image(systemName: isSelected ? "\(imageName).fill" : imageName)
                        .font(.system(size: 24))
                    
                    if let count = badgeCount, count > 0 {
                        Text("\(count)")
                            .font(.system(size: 12))
                            .foregroundColor(.white)
                            .padding(4)
                            .background(Color.red)
                            .clipShape(Circle())
                            .offset(x: 10, y: -10)
                    }
                }
                
                Text(title)
                    .font(.caption2)
            }
            .foregroundColor(isSelected ? .black : .gray)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    TabButton(
        title: "Warenkorb",
        imageName: "bag",
        isSelected: true,
        badgeCount: 2
    ) {}
}
