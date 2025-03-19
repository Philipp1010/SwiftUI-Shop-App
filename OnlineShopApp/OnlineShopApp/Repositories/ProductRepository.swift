//
//  ProductRepository.swift
//  OnlineShopApp
//
//  Created by Philipp Hermann on 22.01.25.
//

import Foundation
import FirebaseFirestore

/// Repository für alle Produkt-bezogenen Datenbankoperationen
protocol ProductRepository {
    /// Lädt alle verfügbaren Produkte aus der Datenbank
    /// - Returns: Array aller Produkte
    /// - Throws: FirebaseError wenn die Verbindung fehlschlägt oder die Daten nicht gelesen werden können
    func fetchProducts() async throws -> [Product]
    
    /// Lädt ein spezifisches Produkt anhand seiner ID
    /// - Parameter id: Eindeutige ID des zu ladenden Produkts
    /// - Returns: Das gefundene Produkt
    /// - Throws: FirebaseError wenn das Produkt nicht gefunden wird oder die Verbindung fehlschlägt
    func fetchProduct(byId id: Int) async throws -> Product
    
    /// Lädt alle Produkte einer bestimmten Kategorie
    /// - Parameter category: Name der Kategorie (z.B. "clothing", "electronics")
    /// - Returns: Array von Produkten in dieser Kategorie
    /// - Throws: FirebaseError wenn die Kategorie nicht gefunden wird oder die Verbindung fehlschlägt
    func fetchProductsByCategory(_ category: String) async throws -> [Product]
    
    /// Sucht nach Produkten basierend auf einem Suchbegriff
    /// - Parameter query: Suchbegriff für die Produktsuche
    /// - Returns: Array von Produkten, die dem Suchbegriff in Titel, Beschreibung oder Kategorie entsprechen
    /// - Throws: FirebaseError wenn die Suche fehlschlägt oder die Verbindung nicht hergestellt werden kann
    func searchProducts(query: String) async throws -> [Product]
}

class FirebaseProductRepository: ProductRepository {
    private let db = Firestore.firestore()
    
    func fetchProducts() async throws -> [Product] {
        let snapshot = try await db.collection("products").getDocuments()
        return try snapshot.documents.compactMap { doc in
            try doc.data(as: Product.self)
        }
    }
    
    func fetchProduct(byId id: Int) async throws -> Product {
        let snapshot = try await db.collection("products")
            .whereField("id", isEqualTo: id)  // ist eine Firestore-Abfragemethode, die es ermöglicht, Dokumente nach bestimmten Kriterien zu filtern.
            .getDocuments()
        
        guard let document = snapshot.documents.first,
              let product = try? document.data(as: Product.self) else {
            throw NSError(domain: "", code: -1, userInfo: [
                NSLocalizedDescriptionKey: "Produkt nicht gefunden"
            ])
        }
        
        return product
    }
    
    func fetchProductsByCategory(_ category: String) async throws -> [Product] {
        let snapshot = try await db.collection("products")
            .whereField("category", isEqualTo: category)
            .getDocuments()
        
        return try snapshot.documents.compactMap { doc in
            try doc.data(as: Product.self)
        }
    }
    
    func searchProducts(query: String) async throws -> [Product] {
        let lowercaseQuery = query.lowercased()
        let snapshot = try await db.collection("products").getDocuments()
        
        return try snapshot.documents.compactMap { doc in
            guard let product = try? doc.data(as: Product.self) else { return nil }
            
            // Lokale Suche in den Produktdaten
            let titleMatch = product.title.lowercased().contains(lowercaseQuery)
            let descriptionMatch = product.description.lowercased().contains(lowercaseQuery)
            let categoryMatch = product.category.lowercased().contains(lowercaseQuery)
            
            return (titleMatch || descriptionMatch || categoryMatch) ? product : nil
        }
    }
}
