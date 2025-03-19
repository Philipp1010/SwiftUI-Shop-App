//
//  ContentView.swift
//  OnlineShopApp
//
//  Created by Philipp Hermann on 19.12.24.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = ShopViewModel()
    @StateObject private var cartViewModel = CartViewModel()
    @StateObject private var favoritesViewModel = FavoritesViewModel()
    @State private var selectedTab: Tab = .home
    @GestureState private var dragOffset: CGFloat = 0
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .bottom) {
                TabView(selection: $selectedTab) {
                    HomeView(
                        viewModel: viewModel,
                        cartViewModel: cartViewModel,
                        favoritesViewModel: favoritesViewModel,
                        selectedTab: $selectedTab
                    )
                    .tag(Tab.home)
                    
                    FavoritesView(favoritesViewModel: favoritesViewModel, cartViewModel: cartViewModel)
                        .tag(Tab.favorites)
                    
                    CartView(cartViewModel: cartViewModel)
                        .tag(Tab.cart)
                    
                    ProfileView(
                        favoritesViewModel: favoritesViewModel,
                        cartViewModel: cartViewModel
                    )
                    .tag(Tab.profile)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                
                CustomTabBar(selectedTab: $selectedTab, cartItemCount: cartViewModel.itemCount)
                    .padding(.bottom, 10)
            }
            .simultaneousGesture(
                DragGesture()
                    .updating($dragOffset) { value, state, _ in
                        if abs(value.translation.width) > abs(value.translation.height) {
                            state = value.translation.width
                        }
                    }
                    .onEnded { gesture in
                        if abs(gesture.translation.width) > abs(gesture.translation.height) {
                            let tabs: [Tab] = [.home, .favorites, .cart, .profile]
                            if let currentIndex = tabs.firstIndex(of: selectedTab) {
                                let screenWidth = UIScreen.main.bounds.width
                                let dragThreshold: CGFloat = screenWidth * 0.5
                                
                                if gesture.translation.width > dragThreshold && currentIndex > 0 {
                                    withAnimation {
                                        selectedTab = tabs[currentIndex - 1]
                                    }
                                } else if gesture.translation.width < -dragThreshold && currentIndex < tabs.count - 1 {
                                    withAnimation {
                                        selectedTab = tabs[currentIndex + 1]
                                    }
                                }
                            }
                        }
                    }
            )
            .navigationBarTitleDisplayMode(.inline)
        }
        .navigationViewStyle(.stack)
    }
}

#Preview {
    ContentView()
}
