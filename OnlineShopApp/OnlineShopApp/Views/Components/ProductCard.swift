//
//  ProductCard.swift
//  OnlineShopApp
//
//  Created by Philipp Hermann on 19.12.24.
//

import SwiftUI

struct ProductCard: View {
    let product: Product
    @ObservedObject var viewModel: ShopViewModel
    @ObservedObject var cartViewModel: CartViewModel
    
    var body: some View {
        VStack(alignment: .leading) {
            // Image
            AsyncImage(url: URL(string: product.image)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } placeholder: {
                ProgressView()
            }
            .frame(height: 180)
            .cornerRadius(12)
            
            // Title
            Text(product.title)
                .font(.system(size: 14, weight: .semibold))
                .lineLimit(2)
            
            // Price
            Text("$\(String(format: "%.2f", product.price))")
                .font(.system(size: 14, weight: .bold))
            
            // Rating
            HStack {
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
                Text(String(format: "%.1f", product.rating.rate))
                Text("(\(product.rating.count))")
                    .foregroundColor(.gray)
            }
            .font(.system(size: 12))
        }
        .padding(12)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 5, y: 2)
    }
}

#Preview {
    ProductCard(
        product: Product(
            id: 1,
            title: "Nike Sportswear Club Fleece",
            price: 99.0,
            description: "Comfortable hoodie for everyday wear",
            category: "clothing",
            image: "https://fakestoreapi.com/img/81fPKd-2AYL._AC_SL1500_.jpg",
            rating: Product.Rating(rate: 4.5, count: 120)
        ),
        viewModel: ShopViewModel(),
        cartViewModel: CartViewModel()
    )
}

#Preview("Product Card") {
    ProductCard(
        product: Product(
            id: 1,
            title: "Nike Sportswear Club Fleece",
            price: 99.0,
            description: "Comfortable hoodie for everyday wear",
            category: "clothing",
            image: "https://fakestoreapi.com/img/81fPKd-2AYL._AC_SL1500_.jpg",
            rating: Product.Rating(rate: 4.5, count: 120)
        ),
        viewModel: ShopViewModel(),
        cartViewModel: CartViewModel()
    )
    .frame(width: 180)
}
