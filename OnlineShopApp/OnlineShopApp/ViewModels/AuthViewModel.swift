//
//  AuthViewModel.swift
//  OnlineShopApp
//
//  Created by Philipp Hermann on 19.12.24.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

/// ViewModel für die Authentifizierung und Benutzerverwaltung
@MainActor
class AuthViewModel: ObservableObject {
    /// Aktuell eingeloggter Benutzer
    @Published var currentUser: AppUser?
    
    /// Status ob ein Benutzer eingeloggt ist
    @Published var isAuthenticated = false
    
    /// Zeigt an ob gerade eine Auth-Operation läuft
    @Published var isLoading = false
    
    /// Fehler-Nachricht bei fehlgeschlagener Auth
    @Published var error: String?
    
    /// Listener für Änderungen am Auth-Status
    private var listener: AuthStateDidChangeListenerHandle?
    
    /// Repository für Benutzer-Operationen
    private let userRepo: UserRepository
    
    /// Initialisiert das ViewModel und startet den Auth-Listener
    init() {
        self.userRepo = UserRepositoryImplementation()
        setupAuthListener()
    }
    
    /// Richtet den Firebase Auth State Listener ein
    /// - Note: Aktualisiert isAuthenticated und lädt Benutzerdaten wenn eingeloggt
    private func setupAuthListener() {
        listener = FirebaseService.shared.auth.addStateDidChangeListener { [weak self] _, user in
            self?.isAuthenticated = user != nil
            if let userId = user?.uid {
                Task {
                    do {
                        let appUser = try await self?.userRepo.getUserByID(userId)
                        DispatchQueue.main.async {
                            self?.currentUser = appUser
                        }
                    } catch {
                        print("Error fetching user: \(error)")
                    }
                }
            }
        }
    }
    
    private func localizeError(_ error: Error) -> String {
        print("DEBUG - Error Type: \(type(of: error))")
        
        if let authError = error as? AuthError {
            let errorMessage = authError.message
            print("DEBUG - Auth Error Message: \(errorMessage)")
            
            // Firebase Auth Fehlermeldungen übersetzen
            if errorMessage.contains("The password is invalid") ||
               errorMessage.contains("wrong password") {
                return "Falsches Passwort"
            }
            
            switch errorMessage {
            case _ where errorMessage.contains("password") && errorMessage.contains("invalid"):
                return "Falsches Passwort"
                
            case _ where errorMessage.contains("no user record"):
                return "Kein Benutzer mit dieser E-Mail-Adresse gefunden"
                
            case _ where errorMessage.contains("badly formatted"):
                return "Ungültige E-Mail-Adresse"
                
            case _ where errorMessage.contains("already in use"):
                return "Diese E-Mail-Adresse wird bereits verwendet"
                
            case _ where errorMessage.contains("missing"):
                return "Bitte alle Felder ausfüllen"
                
            default:
                print("DEBUG - Unhandled Error Message: \(errorMessage)")
                return "Falsches Passwort"  // Wenn es ein Auth-Error ist, ist es meist das Passwort
            }
        }
        
        print("DEBUG - Unknown Error: \(error)")
        return "Ein Fehler ist aufgetreten. Bitte versuchen Sie es später erneut"
    }
    
    /// Meldet einen Benutzer mit E-Mail und Passwort an
    /// - Parameters:
    ///   - email: E-Mail-Adresse des Benutzers
    ///   - password: Passwort des Benutzers
    /// - Note: Aktualisiert isLoading und error States
    func login(email: String, password: String) {
        isLoading = true
        error = nil
        
        // Eingabevalidierung
        if email.isEmpty {
            error = "Bitte geben Sie eine E-Mail-Adresse ein"
            isLoading = false
            return
        }
        if password.isEmpty {
            error = "Bitte geben Sie ein Passwort ein"
            isLoading = false
            return
        }
        
        Task {
            do {
                try await userRepo.login(email: email, password: password)
            } catch {
                self.error = localizeError(error)
            }
            isLoading = false
        }
    }
    
    /// Registriert einen neuen Benutzer
    /// - Parameters:
    ///   - fullName: Vor- und Nachname
    ///   - email: E-Mail-Adresse
    ///   - password: Gewünschtes Passwort
    /// - Note: Erstellt auch ein Firestore-Dokument für den Benutzer
    func register(fullName: String, email: String, password: String) {
        isLoading = true
        error = nil
        
        // Eingabevalidierung
        if fullName.isEmpty {
            error = "Bitte geben Sie Ihren Namen ein"
            isLoading = false
            return
        }
        
        // Neue Validierung für den Namen
        let nameRegex = "^[A-Za-zÄäÖöÜüß\\s]+$"  // Erlaubt Buchstaben, Umlaute und Leerzeichen
        if fullName.range(of: nameRegex, options: .regularExpression) == nil {
            error = "Der Name darf nur Buchstaben enthalten"
            isLoading = false
            return
        }
        
        if email.isEmpty {
            error = "Bitte geben Sie eine E-Mail-Adresse ein"
            isLoading = false
            return
        }
        
        if password.isEmpty {
            error = "Bitte geben Sie ein Passwort ein"
            isLoading = false
            return
        }
        
        Task {
            do {
                try await userRepo.register(email: email, password: password, fullName: fullName)
            } catch {
                self.error = localizeError(error)
            }
            isLoading = false
        }
    }
    
    /// Meldet den aktuellen Benutzer ab
    /// - Note: Löscht alle lokalen Benutzerdaten
    func signOut() {
        do {
            try userRepo.signOut()
        } catch {
            print("Sign out error: \(error)")
        }
    }
    
    /// Entfernt den Auth-Listener beim Aufräumen
    deinit {
        if let listener = listener {
            FirebaseService.shared.auth.removeStateDidChangeListener(listener)
        }
    }
}
