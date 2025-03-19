//
//  CustomTextField.swift
//  OnlineShopApp
//
//  Created by Philipp Hermann on 03.01.25.
//

import SwiftUI

struct CustomTextField: View {
    @Binding var text: String
    let placeholder: String
    let icon: String
    let formatter: (String) -> String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.gray)
            TextField(placeholder, text: Binding(
                get: { text },
                set: { text = formatter($0) }
            ))
            .textInputAutocapitalization(.never)
            .keyboardType(icon == "creditcard" || icon == "calendar" || icon == "lock" ? .numberPad : .default)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }
}

#Preview {
    VStack(spacing: 20) {
        CustomTextField(
            text: .constant(""),
            placeholder: "Name",
            icon: "person",
            formatter: { $0 }
        )
        
        CustomTextField(
            text: .constant("1234"),
            placeholder: "Nummer",
            icon: "number",
            formatter: { $0 }
        )
    }
    .padding()
}
