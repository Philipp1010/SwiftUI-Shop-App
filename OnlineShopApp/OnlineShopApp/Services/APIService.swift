//
//  APIService.swift
//  OnlineShopApp
//
//  Created by Philipp Hermann on 14.01.25.
//

import Foundation

/// Mögliche Fehler bei API-Anfragen
enum APIError: Error {
    case invalidURL        // URL konnte nicht erstellt werden
    case invalidResponse   // Server-Antwort ist ungültig (kein 200 Status)
    case decodingError    // JSON konnte nicht in Swift-Objekte konvertiert werden
    case networkError(Error) // Allgemeiner Netzwerkfehler
}

/// Service-Klasse für alle API-Anfragen an den FakeStore
class APIService {
    /// Shared Instance für den globalen Zugriff (Singleton Pattern)
    static let shared = APIService()
    
    /// Private Initialisierer verhindert externe Instanziierung
    private init() {}
    
    /// Basis-URL des FakeStore API
    private let baseURL = "https://fakestoreapi.com"
    
    /// Lädt alle verfügbaren Produkte vom Server
    /// - Returns: Array aller Produkte
    /// - Throws: APIError wenn die Anfrage fehlschlägt
    /// - Note: Verwendet die /products Endpoint
    func fetchProducts() async throws -> [Product] {
        guard let url = URL(string: "\(baseURL)/products") else {
            throw APIError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw APIError.invalidResponse
        }
        
        do {
            return try JSONDecoder().decode([Product].self, from: data)
        } catch {
            print("Decoding error: \(error)")
            throw APIError.decodingError
        }
    }
    
    /// Lädt alle verfügbaren Produktkategorien
    /// - Returns: Array von Kategorie-Namen
    /// - Throws: APIError wenn die Anfrage fehlschlägt
    /// - Note: Verwendet die /products/categories Endpoint
    func fetchCategories() async throws -> [String] {
        guard let url = URL(string: "\(baseURL)/products/categories") else {
            throw APIError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw APIError.invalidResponse
        }
        
        return try JSONDecoder().decode([String].self, from: data)
    }
    
    /// Lädt Produkte einer bestimmten Kategorie
    /// - Parameter category: Name der gewünschten Kategorie
    /// - Returns: Array von Produkten in dieser Kategorie
    /// - Throws: APIError wenn die Anfrage fehlschlägt
    /// - Note: Verwendet die /products/category/{category} Endpoint
    func fetchProductsByCategory(_ category: String) async throws -> [Product] {
        guard let url = URL(string: "\(baseURL)/products/category/\(category)") else {
            throw APIError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw APIError.invalidResponse
        }
        
        return try JSONDecoder().decode([Product].self, from: data)
    }
}
