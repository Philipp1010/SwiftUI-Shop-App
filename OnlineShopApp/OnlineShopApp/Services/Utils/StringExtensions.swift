//
//  StringExtensions.swift
//  OnlineShopApp
//
//  Created by Philipp Hermann on 22.01.25.
//

import Foundation

extension String {
    /// Prüft ob ein String einem bestimmten Regex-Pattern entspricht
    func matches(pattern: String) -> Bool {
        return self.range(of: pattern, options: .regularExpression) != nil
    }
    
    /// Formatiert eine Kreditkartennummer mit Leerzeichen
    func formatAsCardNumber() -> String {
        let cleaned = self.filter { $0.isNumber }
        var formatted = ""
        for (index, char) in cleaned.prefix(16).enumerated() {
            if index > 0 && index % 4 == 0 {
                formatted += " "
            }
            formatted.append(char)
        }
        return formatted
    }
    
    /// Formatiert ein Ablaufdatum (MM/YY)
    func formatAsExpiryDate() -> String {
        let cleaned = self.filter { $0.isNumber }
        var formatted = ""
        for (index, char) in cleaned.prefix(4).enumerated() {
            if index == 2 {
                formatted += "/"
            }
            formatted.append(char)
        }
        return formatted
    }
    
    /// Entfernt alle Leerzeichen aus einem String
    var withoutSpaces: String {
        self.replacingOccurrences(of: " ", with: "")
    }
    
    /// Prüft ob der String eine gültige E-Mail-Adresse ist
    var isValidEmail: Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        return self.matches(pattern: emailRegex)
    }
    
    /// Formatiert eine E-Mail-Adresse (erster Buchstabe groß, Rest klein)
    func formatAsEmail() -> String {
        guard !self.isEmpty else { return self }
        let components = self.lowercased().split(separator: "@")
        guard components.count == 2 else { return self.lowercased() }
        
        let localPart = String(components[0])
        let domain = components[1]
        
        return localPart.prefix(1).uppercased() + localPart.dropFirst() + "@" + domain
    }
}
