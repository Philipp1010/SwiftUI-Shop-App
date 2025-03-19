//
//  FirebaseManager.swift
//  OnlineShopApp
//
//  Created by Philipp Hermann on 14.01.25.
//

import FirebaseCore
import FirebaseFirestore
import FirebaseAuth

/// Manager-Klasse für alle Firebase-Operationen (Firestore & Auth)
class FirebaseManager {
    /// Shared Instance für den globalen Zugriff (Singleton Pattern)
    static let shared = FirebaseManager()
    
    /// Firestore Datenbank-Referenz
    let db = Firestore.firestore()
    
    /// Referenz zur Users Collection in Firestore
    private var userRef: CollectionReference {
        db.collection("users")
    }
    
    /// ID des aktuell eingeloggten Benutzers
    var currentUserId: String? {
        Auth.auth().currentUser?.uid
    }
    
    /// Speichert die Favoriten eines Benutzers
    /// - Parameter products: Array der zu speichernden Produkte
    /// - Throws: FirebaseError wenn das Speichern fehlschlägt
    /// - Note: Aktualisiert nur die Favoriten, andere Daten bleiben erhalten (merge: true)
    func saveFavorites(products: [Product]) async throws {
        guard let userId = currentUserId else { return }
        try await userRef.document(userId).setData([
            "favorites": products.map { $0.asDictionary() }
        ], merge: true)
    }
    
    /// Lädt die Favoriten des aktuellen Benutzers
    /// - Returns: Array der gespeicherten Favoriten-Produkte
    /// - Throws: FirebaseError wenn das Laden fehlschlägt
    func loadFavorites() async throws -> [Product] {
        guard let userId = currentUserId else { return [] }
        let document = try await userRef.document(userId).getDocument()
        guard let data = document.data(),
              let favoritesData = data["favorites"] as? [[String: Any]] else {
            return []
        }
        
        return favoritesData.compactMap { dict in
            guard let id = dict["id"] as? Int,
                  let title = dict["title"] as? String,
                  let price = dict["price"] as? Double,
                  let description = dict["description"] as? String,
                  let category = dict["category"] as? String,
                  let image = dict["image"] as? String,
                  let ratingDict = dict["rating"] as? [String: Any],
                  let rate = ratingDict["rate"] as? Double,
                  let count = ratingDict["count"] as? Int else {
                return nil
            }
            
            return Product(
                id: id,
                title: title,
                price: price,
                description: description,
                category: category,
                image: image,
                rating: Product.Rating(rate: rate, count: count)
            )
        }
    }
    
    /// Speichert den Warenkorb eines Benutzers
    /// - Parameter items: Array der Warenkorb-Items
    /// - Throws: FirebaseError wenn das Speichern fehlschlägt
    /// - Note: Aktualisiert nur den Warenkorb, andere Daten bleiben erhalten
    func saveCart(items: [CartItem]) async throws {
        guard let userId = currentUserId else { return }
        try await userRef.document(userId).setData([
            "cart": items.map { [
                "product": [
                    "id": $0.product.id,
                    "title": $0.product.title,
                    "price": $0.product.price,
                    "description": $0.product.description,
                    "category": $0.product.category,
                    "image": $0.product.image,
                    "rating": [
                        "rate": $0.product.rating.rate,
                        "count": $0.product.rating.count
                    ]
                ],
                "quantity": $0.quantity
            ] }
        ], merge: true)
    }
    
    /// Lädt den Warenkorb des aktuellen Benutzers
    /// - Returns: Array der gespeicherten Warenkorb-Items
    /// - Throws: FirebaseError wenn das Laden fehlschlägt
    func loadCart() async throws -> [CartItem] {
        guard let userId = currentUserId else { return [] }
        let document = try await userRef.document(userId).getDocument()
        guard let data = document.data(),
              let cartData = data["cart"] as? [[String: Any]] else {
            return []
        }
        
        return cartData.compactMap { dict in
            guard let productDict = dict["product"] as? [String: Any],
                  let quantity = dict["quantity"] as? Int,
                  let id = productDict["id"] as? Int,
                  let title = productDict["title"] as? String,
                  let price = productDict["price"] as? Double,
                  let description = productDict["description"] as? String,
                  let category = productDict["category"] as? String,
                  let image = productDict["image"] as? String,
                  let ratingDict = productDict["rating"] as? [String: Any],
                  let rate = ratingDict["rate"] as? Double,
                  let count = ratingDict["count"] as? Int else {
                return nil
            }
            
            let product = Product(
                id: id,
                title: title,
                price: price,
                description: description,
                category: category,
                image: image,
                rating: Product.Rating(rate: rate, count: count)
            )
            
            return CartItem(product: product, quantity: quantity)
        }
    }
    
    /// Lädt die Bestellhistorie des aktuellen Benutzers
    /// - Returns: Array aller Bestellungen des Benutzers
    /// - Throws: FirebaseError wenn das Laden fehlschlägt
    /// - Note: Sortiert nach Bestelldatum
    func loadOrderHistory() async throws -> [ShopModels.Order] {
        guard let userId = currentUserId else {
            return []
        }
        
        let snapshot = try await userRef
            .document(userId)
            .collection("orders")
            .getDocuments()
        
        return try snapshot.documents.map { document in
            let data = document.data()
            
            // Shipping Details
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
            
            // Items
            let items = (data["items"] as? [[String: Any]] ?? []).map { itemData -> CartItem in
                let productData = itemData["product"] as? [String: Any] ?? [:]
                let product = Product(
                    id: productData["id"] as? Int ?? 0,
                    title: productData["title"] as? String ?? "",
                    price: productData["price"] as? Double ?? 0.0,
                    description: "",
                    category: "",
                    image: productData["image"] as? String ?? "",
                    rating: Product.Rating(rate: 0, count: 0)
                )
                return CartItem(product: product, quantity: itemData["quantity"] as? Int ?? 1)
            }
            
            return ShopModels.Order(
                id: document.documentID,
                items: items,
                date: (data["date"] as? Timestamp)?.dateValue() ?? Date(),
                total: data["total"] as? Double ?? 0.0,
                status: data["status"] as? String ?? "Neu",
                shipping: shipping
            )
        }
    }
    
    /// Speichert eine neue Bestellung
    /// - Parameter order: Die zu speichernde Bestellung
    /// - Throws: FirebaseError wenn das Speichern fehlschlägt
    /// - Note: Erstellt ein neues Dokument in der orders-Subcollection
    func saveOrder(_ order: ShopModels.Order) async throws {
        guard let userId = currentUserId else { return }
        
        let orderData: [String: Any] = [
            "date": Timestamp(date: order.date),
            "items": order.items.map { item in
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
            "total": order.total,
            "status": order.status,
            "shipping": [
                "name": order.shipping.name,
                "email": order.shipping.email,
                "address": order.shipping.address,
                "city": order.shipping.city,
                "zip": order.shipping.zip
            ]
        ]
        
        try await userRef.document(userId)
            .collection("orders")
            .document(order.id)
            .setData(orderData)
    }
}

// MARK: - Helper Extensions

extension Product {
    /// Konvertiert ein Produkt in ein Firebase-kompatibles Dictionary
    func asDictionary() -> [String: Any] {
        return [
            "id": id,
            "title": title,
            "price": price,
            "description": description,
            "category": category,
            "image": image,
            "rating": [
                "rate": rating.rate,
                "count": rating.count
            ]
        ]
    }
}
