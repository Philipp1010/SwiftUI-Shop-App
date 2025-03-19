//
//  FavoritesView.swift
//  OnlineShopApp
//
//  Created by Philipp Hermann on 19.12.24.
//

import SwiftUI

struct FavoritesView: View {
    @ObservedObject var favoritesViewModel: FavoritesViewModel
    @ObservedObject var cartViewModel: CartViewModel
    @State private var scale: CGFloat = 1.0
    let timer = Timer.publish(every: 1.0, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack(spacing: 0) {
            // Pulsierendes Herz
            Image(systemName: "heart.fill")
                .font(.title)
                .foregroundColor(.red)
                .scaleEffect(scale)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .onReceive(timer) { _ in
                    withAnimation(.easeInOut(duration: 0.5)) {
                        scale = scale == 1.0 ? 1.2 : 1.0
                    }
                }
            
            if favoritesViewModel.favoriteItems.isEmpty {
                Spacer()
                Text("Keine Favoriten vorhanden")
                    .foregroundColor(.gray)
                Spacer()
            } else {
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(favoritesViewModel.favoriteItems) { product in
                            FavoriteItemRow(
                                product: product,
                                favoritesViewModel: favoritesViewModel,
                                cartViewModel: cartViewModel
                            )
                        }
                    }
                    .padding()
                }
            }
        }
    }
}

struct FavoriteItemRow: View {
    let product: Product
    @ObservedObject var favoritesViewModel: FavoritesViewModel
    @ObservedObject var cartViewModel: CartViewModel
    @State private var showDetail = false
    
    var body: some View {
        HStack(spacing: 12) {
            AsyncImage(url: URL(string: product.image)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding(8)
            } placeholder: {
                ProgressView()
            }
            .frame(width: 80, height: 80)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(color: .black.opacity(0.1), radius: 2)
            
            // Product Info
            VStack(alignment: .leading, spacing: 4) {
                Text(product.title)
                    .font(.headline)
                    .lineLimit(2)
                
                Text("$\(String(format: "%.2f", product.price))")
                    .fontWeight(.semibold)
                
                // Rating
                HStack {
                    ForEach(0..<5) { index in
                        Image(systemName: index < Int(product.rating.rate) ? "star.fill" : "star")
                            .foregroundColor(.yellow)
                            .font(.system(size: 10))
                    }
                    Text("(\(product.rating.count))")
                        .foregroundColor(.gray)
                        .font(.caption)
                }
            }
            
            Spacer()
            
            Button(action: {
                favoritesViewModel.removeFromFavorites(product: product)
            }) {
                Image(systemName: "heart.fill")
                    .foregroundColor(.red)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5)
        .onTapGesture {
            showDetail = true
        }
        .sheet(isPresented: $showDetail) {
            NavigationView {
                ProductDetailView(
                    product: product,
                    cartViewModel: cartViewModel,
                    favoritesViewModel: favoritesViewModel
                )
            }
        }
    }
}

#Preview {
    NavigationView {
        FavoritesView(
            favoritesViewModel: FavoritesViewModel(),
            cartViewModel: CartViewModel()
        )
    }
}

#Preview("Favorites") {
    FavoritesView(
        favoritesViewModel: FavoritesViewModel(),
        cartViewModel: CartViewModel()
    )
}
