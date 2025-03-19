//
//  CartViewModel.swift
//  OnlineShopApp
//
//  Created by Philipp Hermann on 19.12.24.
//

import Foundation

/// ViewModel für die Verwaltung des Warenkorbs und der Bestellungen
@MainActor
class CartViewModel: ObservableObject {
    /// Aktuelle Produkte im Warenkorb mit Mengen
    @Published var cartItems: [CartItem] = []
    
    /// Bestellhistorie des Benutzers
    @Published var orderHistory: [ShopModels.Order] = []
    
    /// Produktbewertungen
    @Published var reviews: [Review] = []
    
    /// Fehlermeldung
    @Published var error: String?
    
    // Lieferadresse
    @Published var deliveryName = ""
    @Published var deliveryEmail = ""
    @Published var deliveryAddress = ""
    @Published var deliveryCity = ""
    @Published var deliveryZip = ""
    
    // Zahlungsinformationen
    @Published var cardNumber = ""
    @Published var cardHolder = ""
    @Published var expiryDate = ""
    @Published var cvv = ""
    
    /// Initialisiert den ViewModel und lädt Warenkorb und Bestellhistorie
    init() {
        Task {
            await loadCart()
            await loadOrderHistory()
        }
    }
    
    /// Lädt den gespeicherten Warenkorb aus Firebase
    /// - Note: Wird beim Start und nach Login aufgerufen
    func loadCart() async {
        do {
            cartItems = try await FirebaseManager.shared.loadCart()
        } catch {
            print("Error loading cart: \(error)")
        }
    }
    
    /// Speichert den aktuellen Warenkorb in Firebase
    /// - Note: Wird nach jeder Änderung am Warenkorb aufgerufen
    private func saveCart() {
        Task {
            do {
                try await FirebaseManager.shared.saveCart(items: cartItems)
            } catch {
                print("Error saving cart: \(error)")
            }
        }
    }
    
    /// Gesamtanzahl der Produkte im Warenkorb
    var itemCount: Int {
        cartItems.reduce(0) { $0 + $1.quantity }
    }
    
    /// Gesamtbetrag aller Produkte im Warenkorb
    var total: Double {
        cartItems.reduce(0.0) { result, item in
            result + (item.product.price * Double(item.quantity))
        }
    }
    
    /// Fügt ein Produkt zum Warenkorb hinzu oder erhöht die Menge
    /// - Parameter product: Das hinzuzufügende Produkt
    /// - Note: Trackt das Event in Analytics
    func addToCart(product: Product) {
        if let index = cartItems.firstIndex(where: { $0.product.id == product.id }) {
            cartItems[index].quantity += 1
            AnalyticsManager.shared.logAddToCart(product: product, quantity: cartItems[index].quantity)
        } else {
            cartItems.append(CartItem(product: product, quantity: 1))
            AnalyticsManager.shared.logAddToCart(product: product, quantity: 1)
        }
        saveCart()
    }
    
    /// Entfernt ein Produkt aus dem Warenkorb oder reduziert die Menge
    /// - Parameter product: Das zu entfernende Produkt
    func removeFromCart(product: Product) {
        if let index = cartItems.firstIndex(where: { $0.product.id == product.id }) {
            if cartItems[index].quantity > 1 {
                cartItems[index].quantity -= 1
            } else {
                cartItems.remove(at: index)
            }
            saveCart()
        }
    }
    
    /// Lädt die Bestellhistorie des Benutzers
    func loadOrderHistory() async {
        do {
            orderHistory = try await FirebaseManager.shared.loadOrderHistory()
        } catch {
            print("Error loading order history: \(error)")
        }
    }
    
    /// Leert den Warenkorb vollständig
    func clearCart() {
        cartItems = []
        saveCart()
    }
    
