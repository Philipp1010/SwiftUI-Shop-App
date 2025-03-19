//
//  FirebaseService.swift
//  OnlineShopApp
//
//  Created by Philipp Hermann on 14.01.25.
//

import FirebaseAuth
import FirebaseFirestore

/// Service-Klasse für grundlegende Firebase-Konfiguration und Zugriff
/// Stellt zentrale Referenzen für Auth und Firestore bereit
class FirebaseService {
    /// Shared Instance für den globalen Zugriff (Singleton Pattern)
    static let shared = FirebaseService()
    
    /// Private Initialisierer verhindert externe Instanziierung
    private init() {}
    
    /// Firebase Authentication Instanz
    /// Verwendet für alle Auth-bezogenen Operationen
    let auth = Auth.auth()
    
    /// Firestore Datenbank Instanz
    /// Verwendet für alle Datenbank-Operationen
    let database = Firestore.firestore()
    
    /// ID des aktuell eingeloggten Benutzers
    /// - Returns: Die UID des authentifizierten Benutzers oder nil wenn nicht eingeloggt
    var currentUserID: String? {
        auth.currentUser?.uid
    }
}
