//
//  Brand.swift
//  OnlineShopApp
//
//  Created by Philipp Hermann on 19.12.24.
//

import Foundation

/// Repräsentiert eine Marke/Hersteller im Shop
struct Brand: Identifiable {
    let id: Int
    let name: String         // Name der Marke
    let logoName: String     // Name des lokalen Logo-Assets
    let description: String  // Kurzbeschreibung der Marke
}
