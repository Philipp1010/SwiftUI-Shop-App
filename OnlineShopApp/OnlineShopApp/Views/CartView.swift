//
//  CartView.swift
//  OnlineShopApp
//
//  Created by Philipp Hermann on 19.12.24.
//

import SwiftUI

struct CartView: View {
    @ObservedObject var cartViewModel: CartViewModel
    @State private var selectedProduct: Product?  // Für DetailView
    @State private var showingCheckout = false
    
    var body: some View {
        VStack(spacing: 0) {
            Image(systemName: "cart")
                .font(.title)
                .foregroundColor(.black)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
            
            if cartViewModel.cartItems.isEmpty {
                Spacer()
                Text("Dein Warenkorb ist leer")
                    .foregroundColor(.gray)
                Spacer()
            } else {
                HStack {
                    Text("\(cartViewModel.itemCount) Artikel")
                        .font(.footnote)
                        .fontWeight(.medium)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [.purple.opacity(0.2), .blue.opacity(0.2)]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                        )
                        .foregroundColor(.purple)
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Gesamtsumme")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.black)
                        Text("$\(String(format: "%.2f", cartViewModel.total))")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.gray)
                    }
                }
                .padding()
                .background(Color.white)
                .shadow(color: .black.opacity(0.05), radius: 8, y: 4)
                
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(cartViewModel.cartItems) { item in
                            CartItemRow(
                                item: item,
                                cartViewModel: cartViewModel
                            )
                            .onTapGesture {
                                selectedProduct = item.product
                            }
                        }
                    }
                    .padding()
                    
                    VStack {
                        Button(action: { showingCheckout = true }) {
                            HStack {
                                Image(systemName: "cart.badge.plus")
                                Text("Zur Kasse")
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
                    .background(Color.white)
                }
            }
        }
        .onAppear {
            AnalyticsManager.shared.logScreenView(screenName: "Cart")
        }
        .sheet(item: $selectedProduct) { product in
            NavigationView {
                ProductDetailView(
                    product: product,
                    cartViewModel: cartViewModel,
                    favoritesViewModel: FavoritesViewModel()
                )
            }
        }
        .sheet(isPresented: $showingCheckout) {
            CheckoutView(cartViewModel: cartViewModel)
        }
    }
}

// CartItemRow View
struct CartItemRow: View {
    let item: CartItem
    @ObservedObject var cartViewModel: CartViewModel
    
    var body: some View {
        HStack(spacing: 12) {
            AsyncImage(url: URL(string: item.product.image)) { image in
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
            
            VStack(alignment: .leading, spacing: 4) {
                Text(item.product.title)
                    .font(.headline)
                    .lineLimit(2)
                
                Text("$\(String(format: "%.2f", item.product.price))")
                    .fontWeight(.semibold)
            }
            
            Spacer()
            
            HStack(spacing: 16) {
                Button(action: {
                    cartViewModel.removeFromCart(product: item.product)
                }) {
                    Image(systemName: "minus.circle.fill")
                        .foregroundStyle(.blue)
                }
                
                Text("\(item.quantity)")
                    .fontWeight(.medium)
                    .frame(minWidth: 20)
                
                Button(action: {
                    cartViewModel.addToCart(product: item.product)
                }) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundStyle(.blue)
                }
            }
            .font(.title3)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5)
    }
}

#Preview {
    NavigationView {
        CartView(cartViewModel: {
            let vm = CartViewModel()
            vm.cartItems = [
                CartItem(
                    product: Product(
                        id: 1,
                        title: "Nike Sportswear Club Fleece",
                        price: 99.0,
                        description: "Comfortable hoodie for everyday wear",
                        category: "clothing",
                        image: "https://fakestoreapi.com/img/81fPKd-2AYL._AC_SL1500_.jpg",
                        rating: Product.Rating(rate: 4.5, count: 120)
                    ),
                    quantity: 1
                )
            ]
            return vm
        }())
    }
}

