//
//  UserRepositoryImplementation.swift
//  OnlineShopApp
//
//  Created by Philipp Hermann on 14.01.25.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

/// Repository für alle Benutzer-bezogenen Authentifizierungs- und Datenbankoperationen
protocol UserRepository {
    /// Lädt einen Benutzer anhand seiner ID aus der Datenbank
    /// - Parameter id: Eindeutige Benutzer-ID (Firebase Auth UID)
    /// - Returns: Der gefundene AppUser mit allen Benutzerdaten
    /// - Throws: FirebaseError wenn der Benutzer nicht gefunden wird oder die Verbindung fehlschlägt
    func getUserByID(_ id: String) async throws -> AppUser
    
    /// Authentifiziert einen Benutzer mit E-Mail und Passwort
    /// - Parameters:
    ///   - email: E-Mail-Adresse des Benutzers
    ///   - password: Passwort des Benutzers
    /// - Throws: FirebaseError bei ungültigen Anmeldedaten oder Verbindungsproblemen
    func login(email: String, password: String) async throws
    
    /// Registriert einen neuen Benutzer
    /// - Parameters:
    ///   - email: E-Mail-Adresse für den neuen Account
    ///   - password: Gewünschtes Passwort
    ///   - fullName: Vor- und Nachname des Benutzers
    /// - Throws: FirebaseError wenn die E-Mail bereits existiert oder die Registrierung fehlschlägt
    func register(email: String, password: String, fullName: String) async throws
    
    /// Meldet den aktuellen Benutzer ab
    /// - Throws: FirebaseError wenn die Abmeldung fehlschlägt
    func signOut() throws
}

class UserRepositoryImplementation: UserRepository {
    private let fb = FirebaseService.shared
    
    func getUserByID(_ id: String) async throws -> AppUser {
        return try await fb.database
            .collection("users")
            .document(id)
            .getDocument(as: AppUser.self)
    }
    
    func login(email: String, password: String) async throws {
        do {
            try await fb.auth.signIn(withEmail: email, password: password)
        } catch let error as NSError {
            print("DEBUG - Original Firebase Error: \(error.localizedDescription)")
            print("DEBUG - Error Code: \(error.code)")
            throw AuthError(message: error.localizedDescription)
        }
    }
    
    func register(email: String, password: String, fullName: String) async throws {
        do {
            let result = try await fb.auth.createUser(withEmail: email, password: password)
            let user = AppUser(fullName: fullName, email: email)
            try fb.database
                .collection("users")
                .document(result.user.uid)
                .setData(from: user)
        } catch let error as NSError {
            throw AuthError(message: error.localizedDescription)
        }
    }
    
    func signOut() throws {
        try fb.auth.signOut()
    }
}

// Custom Error Type
struct AuthError: Error {
    let message: String
}
