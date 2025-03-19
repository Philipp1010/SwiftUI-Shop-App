//
//  FilterView.swift
//  OnlineShopApp
//
//  Created by Philipp Hermann on 14.01.25.
//

import SwiftUI

struct FilterView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: ShopViewModel
    
    // Lokale State-Variablen für den Slider
    @State private var minPriceValue: Double = 0
    @State private var maxPriceValue: Double = 1000
    
    // Konstanten für den Preisbereich
    private let priceRange: ClosedRange<Double> = 0...1000
    private let step: Double = 5
    
    var body: some View {
        NavigationView {
            Form {
                // Sortierung
                Section(header: Text("Sortierung")) {
                    Picker("Sortieren nach", selection: $viewModel.sortOption) {
                        Text("Standard").tag(ShopViewModel.SortOption.none)
                        Text("Preis aufsteigend").tag(ShopViewModel.SortOption.priceAscending)
                        Text("Preis absteigend").tag(ShopViewModel.SortOption.priceDescending)
                        Text("Beste Bewertung").tag(ShopViewModel.SortOption.ratingDescending)
                    }
                }
                
                // Preisfilter mit Slider
                Section(header: Text("Preisbereich")) {
                    VStack {
                        // Preis-Labels
                        HStack {
                            Text("$\(Int(minPriceValue))")
                            Spacer()
                            Text("$\(Int(maxPriceValue))")
                        }
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        
                        // Slider
                        RangeSlider(
                            minValue: $minPriceValue,
                            maxValue: $maxPriceValue,
                            range: priceRange,
                            step: step
                        )
                        .frame(height: 30)
                    }
                    .padding(.vertical, 8)
                }
                .onChange(of: minPriceValue) { _ in
                    viewModel.minPrice = minPriceValue
                }
                .onChange(of: maxPriceValue) { _ in
                    viewModel.maxPrice = maxPriceValue
                }
                
                // Bewertungsfilter
                Section(header: Text("Mindestbewertung")) {
                    Picker("Mindestens", selection: $viewModel.minRating) {
                        Text("Alle").tag(nil as Double?)
                        Text("⭐️⭐️⭐️⭐️⭐️").tag(5.0 as Double?)
                        Text("⭐️⭐️⭐️⭐️").tag(4.0 as Double?)
                        Text("⭐️⭐️⭐️").tag(3.0 as Double?)
                    }
                }
                
                // Filter zurücksetzen
                Section {
                    Button("Filter zurücksetzen") {
                        viewModel.resetFilters()
                    }
                    .foregroundColor(.red)
                }
            }
            .navigationTitle("Filter")
            .navigationBarItems(trailing: Button("Fertig") {
                dismiss()
            })
            .onAppear {
                // Initialisiere Slider mit aktuellen Werten
                minPriceValue = viewModel.minPrice ?? 0
                maxPriceValue = viewModel.maxPrice ?? 1000
            }
        }
    }
}

// Custom RangeSlider View
struct RangeSlider: View {
    @Binding var minValue: Double
    @Binding var maxValue: Double
    let range: ClosedRange<Double>
    let step: Double
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Track
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 4)
                
                // Selected Range
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color.black)
                    .frame(width: position(for: maxValue, in: geometry.size) - position(for: minValue, in: geometry.size),
                           height: 4)
                    .offset(x: position(for: minValue, in: geometry.size))
                
                // Min Thumb
                Circle()
                    .fill(Color.white)
                    .frame(width: 24, height: 24)
                    .shadow(radius: 4)
                    .offset(x: position(for: minValue, in: geometry.size) - 12)
                    .gesture(dragGesture(for: .min, in: geometry.size))
                
                // Max Thumb
                Circle()
                    .fill(Color.white)
                    .frame(width: 24, height: 24)
                    .shadow(radius: 4)
                    .offset(x: position(for: maxValue, in: geometry.size) - 12)
                    .gesture(dragGesture(for: .max, in: geometry.size))
            }
        }
    }
    
    private func position(for value: Double, in size: CGSize) -> CGFloat {
        let percent = (value - range.lowerBound) / (range.upperBound - range.lowerBound)
        return CGFloat(percent) * size.width
    }
    
    private func dragGesture(for thumb: Thumb, in size: CGSize) -> some Gesture {
        DragGesture()
            .onChanged { drag in
                let width = size.width
                let xOffset = drag.location.x
                let percent = Double(xOffset / width)
                let value = range.lowerBound + (range.upperBound - range.lowerBound) * percent
                let steppedValue = round(value / step) * step
                
                switch thumb {
                case .min:
                    minValue = min(max(steppedValue, range.lowerBound), maxValue - step)
                case .max:
                    maxValue = max(min(steppedValue, range.upperBound), minValue + step)
                }
            }
    }
    
    private enum Thumb {
        case min, max
    }
}

#Preview {
    FilterView(viewModel: ShopViewModel())
}
