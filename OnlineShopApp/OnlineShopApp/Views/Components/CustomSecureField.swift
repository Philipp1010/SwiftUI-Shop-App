//
//  CustomSecureField.swift
//  OnlineShopApp
//
//  Created by Philipp Hermann on 03.01.25.
//

import SwiftUI

struct CustomSecureField: View {
    @Binding var text: String
    let placeholder: String
    let icon: String
    let formatter: (String) -> String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.gray)
            SecureField(placeholder, text: Binding(
                get: { text },
                set: { text = formatter($0) }
            ))
            .textInputAutocapitalization(.never)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }
}

#Preview {
    CustomSecureField(
        text: .constant(""),
        placeholder: "Password",
        icon: "lock",
        formatter: { $0 }
    )
    .padding()
}
