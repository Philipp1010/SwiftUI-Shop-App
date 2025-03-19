//
//  HomeView.swift
//  OnlineShopApp
//
//  Created by Philipp Hermann on 19.12.24.
//

import SwiftUI

struct HomeView: View {
    @ObservedObject var viewModel: ShopViewModel
    @ObservedObject var cartViewModel: CartViewModel
    @ObservedObject var favoritesViewModel: FavoritesViewModel
    @Binding var selectedTab: Tab
    @State private var searchText = ""
    @State private var selectedProduct: Product?  // Für DetailView
    @State private var showingFilters = false
    
    var body: some View {
        VStack(spacing: 16) {
            // Search Bar
            SearchBarView(searchText: $viewModel.searchText)
                .padding(.top, 8)
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    // Slideshow
                    SlideShowView()
                        .cornerRadius(12)
                        .padding(.horizontal)
                    
                    // Categories
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Categories")
                                .font(.title3)
                                .fontWeight(.bold)
                            Spacer()
                        }
                        .padding(.horizontal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(viewModel.categories, id: \.self) { category in
                                    CategoryButton(
                                        title: category.capitalized,
                                        isSelected: category == viewModel.selectedCategory
                                    )
                                    .onTapGesture {
                                        selectCategory(category)
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                    // Brands
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Popular Brands")
                                .font(.title3)
                                .fontWeight(.bold)
                            Spacer()
                            Button("See All") { }
                                .foregroundColor(.gray)
                        }
                        .padding(.horizontal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            LazyHGrid(rows: [GridItem(.flexible())], spacing: 12) {
                                ForEach(viewModel.brands) { brand in
                                    BrandView(brand: brand)
                                }
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 8)
                        }
                    }
                    .padding(.vertical, 8)
                    
                    // New Arrivals
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("New Arrivals")
                                .font(.title3)
                                .fontWeight(.bold)
                            Spacer()
                            Button("See All") { }
                                .foregroundColor(.gray)
                        }
                        .padding(.horizontal)
                        
                        // Products Grid
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 16) {
                            ForEach(viewModel.filteredProducts) { product in
                                ProductCard(
                                    product: product,
                                    viewModel: viewModel,
                                    cartViewModel: cartViewModel
                                )
                                .onTapGesture {
                                    selectedProduct = product
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
        }
        .onAppear {
            if viewModel.products.isEmpty {
                viewModel.loadProducts()
            }
            AnalyticsManager.shared.logScreenView(screenName: "Home")
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    showingFilters = true
                }) {
                    Image(systemName: "line.horizontal.3")
                        .foregroundColor(.black)
                        .font(.title3)
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    selectedTab = .cart
                }) {
                    Image(systemName: "cart")
                        .foregroundColor(.black)
                        .overlay(
                            Group {
                                if cartViewModel.itemCount > 0 {
                                    Text("\(cartViewModel.itemCount)")
                                        .font(.caption2)
                                        .padding(4)
                                        .background(Color.red)
                                        .clipShape(Circle())
                                        .foregroundColor(.white)
                                        .offset(x: 10, y: -10)
                                }
                            }
                        )
                }
            }
        }
        .sheet(item: $selectedProduct) { product in  // DetailView als Sheet
            NavigationView {
                ProductDetailView(
                    product: product,
                    cartViewModel: cartViewModel,
                    favoritesViewModel: favoritesViewModel
                )
            }
        }
        .sheet(isPresented: $showingFilters) {
            FilterView(viewModel: viewModel)
        }
    }
    
    private func selectCategory(_ category: String) {
        viewModel.selectedCategory = category
        AnalyticsManager.shared.logEvent("select_category", parameters: [
            "category_name": category
        ])
    }
}

// Preview
struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {  // Wichtig für Preview
            HomeView(
                viewModel: ShopViewModel(),
                cartViewModel: CartViewModel(),
                favoritesViewModel: FavoritesViewModel(),
                selectedTab: .constant(.home)
            )
        }
    }
}
