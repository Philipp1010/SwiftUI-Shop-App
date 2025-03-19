//
//  DateExtensions.swift
//  OnlineShopApp
//
//  Created by Philipp Hermann on 22.01.25.
//

import Foundation

extension Date {
    /// Formatiert ein Datum als String (z.B. "01.01.2024")
    func formatted() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        return formatter.string(from: self)
    }
    
    /// Formatiert ein Datum mit Uhrzeit (z.B. "01.01.2024 14:30")
    func formattedWithTime() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy HH:mm"
        return formatter.string(from: self)
    }
}
