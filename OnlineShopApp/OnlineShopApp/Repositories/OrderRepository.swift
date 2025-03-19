//
//  OrderRepository.swift
//  OnlineShopApp
//
//  Created by Philipp Hermann on 22.01.25.
//

import Foundation
import FirebaseFirestore

/// Repository für alle Bestellungs-bezogenen Operationen
protocol OrderRepository {
    
    /// Erstellt eine neue Bestellung
    /// - Parameter order: Die zu erstellende Bestellung
    /// - Throws: FirebaseError wenn das Erstellen fehlschlägt
    func createOrder(_ order: ShopModels.Order) async throws
    
    /// Lädt alle Bestellungen eines Benutzers
    /// - Parameter userId: ID des Benutzers dessen Bestellungen geladen werden sollen
    /// - Returns: Array von Bestellungen des Benutzers
    /// - Throws: FirebaseError wenn das Laden fehlschlägt
    func fetchOrders(forUserId userId: String) async throws -> [ShopModels.Order]
    
    /// Aktualisiert den Status einer Bestellung
    /// - Parameters:
    ///   - orderId: ID der zu aktualisierenden Bestellung
    ///   - status: Neuer Status der Bestellung (z.B. "Processing", "Shipped")
    /// - Throws: FirebaseError wenn die Aktualisierung fehlschlägt
    func updateOrderStatus(orderId: String, status: String) async throws
    
    
}

class FirebaseOrderRepository: OrderRepository {
    private let db = Firestore.firestore()
    
    func createOrder(_ order: ShopModels.Order) async throws {
        try await db.collection("orders")
            .document(order.id)
            .setData(order.asDictionary())
    }
    
    func fetchOrders(forUserId userId: String) async throws -> [ShopModels.Order] {
        let snapshot = try await db.collection("users")
            .document(userId)
            .collection("orders")
            .getDocuments()
        
        return try snapshot.documents.map { document in
            try mapDocumentToOrder(document)
        }
    }
    
    func updateOrderStatus(orderId: String, status: String) async throws {
        try await db.collection("orders")
            .document(orderId)
            .setData(["status": status], merge: true)
    }
    
    /// Konvertiert Firestore-Daten in Swift-Objekte
    /// Wandelt es in eine typsichere Order um
    private func mapDocumentToOrder(_ document: DocumentSnapshot) throws -> ShopModels.Order {
        // Basis-Daten aus dem Dokument holen
        let data = document.data() ?? [:]
        let id = document.documentID
        
        // Produkte aus dem Array mappen
        let items = (data["items"] as? [[String: Any]] ?? []).map { itemData -> CartItem in
            let productData = itemData["product"] as? [String: Any] ?? [:]
            let product = Product(
                id: productData["id"] as? Int ?? 0,
                title: productData["title"] as? String ?? "",
                price: productData["price"] as? Double ?? 0.0,
                description: "",  // Nicht in der Order gespeichert
                category: "",     // Nicht in der Order gespeichert
                image: productData["image"] as? String ?? "",
                rating: Product.Rating(rate: 0, count: 0)  // Nicht in der Order gespeichert
            )
            return CartItem(product: product, quantity: itemData["quantity"] as? Int ?? 1)
        }
        
        // Shipping Details mappen
        let shippingData = data["shipping"] as? [String: Any] ?? [:]
        let shipping = ShopModels.Order.ShippingDetails(
            name: shippingData["name"] as? String ?? "",
            email: shippingData["email"] as? String ?? "",
            address: shippingData["address"] as? String ?? "",
            city: shippingData["city"] as? String ?? "",
            zip: shippingData["zip"] as? String ?? "",
            cardNumber: shippingData["cardNumber"] as? String ?? "",
            cardHolder: shippingData["cardHolder"] as? String ?? ""
        )
        
        // Komplette Order zusammenbauen und zurückgeben
        return ShopModels.Order(
            id: id,
            items: items,
            date: (data["date"] as? Timestamp)?.dateValue() ?? Date(),
            total: data["total"] as? Double ?? 0.0,
            status: data["status"] as? String ?? "Neu",
            shipping: shipping
        )
    }
}