    /// Validiert alle Eingaben für die Bestellung
    /// - Returns: true wenn alle Eingaben gültig sind
    func validateOrder() -> Bool {
        error = nil
        
        // Name Validierung
        if deliveryName.isEmpty {
            error = "Bitte geben Sie einen Namen ein"
            return false
        }
        let nameRegex = "^[A-Za-zÄäÖöÜüß\\s]+$"
        if !deliveryName.matches(pattern: nameRegex) {
            error = "Der Name darf nur Buchstaben enthalten"
            return false
        }
        
        // Email Validierung
        if deliveryEmail.isEmpty {
            error = "Bitte geben Sie eine E-Mail-Adresse ein"
            return false
        }
        if !deliveryEmail.isValidEmail {
            error = "Bitte geben Sie eine gültige E-Mail-Adresse ein"
            return false
        }
        
        // Adresse Validierung
        if deliveryAddress.isEmpty {
            error = "Bitte geben Sie eine Adresse ein"
            return false
        }
        
        // Stadt Validierung
        if deliveryCity.isEmpty {
            error = "Bitte geben Sie eine Stadt ein"
            return false
        }
        
        // PLZ Validierung
        if deliveryZip.isEmpty {
            error = "Bitte geben Sie eine PLZ ein"
            return false
        }
        if !deliveryZip.allSatisfy({ $0.isNumber }) || deliveryZip.count != 5 {
            error = "Bitte geben Sie eine gültige PLZ ein (5 Ziffern)"
            return false
        }
        
        // Kartennummer Validierung
        if cardNumber.isEmpty {
            error = "Bitte geben Sie eine Kartennummer ein"
            return false
        }
        let cleanedCardNumber = cardNumber.withoutSpaces
        if !cleanedCardNumber.allSatisfy({ $0.isNumber }) {
            error = "Die Kartennummer darf nur Ziffern enthalten"
            return false
        }
        if cleanedCardNumber.count != 16 {
            error = "Die Kartennummer muss 16 Ziffern enthalten"
            return false
        }
        
        // Karteninhaber Validierung
        if cardHolder.isEmpty {
            error = "Bitte geben Sie den Karteninhaber ein"
            return false
        }
        
        // Ablaufdatum Validierung
        if expiryDate.isEmpty {
            error = "Bitte geben Sie das Ablaufdatum ein"
            return false
        }
        if !expiryDate.matches(pattern: "^(0[1-9]|1[0-2])/([0-9]{2})$") {
            error = "Bitte geben Sie ein gültiges Ablaufdatum ein (MM/YY)"
            return false
        }
        
        // CVV Validierung
        if cvv.isEmpty {
            error = "Bitte geben Sie die CVV-Nummer ein"
            return false
        }
        if !cvv.allSatisfy({ $0.isNumber }) {
            error = "Die CVV-Nummer darf nur Ziffern enthalten"
            return false
        }
        if cvv.count != 3 {
            error = "Die CVV-Nummer muss 3 Ziffern enthalten"
            return false
        }
        
        return true
    }
    
    /// Bestellung abschließen
    func submitOrder(_ order: ShopModels.Order) async {
        error = nil
        
        do {
            try await FirebaseManager.shared.saveOrder(order)
            orderHistory.append(order)
            clearCart()
            resetForm()
        } catch {
            self.error = "Fehler beim Speichern der Bestellung"
        }
    }
    
    // Formular zurücksetzen
    private func resetForm() {
        deliveryName = ""
        deliveryEmail = ""
        deliveryAddress = ""
        deliveryCity = ""
        deliveryZip = ""
        cardNumber = ""
        cardHolder = ""
        expiryDate = ""
        cvv = ""
    }
}

/// Repräsentiert eine Produktbewertung
struct Review: Identifiable {
    let id: String           // Eindeutige Review-ID
    let productId: Int       // ID des bewerteten Produkts
    let rating: Int          // Bewertung (1-5 Sterne)
    let comment: String      // Bewertungstext
    let date: Date          // Datum der Bewertung
}
