//
//  AnalyticsManager.swift
//  OnlineShopApp
//
//  Created by Philipp Hermann on 17.01.25.
//

import FirebaseAnalytics

/// Manager-Klasse für das Tracking von Benutzerverhalten in der App
class AnalyticsManager {
    /// Shared Instance für den globalen Zugriff (Singleton Pattern)
    static let shared = AnalyticsManager()
    
    /// Private Initialisierer verhindert externe Instanziierung
    private init() {}
    
    /// Basis-Logging Funktion für Firebase Analytics Events
    /// - Parameters:
    ///   - name: Name des Events (z.B. "add_to_cart")
    ///   - parameters: Optionale Parameter für zusätzliche Event-Informationen
    /// - Note: Events werden nur im Release-Build gesendet, nicht während der Entwicklung
    func logEvent(_ name: String, parameters: [String: Any]? = nil) {
        // #if !DEBUG
        Analytics.logEvent(name, parameters: parameters)
        // #endif
    }
    
    /// Trackt wenn ein Produkt zum Warenkorb hinzugefügt wird
    /// - Parameters:
    ///   - product: Das hinzugefügte Produkt
    ///   - quantity: Die ausgewählte Menge
    /// - Note: Erfasst Produkt-ID, Name, Menge und Preis
    func logAddToCart(product: Product, quantity: Int) {
        logEvent(AnalyticsEventAddToCart, parameters: [
            AnalyticsParameterItemID: product.id,
            AnalyticsParameterItemName: product.title,
            AnalyticsParameterQuantity: quantity,
            AnalyticsParameterPrice: product.price
        ])
    }
    
    /// Trackt Seitenaufrufe in der App
    /// - Parameter screenName: Name des aufgerufenen Screens
    /// - Note: Ermöglicht Analyse der Nutzernavigation
    func logScreenView(screenName: String) {
        logEvent(AnalyticsEventScreenView, parameters: [
            AnalyticsParameterScreenName: screenName
        ])
    }
    
    /// Trackt eine erfolgreiche Bestellung/Transaktion
    /// - Parameters:
    ///   - orderId: Eindeutige Bestellnummer
    ///   - items: Gekaufte Produkte mit Mengen
    ///   - total: Gesamtbetrag der Bestellung
    ///   - currency: Währung (Standard: USD)
    /// - Note: Wichtig für Umsatzanalyse und Conversion-Tracking
    func logPurchase(orderId: String, items: [CartItem], total: Double, currency: String = "USD") {
        let items = items.map { cartItem in
            [
                AnalyticsParameterItemID: cartItem.product.id,
                AnalyticsParameterItemName: cartItem.product.title,
                AnalyticsParameterQuantity: cartItem.quantity,
                AnalyticsParameterPrice: cartItem.product.price
            ] as [String : Any]
        }
        
        logEvent(AnalyticsEventPurchase, parameters: [
            AnalyticsParameterTransactionID: orderId,
            AnalyticsParameterValue: total,
            AnalyticsParameterCurrency: currency,
            AnalyticsParameterItems: items
        ])
    }
    
    /// Trackt Suchvorgänge in der App
    /// - Parameter searchTerm: Der eingegebene Suchbegriff
    func logSearch(searchTerm: String) {
        logEvent(AnalyticsEventSearch, parameters: [
            AnalyticsParameterSearchTerm: searchTerm
        ])
    }
    
    /// Trackt wenn ein Produkt zur Wunschliste hinzugefügt wird
    /// - Parameter product: Das zur Wunschliste hinzugefügte Produkt
    func logAddToWishlist(product: Product) {
        logEvent(AnalyticsEventAddToWishlist, parameters: [
            AnalyticsParameterItemID: product.id,
            AnalyticsParameterItemName: product.title,
            AnalyticsParameterPrice: product.price
        ])
    }
}
