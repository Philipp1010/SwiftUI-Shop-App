//
//  CartRepository.swift
//  OnlineShopApp
//
//  Created by Philipp Hermann on 22.01.25.
//

import Foundation
import FirebaseFirestore

/// Repository für alle Warenkorb-bezogenen Operationen
protocol CartRepository {
    
    /// Speichert den aktuellen Warenkorb eines Benutzers
    /// - Parameters:
    ///   - items: Array von CartItems die gespeichert werden sollen
    ///   - userId: ID des Benutzers dessen Warenkorb gespeichert wird
    /// - Throws: FirebaseError wenn das Speichern fehlschlägt
    func saveCart(items: [CartItem], userId: String) async throws
    
    /// Lädt den Warenkorb eines Benutzers
    /// - Parameter userId: ID des Benutzers dessen Warenkorb geladen werden soll
    /// - Returns: Array von CartItems aus dem Warenkorb
    /// - Throws: FirebaseError wenn das Laden fehlschlägt
    func loadCart(userId: String) async throws -> [CartItem]
    
    /// Leert den Warenkorb eines Benutzers
    /// - Parameter userId: ID des Benutzers dessen Warenkorb geleert werden soll
    /// - Throws: FirebaseError wenn das Löschen fehlschlägt
    func clearCart(userId: String) async throws
}

class FirebaseCartRepository: CartRepository {
    private let db = Firestore.firestore()
    
    func saveCart(items: [CartItem], userId: String) async throws {
        let cartData = items.map { item in
            [
                "productId": item.product.id,
                "quantity": item.quantity
            ]
        }
        
        try await db.collection("users")
            .document(userId)
            .setData(["cart": cartData], merge: true)
    }
    
    func loadCart(userId: String) async throws -> [CartItem] {
        let document = try await db.collection("users")
            .document(userId)
            .getDocument()
        
        guard let data = document.data(),
              let cartData = data["cart"] as? [[String: Any]] else {
            return []
        }
        
        var cartItems: [CartItem] = []
        
        for itemData in cartData {
            guard let productId = itemData["productId"] as? Int,
                  let quantity = itemData["quantity"] as? Int else {
                continue
            }
            
            // Produkt aus der Datenbank laden
            let productDoc = try await db.collection("products")
                .document(String(productId))
                .getDocument()
            
            guard let product = try? productDoc.data(as: Product.self) else {
                continue
            }
            
            let cartItem = CartItem(product: product, quantity: quantity)
            cartItems.append(cartItem)
        }
        
        return cartItems
    }
    
    func clearCart(userId: String) async throws {
        try await db.collection("users")
            .document(userId)
            .setData(["cart": []], merge: true)
    }
}
