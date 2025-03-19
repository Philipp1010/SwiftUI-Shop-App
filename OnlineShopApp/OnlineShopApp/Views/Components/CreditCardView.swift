//
//  CreditCardView.swift
//  OnlineShopApp
//
//  Created by Philipp Hermann on 22.01.25.
//

import SwiftUI

struct CreditCardView: View {
    @Binding var cardNumber: String
    @Binding var cardHolder: String
    @Binding var expiryDate: String
    @Binding var cvv: String
    @State private var isCardFlipped = false
    
    var body: some View {
        VStack {
            // Kreditkarte
            ZStack {
                // Vorderseite
                Group {
                    if !isCardFlipped {
                        CardFrontView(
                            cardNumber: $cardNumber,
                            cardHolder: $cardHolder,
                            expiryDate: $expiryDate
                        )
                    } else {
                        CardBackView(cvv: $cvv)
                    }
                }
                .rotation3DEffect(
                    .degrees(isCardFlipped ? 180 : 0),
                    axis: (x: 0.0, y: 1.0, z: 0.0)
                )
            }
            .frame(width: 320, height: 200)
            .onTapGesture {
                withAnimation(.spring()) {
                    isCardFlipped.toggle()
                }
            }
            
            // Eingabefelder
            VStack(spacing: 20) {
                CustomTextField(
                    text: $cardNumber,
                    placeholder: "Kartennummer",
                    icon: "creditcard",
                    formatter: { $0.formatAsCardNumber() }
                )
                
                CustomTextField(
                    text: $cardHolder,
                    placeholder: "Karteninhaber",
                    icon: "person",
                    formatter: { $0.uppercased() }
                )
                
                HStack(spacing: 20) {
                    CustomTextField(
                        text: $expiryDate,
                        placeholder: "MM/YY",
                        icon: "calendar",
                        formatter: { $0.formatAsExpiryDate() }
                    )
                    .frame(width: 150)
                    
                    CustomTextField(
                        text: $cvv,
                        placeholder: "CVV",
                        icon: "lock",
                        formatter: { $0.prefix(3).description }
                    )
                    .frame(width: 150)
                }
            }
            .padding()
        }
    }
}

struct CardFrontView: View {
    @Binding var cardNumber: String
    @Binding var cardHolder: String
    @Binding var expiryDate: String
    
    var body: some View {
        ZStack {
            // Hintergrund
            LinearGradient(
                gradient: Gradient(colors: [.blue, .purple]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            VStack(alignment: .leading, spacing: 20) {
                // Chip & Logo
                HStack {
                    Image(systemName: "creditcard.fill")
                        .font(.title)
                    Spacer()
                    Image(systemName: "wave.3.right")
                        .font(.title)
                }
                
                // Kartennummer
                Text(cardNumber.isEmpty ? "•••• •••• •••• ••••" : cardNumber)
                    .font(.title2)
                    .kerning(3)
                
                HStack {
                    VStack(alignment: .leading) {
                        Text("CARD HOLDER")
                            .font(.caption2)
                            .opacity(0.7)
                        Text(cardHolder.isEmpty ? "YOUR NAME" : cardHolder)
                            .font(.callout)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .leading) {
                        Text("EXPIRES")
                            .font(.caption2)
                            .opacity(0.7)
                        Text(expiryDate.isEmpty ? "MM/YY" : expiryDate)
                            .font(.callout)
                    }
                }
            }
            .foregroundColor(.white)
            .padding(20)
        }
        .cornerRadius(15)
    }
}

struct CardBackView: View {
    @Binding var cvv: String
    
    var body: some View {
        ZStack {
            // Hintergrund
            LinearGradient(
                gradient: Gradient(colors: [.purple, .blue]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            VStack {
                // Magnetstreifen
                Rectangle()
                    .fill(Color.black)
                    .frame(height: 50)
                    .padding(.top, 20)
                
                // CVV
                HStack {
                    Spacer()
                    ZStack(alignment: .trailing) {
                        Rectangle()
                            .fill(Color.white)
                            .frame(width: 200, height: 40)
                        
                        Text(cvv.isEmpty ? "•••" : cvv)
                            .kerning(3)
                            .padding(.trailing, 10)
                            .foregroundColor(.black)
                    }
                    .padding(.trailing, 20)
                }
                
                Spacer()
            }
        }
        .cornerRadius(15)
        .rotation3DEffect(
            .degrees(180),
            axis: (x: 0.0, y: 1.0, z: 0.0)
        )
    }
}

#Preview {
    VStack {
        CreditCardView(
            cardNumber: .constant("4242 4242 4242 4242"),
            cardHolder: .constant("MAX MUSTERMANN"),
            expiryDate: .constant("12/25"),
            cvv: .constant("123")
        )
        
        // Leere Karte zum Testen
        CreditCardView(
            cardNumber: .constant(""),
            cardHolder: .constant(""),
            expiryDate: .constant(""),
            cvv: .constant("")
        )
    }
    .padding()
}

// Preview für die einzelnen Komponenten
#Preview("Card Front") {
    CardFrontView(
        cardNumber: .constant("4242 4242 4242 4242"),
        cardHolder: .constant("MAX MUSTERMANN"),
        expiryDate: .constant("12/25")
    )
    .frame(width: 320, height: 200)
    .padding()
}

#Preview("Card Back") {
    CardBackView(cvv: .constant("123"))
        .frame(width: 320, height: 200)
        .padding()
}
