//
//  ShopModels.swift
//  OnlineShopApp
//
//  Created by Philipp Hermann on 17.01.25.
//

import Foundation
import FirebaseFirestore

enum ShopModels {
    /// Repräsentiert eine Bestellung im System
    struct Order: Identifiable, Codable {
        let id: String                // Eindeutige Bestellnummer
        let items: [CartItem]         // Bestellte Produkte mit Mengen
        let date: Date                // Bestelldatum
        let total: Double             // Gesamtbetrag der Bestellung
        let status: String            // Status (z.B. "Processing", "Shipped")
        let shipping: ShippingDetails // Lieferadresse und Kontaktdaten
        
        struct ShippingDetails: Codable {
            let name: String    // Name des Empfängers
            let email: String   // Kontakt-Email
            let address: String // Straße und Hausnummer
            let city: String    // Stadt
            let zip: String     // Postleitzahl
            let cardNumber: String  // Nur letzte 4 Ziffern
            let cardHolder: String
        }
    }
}

/// Konvertiert eine Order in ein Firebase-kompatibles Dictionary Format
/// Wandelt die Order-Struktur in ein Dictionary um, das in Firestore gespeichert werden kann
/// - Returns: Ein Dictionary mit allen Order-Daten im Firestore-Format
extension ShopModels.Order {
    func asDictionary() -> [String: Any] {
        return [
            "id": id,
            "date": date,
            "items": items.map { item in
                [
                    "product": [
                        "id": item.product.id,
                        "title": item.product.title,
                        "price": item.product.price,
                        "image": item.product.image
                    ],
                    "quantity": item.quantity
                ]
            },
            "total": total,
            "status": status,
            "shipping": [
                "name": shipping.name,
                "email": shipping.email,
                "address": shipping.address,
                "city": shipping.city,
                "zip": shipping.zip,
                "cardNumber": shipping.cardNumber,
                "cardHolder": shipping.cardHolder
            ]
        ]
    }
}
