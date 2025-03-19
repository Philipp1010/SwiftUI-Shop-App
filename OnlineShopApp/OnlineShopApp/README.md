//
//  README.md
//  OnlineShopApp
//
//  Created by Philipp Hermann on 03.01.25.
//

# OnlineShopApp - iOS Shopping App

Eine moderne iOS Shopping App, entwickelt mit SwiftUI. Die App bietet ein elegantes Einkaufserlebnis mit Fokus auf Mode und Lifestyle-Produkte.

## Features

### 🛍️ Shopping Experience
- Übersichtliche Produktgalerie mit Grid-Layout
- Live-Suchfunktion mit sofortigen Ergebnissen
- Produktfilterung nach Kategorien
- Detaillierte Produktansichten mit Bewertungen
- Einfache und intuitive Navigation
- Optimierte Bilddarstellung
- Intelligente Filterung:
  - Nach Kategorien
  - Nach Preis (aufsteigend/absteigend)
  - Nach Bewertungen
  - Nach Verfügbarkeit

### 🛒 Warenkorb & Checkout
- Intuitiver Warenkorb mit +/- Mengensteuerung
- Automatische Gesamtpreisberechnung
- Übersichtliche Bestellzusammenfassung
- Validierter Checkout-Prozess
- Animierte Bestellbestätigung

### ❤️ Personalisierung
- Animierte Favoritenfunktion mit pulsierendem Herz-Icon
- Persistente Merkliste
- Session-basierte Datenspeicherung

### 🎨 Design & UI
- Modernes, minimalistisches Interface
- Custom TabBar mit dynamischer Badge-Anzeige
- Einheitliches Farbschema (Blau/Weiß)
- Smooth Animationen und Übergänge

### 🔐 Authentication
- Firebase Email/Password Authentication
- Sicherer Login/Logout Flow
- Geschützter Bereich für angemeldete Nutzer
- Error Handling bei Authentifizierung

## Technische Details

### Architektur
- MVVM-Architektur
- SwiftUI Framework
- @StateObject/@ObservedObject für State Management
- Sheet-basierte Navigation

### Datenmodelle
- Robuste Model-Struktur:
  - Product Model mit Rating-System
  - Cart & CartItem Models
  - Order & Checkout Models
- Codable Protokoll-Implementierung
- Computed Properties für Preisberechnungen

### UI-Komponenten
- Wiederverwendbare Komponenten:
  - AddToCartAnimation
  - BrandView
  - BuyLoadingAnimation
  - CategoryButton
  - CheckboxStyle
  - ColorButton
  - CreditCardView
  - CustomSecureField
  - Custom TabBar
  - CustomTextField
  - FilterView
  - ProductCard
  - ProductGridView
  - SearchBarView
  - SizeButton
  - SlideShowView
  - SocialLoginButton
  - TabButton
  - Haptic Feedback Integration

### Datenhandling
- Asynchrone API-Calls mit async/await
- JSON Decoding mit Codable Protocol
- Error Handling mit Custom Error Types
- In-Memory Caching für Warenkorb/Favoriten
- Kategorie-basiertes Filtering
- Live-Search mit direktem Feedback

### Netzwerk
- FakeStore API Integration
- RESTful API Calls für:
  - Produkte abrufen
  - Kategorien laden
  - Produktdetails
- Robustes Error Handling mit User Feedback

### Analytics
- Firebase Analytics Grundintegration
- Event Tracking für:
  - Seitenaufrufe
  - Produktansichten
  - Warenkorbaktionen
  - Käufe

### Features in Entwicklung
- Apple/Google Sign-In Integration
- Lokale Datenpersistenz
- Erweiterte Nutzerprofile

## Installation

1. Repository klonen
2. Xcode 15.0+ öffnen
3. Firebase-Konfigurationsdatei hinzufügen
4. Build & Run

## Anforderungen

- iOS 16.0+
- Xcode 15.0+
- Swift 5.9+
- Firebase Account

[]

## Autor

Entwickelt von [Philipp Hermann]
