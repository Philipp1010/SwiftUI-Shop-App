//
//  UserFavorites.swift
//  OnlineShopApp
//
//  Created by Philipp Hermann on 22.01.25.
//

import FirebaseFirestore

/// Repräsentiert die Favoritenliste eines Benutzers
struct UserFavorites: Codable {
    @DocumentID var id: String?    // Firestore Document ID (entspricht der User ID)
    var productIds: [Int] = []    // Liste der favorisierten Produkt-IDs
    
    /// Prüft, ob ein Produkt in den Favoriten ist
    /// - Parameter productId: ID des zu prüfenden Produkts
    /// - Returns: true wenn das Produkt in den Favoriten ist
    func contains(_ productId: Int) -> Bool {
        productIds.contains(productId)
    }
}
