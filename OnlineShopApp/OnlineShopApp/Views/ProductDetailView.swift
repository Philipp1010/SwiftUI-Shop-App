//
//  ProductDetailView.swift
//  OnlineShopApp
//
//  Created by Philipp Hermann on 19.12.24.
//

import SwiftUI

struct ProductDetailView: View {
    @Environment(\.dismiss) var dismiss
    let product: Product
    @ObservedObject var cartViewModel: CartViewModel
    @ObservedObject var favoritesViewModel: FavoritesViewModel
    @State private var selectedSize = "M"
    @State private var selectedColor = "Schwarz"
    @State private var showingAddToCartAnimation = false
    
    // Verfügbare Größen
    let sizes = ["XS", "S", "M", "L", "XL", "XXL"]
    
    // Verfügbare Farben mit ihren HEX-Codes
    let colors = [
        "Schwarz": Color.black,
        "Weiß": Color.white,
        "Rot": Color.red,
        "Blau": Color.blue,
        "Grau": Color.gray
    ]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Produktbild
                AsyncImage(url: URL(string: product.image)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } placeholder: {
                    ProgressView()
                }
                .frame(maxHeight: 300)
                
                // Produktinfos
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text(product.title)
                            .font(.title2)
                            .fontWeight(.bold)
                        Spacer()
                        
                        // Herz-Button mit Animation
                        Button(action: toggleFavorite) {
                            Image(systemName: favoritesViewModel.isFavorite(product) ? "heart.fill" : "heart")
                                .foregroundColor(favoritesViewModel.isFavorite(product) ? .red : .gray)
                                .font(.title2)
                        }
                        .buttonStyle(BorderlessButtonStyle())
                    }
                    
                    Text("$\(product.price, specifier: "%.2f")")
                        .font(.title3)
                        .foregroundColor(.blue)
                    
                    Text(product.description)
                        .font(.body)
                        .foregroundColor(.secondary)
                    
                    // Bewertungen
                    HStack {
                        ForEach(0..<5) { index in
                            Image(systemName: index < Int(product.rating.rate) ? "star.fill" : "star")
                                .foregroundColor(.yellow)
                        }
                        Text("(\(product.rating.count))")
                            .foregroundColor(.gray)
                    }
                    
                    // Farbauswahl
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 8) {
                            Text("Farbe")
                                .font(.headline)
                            Text("•")
                                .foregroundColor(.gray)
                            Text(selectedColor)
                                .foregroundColor(.gray)
                                .fontWeight(.medium)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.bottom, 4)
                        
                        HStack(spacing: 20) {
                            ForEach(Array(colors.keys.sorted()), id: \.self) { colorName in
                                Button(action: { selectedColor = colorName }) {
                                    ZStack {
                                        Circle()
                                            .fill(colors[colorName] ?? .clear)
                                            .frame(width: 35, height: 35)
                                        
                                        if colorName == "Weiß" {
                                            Circle()
                                                .stroke(Color.gray, lineWidth: 1)
                                                .frame(width: 35, height: 35)
                                        }
                                        
                                        Circle()
                                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                            .frame(width: 35, height: 35)
                                        
                                        if selectedColor == colorName {
                                            Circle()
                                                .stroke(colorName == "Weiß" ? .blue : (colors[colorName] ?? .clear), lineWidth: 2)
                                                .frame(width: 45, height: 45)
                                        }
                                    }
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(.vertical, 8)
                    
                    // Größenauswahl
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 8) {
                            Text("Größe")
                                .font(.headline)
                            Text("•")
                                .foregroundColor(.gray)
                            Text(selectedSize)
                                .foregroundColor(.gray)
                                .fontWeight(.medium)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.bottom, 4)
                        
                        HStack(spacing: 12) {
                            ForEach(sizes, id: \.self) { size in
                                Button(action: { selectedSize = size }) {
                                    Text(size)
                                        .frame(width: 45, height: 45)
                                        .background(selectedSize == size ? Color.blue : Color.gray.opacity(0.2))
                                        .foregroundColor(selectedSize == size ? .white : .black)
                                        .cornerRadius(8)
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(.vertical, 8)
                }
                .padding()
                
                // Kaufen Button
                Button(action: {
                    cartViewModel.addToCart(product: product)
                    AnalyticsManager.shared.logAddToCart(product: product, quantity: 1)
                    withAnimation(.spring()) {
                        showingAddToCartAnimation = true
                    }
                    // Dismiss erst nach der Animation
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.7) {
                        dismiss()
                    }
                }) {
                    HStack {
                        Image(systemName: "cart.badge.plus")
                        Text("In den Warenkorb")
                            .fontWeight(.medium)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                .padding(.horizontal, 30)
                .padding(.top, 8)
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                        Text("Zurück")
                    }
                    .foregroundColor(.blue)
                }
            }
        }
        .onAppear {
            AnalyticsManager.shared.logScreenView(screenName: "Product Detail")
        }
        .overlay {
            AddToCartAnimation(isPresented: $showingAddToCartAnimation)
        }
    }
    
    private func toggleFavorite() {
        withAnimation(.spring(response: 0.3)) {
            if favoritesViewModel.isFavorite(product) {
                favoritesViewModel.removeFromFavorites(product: product)
                AnalyticsManager.shared.logEvent("remove_from_favorites", parameters: [
                    "product_id": product.id,
                    "product_name": product.title
                ])
            } else {
                favoritesViewModel.addToFavorites(product: product)
                let generator = UIImpactFeedbackGenerator(style: .medium)
                generator.impactOccurred()
                
                AnalyticsManager.shared.logEvent("add_to_favorites", parameters: [
                    "product_id": product.id,
                    "product_name": product.title
                ])
            }
        }
    }
}

#Preview {
    NavigationView {
        ProductDetailView(
            product: Product(
                id: 1,
                title: "Nike Sportswear Club Fleece",
                price: 99.0,
                description: "Comfortable hoodie for everyday wear",
                category: "clothing",
                image: "https://fakestoreapi.com/img/81fPKd-2AYL._AC_SL1500_.jpg",
                rating: Product.Rating(rate: 4.5, count: 120)
            ),
            cartViewModel: CartViewModel(),
            favoritesViewModel: FavoritesViewModel()
        )
    }
}
