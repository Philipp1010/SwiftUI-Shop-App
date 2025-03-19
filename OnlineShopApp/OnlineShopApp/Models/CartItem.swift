//
//  CartItem.swift
//  OnlineShopApp
//
//  Created by Philipp Hermann on 19.12.24.
//

import Foundation

/// Repräsentiert ein Produkt im Warenkorb mit Menge
struct CartItem: Identifiable, Codable {
    let id = UUID()
    let product: Product                // Das ausgewählte Produkt
    var quantity: Int                   // Bestellmenge des Produkts
    
    enum CodingKeys: String, CodingKey {
        case product, quantity
    }
}
