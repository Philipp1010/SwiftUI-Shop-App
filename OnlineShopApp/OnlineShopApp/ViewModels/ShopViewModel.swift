//
//  ShopViewModel.swift
//  OnlineShopApp
//
//  Created by Philipp Hermann on 19.12.24.
//

import Foundation

/// ViewModel für die Hauptfunktionalität des Shops
/// Verwaltet Produkte, Kategorien, Marken und Filter
@MainActor
class ShopViewModel: ObservableObject {
    /// Liste aller verfügbaren Produkte
    @Published var products: [Product] = []
    
    /// Liste aller Produktkategorien
    @Published var categories: [String] = []
    
    /// Liste aller verfügbaren Marken
    @Published var brands: [Brand] = []
    
    /// Aktueller Suchtext
    @Published var searchText: String = ""
    
    /// Aktuell ausgewählte Kategorie
    @Published var selectedCategory: String = "all"
    
    /// Aktuell ausgewählte Marke
    @Published var selectedBrand: String?
    
    /// Minimaler Preisfilter
    @Published var minPrice: Double?
    
    /// Maximaler Preisfilter
    @Published var maxPrice: Double?
    
    /// Minimale Bewertung Filter
    @Published var minRating: Double?
    
    /// Aktuelle Sortierungsoption
    @Published var sortOption: SortOption = .none
    
    /// Zeigt an ob Daten geladen werden
    @Published var isLoading = false
    
    /// Aktuelle Fehlermeldung
    @Published var error: String?
    
    /// Verfügbare Sortierungsoptionen
    enum SortOption {
        case none               // Keine Sortierung
        case priceAscending    // Preis aufsteigend
        case priceDescending   // Preis absteigend
        case ratingDescending  // Bewertung absteigend
    }
    
    /// API Service für Produktdaten
    private let apiService = APIService.shared
    
    /// Initialisiert den ViewModel und lädt die Marken
    init() {
        loadBrands()
    }
    
    /// Lädt die verfügbaren Marken
    /// - Note: Aktuell hardcodiert, könnte später aus API geladen werden
    private func loadBrands() {
        brands = [
            Brand(id: 1, name: "Adidas", logoName: "adidas", description: "Impossible is Nothing"),
            Brand(
                id: 2,
                name: "Nike",
                logoName: "nike",
                description: "Just Do It"
            ),
            Brand(
                id: 3,
                name: "Fila",
                logoName: "fila",
                description: "The Choice of Champions"
            ),
            Brand(
                id: 4,
                name: "Puma",
                logoName: "puma",
                description: "Forever Faster"
            )
        ]
    }
    
    /// Lädt alle Produkte und Kategorien von der API
    func loadProducts() {
        isLoading = true
        error = nil
        
        Task {
            do {
                products = try await apiService.fetchProducts()
                if categories.isEmpty {
                    categories = try await apiService.fetchCategories()
                    categories.insert("all", at: 0)
                }
            } catch {
                self.error = error.localizedDescription
            }
            isLoading = false
        }
    }
    
    /// Gefilterte und sortierte Produktliste basierend auf allen aktiven Filtern
    var filteredProducts: [Product] {
        var result = products
        
        // Kategoriefilter
        if selectedCategory.lowercased() != "all" {
            result = result.filter { $0.category == selectedCategory }
        }
        
        // Textsuche
        if !searchText.isEmpty {
            result = result.filter { product in
                product.title.lowercased().contains(searchText.lowercased()) ||
                product.description.lowercased().contains(searchText.lowercased()) ||
                product.category.lowercased().contains(searchText.lowercased())
            }
        }
        
        // Markenfilter
        if let brand = selectedBrand {
            result = result.filter { $0.category.contains(brand) }
        }
        
        // Preisfilter
        if let min = minPrice {
            result = result.filter { $0.price >= min }
        }
        if let max = maxPrice {
            result = result.filter { $0.price <= max }
        }
        
        // Bewertungsfilter
        if let minRating = minRating {
            result = result.filter { $0.rating.rate >= minRating }
        }
        
        // Sortierung
        switch sortOption {
        case .priceAscending:
            result.sort { $0.price < $1.price }
        case .priceDescending:
            result.sort { $0.price > $1.price }
        case .ratingDescending:
            result.sort { $0.rating.rate > $1.rating.rate }
        case .none:
            break
        }
        
        return result
    }
    
    /// Setzt alle Filter zurück auf Standardwerte
    func resetFilters() {
        minPrice = nil
        maxPrice = nil
        minRating = nil
        sortOption = .none
    }
    
    /// Führt eine Produktsuche durch
    /// - Parameter query: Suchbegriff
    /// - Note: Trackt das Suchereignis in Analytics
    func searchProducts(query: String) {
        searchText = query
        AnalyticsManager.shared.logSearch(searchTerm: query)
    }
}
