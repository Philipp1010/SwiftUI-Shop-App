//
//  FavoritesViewModel.swift
//  OnlineShopApp
//
//  Created by Philipp Hermann on 14.01.25.
//

import Foundation

/// ViewModel für die Verwaltung der Wunschliste/Favoriten
@MainActor
class FavoritesViewModel: ObservableObject {
    /// Liste der favorisierten Produkte
    @Published var favoriteItems: [Product] = []
    
    /// Initialisiert den ViewModel und lädt gespeicherte Favoriten
    init() {
        Task {
            await loadFavorites()
        }
    }
    
    /// Lädt die gespeicherten Favoriten aus Firebase
    /// - Note: Wird beim Start und nach Login aufgerufen
    func loadFavorites() async {
        do {
            favoriteItems = try await FirebaseManager.shared.loadFavorites()
        } catch {
            print("Error loading favorites: \(error)")
        }
    }
    
    /// Fügt ein Produkt zur Wunschliste hinzu
    /// - Parameter product: Das zu favorisierende Produkt
    /// - Note: Trackt das Event in Analytics
    func addToFavorites(product: Product) {
        if !favoriteItems.contains(where: { $0.id == product.id }) {
            favoriteItems.append(product)
            AnalyticsManager.shared.logAddToWishlist(product: product)
            saveFavorites()
        }
    }
    
    /// Entfernt ein Produkt aus der Wunschliste
    /// - Parameter product: Das zu entfernende Produkt
    func removeFromFavorites(product: Product) {
        favoriteItems.removeAll { $0.id == product.id }
        saveFavorites()
    }
    
    /// Prüft ob ein Produkt bereits favorisiert ist
    /// - Parameter product: Das zu prüfende Produkt
    /// - Returns: true wenn das Produkt in den Favoriten ist
    func isFavorite(_ product: Product) -> Bool {
        favoriteItems.contains(where: { $0.id == product.id })
    }
    
    /// Speichert die aktuellen Favoriten in Firebase
    /// - Note: Wird nach jeder Änderung an den Favoriten aufgerufen
    private func saveFavorites() {
        Task {
            do {
                try await FirebaseManager.shared.saveFavorites(products: favoriteItems)
            } catch {
                print("Error saving favorites: \(error)")
            }
        }
    }
}
