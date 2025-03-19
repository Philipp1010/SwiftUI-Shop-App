//
//  AppUser.swift
//  OnlineShopApp
//
//  Created by Philipp Hermann on 14.01.25.
//

import FirebaseFirestore

/// Repräsentiert einen Benutzer der App
struct AppUser: Codable, Identifiable {
    @DocumentID var id: String?     // Firestore Document ID
    var fullName: String            // Name des Benutzers
    var email: String               // E-Mail-Adresse
    var registerDate: Date = Date() // Datum der Registrierung
}
