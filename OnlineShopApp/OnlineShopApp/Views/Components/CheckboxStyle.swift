//
//  CheckboxStyle.swift
//  OnlineShopApp
//
//  Created by Philipp Hermann on 03.01.25.
//

import SwiftUI

struct CheckboxStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            Image(systemName: configuration.isOn ? "checkmark.square.fill" : "square")
                .foregroundColor(configuration.isOn ? .black : .gray)
                .onTapGesture {
                    configuration.isOn.toggle()
                }
            configuration.label
        }
    }
}

#Preview {
    Toggle(isOn: .constant(true)) {
        Text("Remember me")
    }
    .toggleStyle(CheckboxStyle())
    .padding()
}
