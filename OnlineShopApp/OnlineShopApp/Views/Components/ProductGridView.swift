//
//  ProductGridView.swift
//  OnlineShopApp
//
//  Created by Philipp Hermann on 19.12.24.
//

import SwiftUI

struct ProductGridView: View {
    let products: [Product]
    @ObservedObject var viewModel: ShopViewModel
    @ObservedObject var cartViewModel: CartViewModel
    
    var body: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 16) {
            ForEach(products) { product in
                ProductCard(
                    product: product,
                    viewModel: viewModel,
                    cartViewModel: cartViewModel
                )
            }
        }
        .padding(.horizontal)
    }
}

#Preview {
    ProductGridView(
        products: [
            Product(
                id: 1,
                title: "Nike Sportswear Club Fleece",
                price: 99.0,
                description: "Comfortable hoodie for everyday wear",
                category: "clothing",
                image: "https://fakestoreapi.com/img/81fPKd-2AYL._AC_SL1500_.jpg",
                rating: Product.Rating(rate: 4.5, count: 120)
            ),
            Product(
                id: 2,
                title: "Nike Windrunner",
                price: 80.0,
                description: "Lightweight running jacket",
                category: "clothing",
                image: "https://fakestoreapi.com/img/71li-ujtlUL._AC_UX679_.jpg",
                rating: Product.Rating(rate: 4.2, count: 85)
            )
        ],
        viewModel: ShopViewModel(),
        cartViewModel: CartViewModel()
    )
}
