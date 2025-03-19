//
//  CustomTabBar.swift
//  OnlineShopApp
//
//  Created by Philipp Hermann on 19.12.24.
//

import SwiftUI

enum Tab: String, CaseIterable {
    case home = "house.fill"
    case favorites = "heart.fill"
    case cart = "cart.fill"
    case profile = "person.fill"
    
    var title: String {
        switch self {
        case .home: return "Home"
        case .favorites: return "Favoriten"
        case .cart: return "Warenkorb"
        case .profile: return "Profil"
        }
    }
}

struct CustomTabBar: View {
    @Binding var selectedTab: Tab
    let cartItemCount: Int
    
    var body: some View {
        HStack(spacing: 0) {
            TabButton(
                title: "Home",
                imageName: "house",
                isSelected: selectedTab == .home
            ) {
                selectedTab = .home
            }
            
            TabButton(
                title: "Favoriten",
                imageName: "heart",
                isSelected: selectedTab == .favorites
            ) {
                selectedTab = .favorites
            }
            
            TabButton(
                title: "Warenkorb",
                imageName: "cart",
                isSelected: selectedTab == .cart,
                badgeCount: cartItemCount
            ) {
                selectedTab = .cart
            }
            
            TabButton(
                title: "Profil",
                imageName: "person",
                isSelected: selectedTab == .profile
            ) {
                selectedTab = .profile
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.15), radius: 5, x: 0, y: -2)
    }
}

#Preview {
    CustomTabBar(selectedTab: .constant(.home), cartItemCount: 2)
}
