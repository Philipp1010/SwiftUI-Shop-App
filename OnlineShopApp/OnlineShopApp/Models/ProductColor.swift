//
//  ProductColor.swift
//  OnlineShopApp
//
//  Created by Philipp Hermann on 02.01.25.
//

import SwiftUI

struct ProductColor: Identifiable, Equatable {
    let id = UUID()
    let name: String
    let color: Color
    
    static let available: [ProductColor] = [
        ProductColor(name: "Black", color: .black),
        ProductColor(name: "White", color: .white),
        ProductColor(name: "Gray", color: Color(.systemGray3)),
        ProductColor(name: "Blue", color: Color(.systemBlue)),
        ProductColor(name: "Red", color: Color(.systemRed))
    ]
    
    static func == (lhs: ProductColor, rhs: ProductColor) -> Bool {
        return lhs.name == rhs.name && lhs.color == rhs.color
    }
}
