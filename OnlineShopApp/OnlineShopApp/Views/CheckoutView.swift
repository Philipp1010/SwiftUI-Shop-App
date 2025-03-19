//
//  CheckoutView.swift
//  OnlineShopApp
//
//  Created by Philipp Hermann on 17.01.25.
//

import SwiftUI
import FirebaseAnalytics

struct CheckoutView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var cartViewModel: CartViewModel
    @State private var showingConfirmation = false
    @State private var isProcessing = false
    @State private var error: String?
    
    // Form States
    @State private var email = ""
    @State private var name = ""
    @State private var address = ""
    @State private var city = ""
    @State private var zip = ""
    @State private var cardNumber = ""
    @State private var expiryDate = ""
    @State private var cvv = ""
    @State private var cardHolder = ""
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Bestellübersicht
                    GroupBox {
                        VStack(spacing: 16) {
                            // Header
                            HStack {
                                Text("Produkte")
                                    .foregroundColor(.gray)
                                Spacer()
                                Text("Menge")
                                    .foregroundColor(.gray)
                                Text("Preis")
                                    .foregroundColor(.gray)
                                    .frame(width: 80, alignment: .trailing)
                            }
                            .font(.subheadline)
                            
                            Divider()
                            
                            // Produkte
                            ForEach(cartViewModel.cartItems) { item in
                                HStack(alignment: .center) {
                                    // Produktbild und Name
                                    HStack {
                                        AsyncImage(url: URL(string: item.product.image)) { image in
                                            image
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .padding(8)
                                        } placeholder: {
                                            ProgressView()
                                        }
                                        .frame(width: 40, height: 40)
                                        .background(Color.white)
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                        .shadow(color: .black.opacity(0.1), radius: 2)
                                        
                                        Text(item.product.title)
                                            .lineLimit(2)
                                            .font(.subheadline)
                                    }
                                    
                                    Spacer()
                                    
                                    // Menge
                                    Text("\(item.quantity)x")
                                        .foregroundColor(.gray)
                                    
                                    // Preis
                                    Text("$\(String(format: "%.2f", item.product.price))")
                                        .frame(width: 80, alignment: .trailing)
                                        .fontWeight(.medium)
                                }
                                
                                if item.id != cartViewModel.cartItems.last?.id {
                                    Divider()
                                }
                            }
                            
                            // Zusammenfassung
                            VStack(spacing: 12) {
                                Divider()
                                    .padding(.vertical, 4)
                                
                                HStack {
                                    Text("Zwischensumme")
                                        .foregroundColor(.gray)
                                    Spacer()
                                    Text("$\(String(format: "%.2f", cartViewModel.total))")
                                        .frame(width: 80, alignment: .trailing)
                                }
                                
                                HStack {
                                    Text("Versand")
                                        .foregroundColor(.gray)
                                    Spacer()
                                    Text("Kostenlos")
                                        .foregroundColor(.green)
                                        .frame(width: 80, alignment: .trailing)
                                }
                                
                                Divider()
                                
                                HStack {
                                    Text("Gesamt")
                                        .font(.headline)
                                    Spacer()
                                    Text("$\(String(format: "%.2f", cartViewModel.total))")
                                        .font(.headline)
                                        .frame(width: 80, alignment: .trailing)
                                }
                            }
                        }
                        .padding(.vertical, 8)
                    } label: {
                        Text("Bestellübersicht")
                            .font(.headline)
                    }
                    
                    // Lieferadresse
                    GroupBox {
                        VStack(spacing: 16) {
                            CustomTextField(
                                text: $name,
                                placeholder: "Name",
                                icon: "person",
                                formatter: { text in
                                    // Ersten Buchstaben jedes Wortes groß schreiben
                                    text.split(separator: " ")
                                        .map { $0.prefix(1).uppercased() + $0.dropFirst().lowercased() }
                                        .joined(separator: " ")
                                }
                            )
                            CustomTextField(
                                text: $email,
                                placeholder: "E-Mail",
                                icon: "envelope",
                                formatter: { $0.formatAsEmail() }
                            )
                            CustomTextField(
                                text: $address,
                                placeholder: "Adresse",
                                icon: "house",
                                formatter: { text in
                                    // Ersten Buchstaben groß schreiben
                                    text.prefix(1).uppercased() + text.dropFirst()
                                }
                            )
                            CustomTextField(
                                text: $city,
                                placeholder: "Stadt",
                                icon: "building",
                                formatter: { text in
                                    // Ersten Buchstaben groß schreiben
                                    text.prefix(1).uppercased() + text.dropFirst()
                                }
                            )
                            CustomTextField(
                                text: $zip,
                                placeholder: "PLZ",
                                icon: "location",
                                formatter: { $0 }  // PLZ unverändert lassen
                            )
                        }
                    } label: {
                        Text("Lieferadresse")
                            .font(.headline)
                    }
                    
                    // Kreditkarte
                    GroupBox {
                        CreditCardView(
                            cardNumber: $cardNumber,
                            cardHolder: $cardHolder,
                            expiryDate: $expiryDate,
                            cvv: $cvv
                        )
                    } label: {
                        Text("Zahlungsinformationen")
                            .font(.headline)
                    }
                    
                    // Kaufen Button mit Fehlermeldung
                    VStack(spacing: 16) {
                        if let error = cartViewModel.error {
                            Text(error)
                                .foregroundColor(.red)
                                .font(.caption)
                                .padding(.horizontal)
                                .padding(.bottom, 4)
                        }
                        
                        Button(action: validateAndProcessOrder) {
                            if isProcessing {
                                EmptyView()
                            } else {
                                HStack {
                                    Image(systemName: "cart.badge.checkmark")
                                    Text("Jetzt kaufen")
                                        .fontWeight(.medium)
                                    Text("\(String(format: "%.2f", cartViewModel.total))$")
                                        .fontWeight(.bold)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: !isFormValid ? [.gray.opacity(0.3)] : [Color.blue]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .foregroundColor(isFormValid ? .white : .gray)
                                .cornerRadius(8)
                            }
                        }
                        .disabled(!isFormValid || isProcessing)
                        .padding(.horizontal, 30)
                        .padding(.top, 8)
                    }
                    .frame(maxWidth: .infinity, maxHeight: isProcessing ? .infinity : nil)
                    .animation(.spring(), value: isProcessing)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 16)
                }
                .padding()
            }
            .overlay {
                if isProcessing {
                    ZStack {
                        // Hintergrund-Overlay
                        Color.black.opacity(0.3)
                            .edgesIgnoringSafeArea(.all)
                            .transition(.opacity)
                        
                        // Animation
                        BuyLoadingAnimation()
                            .transition(.scale.combined(with: .opacity))
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Abbrechen") {
                        dismiss()
                    }
                }
            }
            .alert("Bestellung erfolgreich!", isPresented: $showingConfirmation) {
                Button("OK") {
                    cartViewModel.clearCart()
                    dismiss()
                }
            } message: {
                Text("Vielen Dank für Ihren Einkauf!")
            }
            .onAppear {
                AnalyticsManager.shared.logScreenView(screenName: "Checkout")
            }
        }
    }
    
    private var isFormValid: Bool {
        !name.isEmpty && !email.isEmpty && !address.isEmpty &&
        !city.isEmpty && !zip.isEmpty && !cardNumber.isEmpty &&
        !cardHolder.isEmpty && !expiryDate.isEmpty && !cvv.isEmpty
    }
    
    private func validateAndProcessOrder() {
        // Übertrage die Werte ins ViewModel
        cartViewModel.deliveryName = name
        cartViewModel.deliveryEmail = email
        cartViewModel.deliveryAddress = address
        cartViewModel.deliveryCity = city
        cartViewModel.deliveryZip = zip
        cartViewModel.cardNumber = cardNumber
        cartViewModel.cardHolder = cardHolder
        cartViewModel.expiryDate = expiryDate
        cartViewModel.cvv = cvv
        
        // Validiere im ViewModel
        if cartViewModel.validateOrder() {
            processOrder()
        } else {
            error = cartViewModel.error
        }
    }
    
    private func processOrder() {
        isProcessing = true
        
        let workItem = DispatchWorkItem {
            let shippingDetails = ShopModels.Order.ShippingDetails(
                name: name,
                email: email,
                address: address,
                city: city,
                zip: zip,
                cardNumber: String(cardNumber.suffix(4)),
                cardHolder: cardHolder
            )
            
            let order = ShopModels.Order(
                id: UUID().uuidString,
                items: cartViewModel.cartItems,
                date: Date(),
                total: cartViewModel.total,
                status: "Neu",
                shipping: shippingDetails
            )
            
            Task {
                await cartViewModel.submitOrder(order)
                isProcessing = false
                showingConfirmation = true
                
                // Purchase Event - Wichtig: Der Wert muss als NSNumber gesendet werden
                AnalyticsManager.shared.logPurchase(
                    orderId: order.id,
                    items: order.items,
                    total: order.total
                )
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: workItem)
    }
}

#Preview {
    CheckoutView(cartViewModel: {
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
                quantity: 2
            ),
            CartItem(
                product: Product(
                    id: 2,
                    title: "Adidas Ultraboost",
                    price: 179.99,
                    description: "Experience epic energy with these running shoes",
                    category: "shoes",
                    image: "https://fakestoreapi.com/img/71li-ujtlUL._AC_UX679_.jpg",
                    rating: Product.Rating(rate: 4.8, count: 89)
                ),
                quantity: 1
            )
        ]
        return vm
    }())
}
