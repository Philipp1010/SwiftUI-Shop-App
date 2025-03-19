//
//  Product.swift
//  OnlineShopApp
//
//  Created by Philipp Hermann on 19.12.24.
//

import Foundation

/// Repräsentiert ein Produkt im Shop
struct Product: Identifiable, Codable {
    let id: Int
    let title: String       // Name des Produkts
    let price: Double       // Preis in USD
    let description: String // Detaillierte Produktbeschreibung
    let category: String    // Kategorie (z.B. "clothing", "shoes")
    let image: String       // URL zum Produktbild
    let rating: Rating      // Bewertungen des Produkts
    
    /// Bewertungsinformationen für ein Produkt
    struct Rating: Codable {
        let rate: Double  // Durchschnittliche Bewertung (1-5 Sterne)
        let count: Int    // Anzahl der abgegebenen Bewertungen
    }
}
